import StoreKit

/// Every purchasable product. All are cosmetic or convenience — per the
/// design brief this game is explicitly **not** pay-to-win. Register these
/// exact identifiers as In-App Purchases in App Store Connect before release.
enum IAPProduct: String, CaseIterable {
    case premiumExpansionPack = "com.debbiealex.kawaiirunner.premiumpack"
    case cosmeticBundleSakura = "com.debbiealex.kawaiirunner.cosmetics.sakura"
    case cosmeticBundleNightFestival = "com.debbiealex.kawaiirunner.cosmetics.nightfestival"
    case cocoTokens20 = "com.debbiealex.kawaiirunner.tokens.20"
    case cocoTokens100 = "com.debbiealex.kawaiirunner.tokens.100"

    /// Non-consumables grant a permanent unlock; consumables (token packs)
    /// can be purchased repeatedly.
    var isConsumable: Bool {
        switch self {
        case .cocoTokens20, .cocoTokens100: return true
        default: return false
        }
    }
}

/// Minimal protocol for a rewarded-video provider. `MockRewardedAdProvider`
/// simulates a watched ad instantly so the reward loop (e.g. "watch an ad to
/// double your run's coins") can be built and tested end-to-end before a
/// real ad network SDK (AdMob, Unity Ads, etc.) is wired in.
protocol RewardedAdProviding {
    func isAdReady() -> Bool
    func presentAd() async -> Bool // true if the player watched to completion
}

struct MockRewardedAdProvider: RewardedAdProviding {
    func isAdReady() -> Bool { true }
    func presentAd() async -> Bool {
        try? await Task.sleep(nanoseconds: 500_000_000)
        return true
    }
}

/// StoreKit 2 wrapper for the optional, cosmetic-only monetisation described
/// in the brief: cosmetic skin bundles, a rewarded-ad path, and one premium
/// expansion unlock. Every purchase is voluntary and skippable.
@MainActor
final class IAPManager: ObservableObject {
    static let shared = IAPManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []

    var rewardedAdProvider: RewardedAdProviding = MockRewardedAdProvider()

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = listenForTransactionUpdates()
        Task { await loadProducts() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        guard let loaded = try? await Product.products(for: IAPProduct.allCases.map(\.rawValue)) else { return }
        products = loaded
    }

    /// Purchases a StoreKit product, verifies the transaction, and unlocks
    /// the corresponding content on success.
    func purchase(_ product: Product) async -> Bool {
        guard let result = try? await product.purchase() else { return false }
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else { return false }
            await unlock(productID: transaction.productID)
            await transaction.finish()
            return true
        default:
            return false
        }
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            await unlock(productID: transaction.productID)
        }
    }

    /// Watches a rewarded ad and, on completion, doubles the coins earned in
    /// the just-finished run. Entirely optional — declining costs nothing.
    func watchAdToDoubleCoins(originalCoins: Int) async -> Int {
        guard rewardedAdProvider.isAdReady() else { return 0 }
        let watched = await rewardedAdProvider.presentAd()
        return watched ? originalCoins : 0
    }

    private func unlock(productID: String) async {
        purchasedProductIDs.insert(productID)
        guard let product = IAPProduct(rawValue: productID) else { return }
        switch product {
        case .cocoTokens20: EconomyManager.shared.grant(.cocoTokens(20))
        case .cocoTokens100: EconomyManager.shared.grant(.cocoTokens(100))
        case .premiumExpansionPack, .cosmeticBundleSakura, .cosmeticBundleNightFestival:
            // Non-consumables just flip `purchasedProductIDs`; ShopView reads
            // that set to unlock the associated cosmetic items for free.
            break
        }
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await self?.unlock(productID: transaction.productID)
                await transaction.finish()
            }
        }
    }
}
