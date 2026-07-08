import SwiftUI

/// Cosmetic-only shop: category tabs across the top, a scrollable grid of
/// `ShopItem`s below. Purchases are always optional and never affect
/// gameplay balance, per the brief's no-pay-to-win rule.
struct ShopView: View {
    @StateObject private var viewModel = ShopViewModel()
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Shop", onClose: { dismiss() })
            currencyHeader
            categoryPicker
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.itemsInSelectedCategory) { item in
                        ShopItemCard(item: item, viewModel: viewModel)
                    }
                }
                .padding()
            }
        }
        .background(KawaiiPalette.creamWhite.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var currencyHeader: some View {
        HStack {
            CurrencyBadge(systemImage: "dollarsign.circle.fill", value: viewModel.profile.coins)
            CurrencyBadge(systemImage: "sparkles", value: viewModel.profile.cocoTokens, tint: KawaiiPalette.lavender)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ShopItemCategory.allCases, id: \.self) { category in
                    Button {
                        viewModel.selectedCategory = category
                    } label: {
                        Text(category.rawValue.capitalized)
                            .font(.system(.caption, design: .rounded)).bold()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule().fill(viewModel.selectedCategory == category ? KawaiiPalette.mochiPink : Color.white)
                            )
                            .foregroundStyle(viewModel.selectedCategory == category ? .white : KawaiiPalette.textDark)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

private struct ShopItemCard: View {
    let item: ShopItem
    @ObservedObject var viewModel: ShopViewModel

    var body: some View {
        VStack(spacing: 8) {
            Text(item.placeholderEmoji)
                .font(.system(size: 40))
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color(hex: item.rarity.accentHex).opacity(0.25)))

            Text(item.name)
                .font(.system(.caption, design: .rounded)).bold()
                .multilineTextAlignment(.center)
                .foregroundStyle(KawaiiPalette.textDark)
                .lineLimit(2)

            actionButton
        }
        .padding()
        .frame(maxWidth: .infinity)
        .kawaiiCard()
        .kawaiiOutline(color: Color(hex: item.rarity.accentHex), lineWidth: 2)
    }

    @ViewBuilder
    private var actionButton: some View {
        if viewModel.isOwned(item) {
            Button {
                viewModel.equip(item)
            } label: {
                Text(viewModel.isEquipped(item) ? "Equipped" : "Equip")
                    .font(.system(.caption2, design: .rounded)).bold()
                    .padding(.vertical, 6).padding(.horizontal, 14)
                    .background(Capsule().fill(viewModel.isEquipped(item) ? KawaiiPalette.matchaGreen : Color.white))
            }
            .disabled(viewModel.isEquipped(item))
        } else if item.currency == .premium {
            Text("Premium")
                .font(.system(.caption2, design: .rounded)).bold()
                .padding(.vertical, 6).padding(.horizontal, 14)
                .background(Capsule().fill(KawaiiPalette.honeyYellow))
        } else {
            Button {
                viewModel.purchase(item)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: item.currency == .coins ? "dollarsign.circle.fill" : "sparkles")
                    Text("\(item.price)")
                }
                .font(.system(.caption2, design: .rounded)).bold()
                .padding(.vertical, 6).padding(.horizontal, 14)
                .background(Capsule().fill(viewModel.canAfford(item) ? KawaiiPalette.mochiPink : Color.gray.opacity(0.3)))
                .foregroundStyle(viewModel.canAfford(item) ? .white : .secondary)
            }
            .disabled(!viewModel.canAfford(item))
        }
    }
}

#Preview {
    ShopView()
}
