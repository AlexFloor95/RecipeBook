import SwiftUI
import Combine

/// Drives the Shop and Inventory screens: category filtering, ownership
/// state and the buy/equip actions. All purchase math lives in
/// `EconomyManager`; this view model is purely presentation + filtering.
@MainActor
final class ShopViewModel: ObservableObject {
    @Published var selectedCategory: ShopItemCategory = .outfit
    @Published private(set) var profile: PlayerProfile

    private var cancellable: AnyCancellable?

    init() {
        profile = SaveManager.shared.profile
        cancellable = SaveManager.shared.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.profile = $0 }
    }

    var itemsInSelectedCategory: [ShopItem] {
        ShopItem.catalog.filter { $0.category == selectedCategory }
    }

    var ownedItems: [ShopItem] {
        ShopItem.catalog.filter { profile.unlockedShopItemIDs.contains($0.id) }
    }

    func isOwned(_ item: ShopItem) -> Bool {
        profile.unlockedShopItemIDs.contains(item.id)
    }

    func isEquipped(_ item: ShopItem) -> Bool {
        profile.equippedItems[item.category] == item.id
    }

    func canAfford(_ item: ShopItem) -> Bool {
        switch item.currency {
        case .coins: return profile.coins >= item.price
        case .cocoTokens: return profile.cocoTokens >= item.price
        case .premium: return false // routed through IAPManager instead
        }
    }

    @discardableResult
    func purchase(_ item: ShopItem) -> Bool {
        EconomyManager.shared.purchase(item)
    }

    func equip(_ item: ShopItem) {
        EconomyManager.shared.equip(item)
    }
}
