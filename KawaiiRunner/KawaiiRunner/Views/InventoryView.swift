import SwiftUI

/// Shows everything the player has already unlocked, grouped by category,
/// with quick equip/unequip actions — a read-focused counterpart to `ShopView`.
struct InventoryView: View {
    @StateObject private var viewModel = ShopViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Inventory", onClose: { dismiss() })
            if viewModel.ownedItems.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(ShopItemCategory.allCases, id: \.self) { category in
                            let items = viewModel.ownedItems.filter { $0.category == category }
                            if !items.isEmpty {
                                categorySection(category, items)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .kawaiiDecorativeBackdrop()
        .navigationBarHidden(true)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("🎁").font(.system(size: 56))
            Text("Nothing unlocked yet — visit the Shop!")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private func categorySection(_ category: ShopItemCategory, _ items: [ShopItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.rawValue.capitalized)
                .font(.system(.headline, design: .rounded)).bold()
                .foregroundStyle(KawaiiPalette.textDark)

            ForEach(items) { item in
                HStack {
                    Text(item.placeholderEmoji).font(.title2)
                    Text(item.name).font(.system(.subheadline, design: .rounded))
                    Spacer()
                    Button {
                        viewModel.equip(item)
                    } label: {
                        Text(viewModel.isEquipped(item) ? "Equipped" : "Equip")
                            .font(.system(.caption2, design: .rounded)).bold()
                            .padding(.vertical, 6).padding(.horizontal, 12)
                            .background(Capsule().fill(viewModel.isEquipped(item) ? KawaiiPalette.matchaGreen : Color.white))
                    }
                    .disabled(viewModel.isEquipped(item))
                }
                .padding(10)
                .kawaiiCard()
            }
        }
    }
}

#Preview {
    InventoryView()
}
