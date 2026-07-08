import Foundation

/// Cosmetic slot a shop item occupies. Purely visual — the brief is explicit
/// that monetisation must never be pay-to-win, so nothing here affects
/// physics, spawn rates or scoring.
enum ShopItemCategory: String, Codable, CaseIterable, Hashable {
    case outfit
    case hat
    case backpack
    case pet
    case trail
    case background
}

/// The currency a shop item is priced in.
enum CurrencyType: String, Codable, Hashable {
    case coins
    case cocoTokens
    case premium // real-money one-time unlock, see IAPManager
}

/// Cosmetic rarity, purely for shop presentation (border color, sparkle FX).
enum ItemRarity: String, Codable, CaseIterable, Hashable {
    case common, rare, epic, legendary

    var accentHex: String {
        switch self {
        case .common: return "#B7B7C9"
        case .rare: return "#5DADE2"
        case .epic: return "#AF7AC5"
        case .legendary: return "#F4C542"
        }
    }
}

/// A single purchasable cosmetic. Everything the shop, inventory and
/// character preview screens render is described by this struct so new
/// items can be added purely as data.
struct ShopItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: ShopItemCategory
    /// `nil` means the item is universal (fits both characters); otherwise
    /// restricted to one character's rig (e.g. Debbie's sun hat).
    let restrictedTo: CharacterType?
    let price: Int
    let currency: CurrencyType
    let rarity: ItemRarity
    /// Name of the placeholder glyph/emoji shown until real art is dropped in.
    let placeholderEmoji: String
    /// Underlying asset/texture-atlas key real art should register under.
    let assetKey: String

    static let catalog: [ShopItem] = [
        // Outfits
        ShopItem(id: "outfit_debbie_sakura", name: "Sakura Kimono", category: .outfit, restrictedTo: .debbie, price: 250, currency: .coins, rarity: .rare, placeholderEmoji: "👘", assetKey: "outfit_debbie_sakura"),
        ShopItem(id: "outfit_alex_barista", name: "Barista Apron", category: .outfit, restrictedTo: .alex, price: 250, currency: .coins, rarity: .rare, placeholderEmoji: "🧑‍🍳", assetKey: "outfit_alex_barista"),
        ShopItem(id: "outfit_debbie_festival", name: "Festival Yukata", category: .outfit, restrictedTo: .debbie, price: 15, currency: .cocoTokens, rarity: .epic, placeholderEmoji: "🎆", assetKey: "outfit_debbie_festival"),
        ShopItem(id: "outfit_alex_gold", name: "Golden Café Suit", category: .outfit, restrictedTo: .alex, price: 0, currency: .premium, rarity: .legendary, placeholderEmoji: "✨", assetKey: "outfit_alex_gold"),

        // Hats
        ShopItem(id: "hat_mochi_beanie", name: "Mochi Beanie", category: .hat, restrictedTo: nil, price: 80, currency: .coins, rarity: .common, placeholderEmoji: "🎩", assetKey: "hat_mochi_beanie"),
        ShopItem(id: "hat_cat_ears", name: "Cat Ears", category: .hat, restrictedTo: nil, price: 120, currency: .coins, rarity: .rare, placeholderEmoji: "🐱", assetKey: "hat_cat_ears"),
        ShopItem(id: "hat_lantern_crown", name: "Lantern Crown", category: .hat, restrictedTo: nil, price: 10, currency: .cocoTokens, rarity: .epic, placeholderEmoji: "🏮", assetKey: "hat_lantern_crown"),

        // Backpacks
        ShopItem(id: "backpack_boba_cup", name: "Boba Cup Backpack", category: .backpack, restrictedTo: nil, price: 150, currency: .coins, rarity: .rare, placeholderEmoji: "🎒", assetKey: "backpack_boba_cup"),
        ShopItem(id: "backpack_bento", name: "Bento Box Backpack", category: .backpack, restrictedTo: nil, price: 150, currency: .coins, rarity: .rare, placeholderEmoji: "🍱", assetKey: "backpack_bento"),

        // Pets
        ShopItem(id: "pet_kitten", name: "Mochi Kitten", category: .pet, restrictedTo: nil, price: 20, currency: .cocoTokens, rarity: .epic, placeholderEmoji: "🐈", assetKey: "pet_kitten"),
        ShopItem(id: "pet_duckling", name: "Bubble Duckling", category: .pet, restrictedTo: nil, price: 300, currency: .coins, rarity: .rare, placeholderEmoji: "🐤", assetKey: "pet_duckling"),
        ShopItem(id: "pet_dragon", name: "Baby Boba Dragon", category: .pet, restrictedTo: nil, price: 0, currency: .premium, rarity: .legendary, placeholderEmoji: "🐉", assetKey: "pet_dragon"),

        // Trails
        ShopItem(id: "trail_sakura_petals", name: "Sakura Petal Trail", category: .trail, restrictedTo: nil, price: 100, currency: .coins, rarity: .common, placeholderEmoji: "🌸", assetKey: "trail_sakura_petals"),
        ShopItem(id: "trail_stardust", name: "Stardust Trail", category: .trail, restrictedTo: nil, price: 12, currency: .cocoTokens, rarity: .epic, placeholderEmoji: "✨", assetKey: "trail_stardust"),
        ShopItem(id: "trail_bubbles", name: "Bubble Tea Fizz Trail", category: .trail, restrictedTo: nil, price: 100, currency: .coins, rarity: .common, placeholderEmoji: "🫧", assetKey: "trail_bubbles"),

        // Backgrounds (cosmetic home-screen backdrops)
        ShopItem(id: "background_sunset_cafe", name: "Sunset Café Backdrop", category: .background, restrictedTo: nil, price: 200, currency: .coins, rarity: .rare, placeholderEmoji: "🌇", assetKey: "background_sunset_cafe"),
        ShopItem(id: "background_starry_rooftop", name: "Starry Rooftop Backdrop", category: .background, restrictedTo: nil, price: 18, currency: .cocoTokens, rarity: .epic, placeholderEmoji: "🌌", assetKey: "background_starry_rooftop"),
    ]
}
