import SwiftUI
import SpriteKit

/// Hosts the `GameScene` inside a `SpriteView`, overlays the HUD and combo
/// button, translates one-handed touch gestures into `GameViewModel` calls,
/// and swaps in `PauseMenuView` / `GameOverView` as needed.
///
/// Gesture mapping: tap = jump (tap again while airborne = double jump,
/// handled contextually by `GameScene.handleTap()` rather than as a second
/// gesture — see the note there for why), swipe down = slide, long press = dash.
struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    init(leadCharacter: CharacterType) {
        _viewModel = StateObject(wrappedValue: GameViewModel(leadCharacter: leadCharacter))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { viewModel.onTap() }
                .simultaneousGesture(swipeDownGesture)
                .onLongPressGesture(minimumDuration: 0.25, maximumDistance: 40, pressing: { isPressing in
                    if isPressing {
                        viewModel.onLongPressBegan()
                    } else {
                        viewModel.onLongPressEnded()
                    }
                }, perform: {})

            VStack {
                GameHUDView(hud: viewModel.hud, onPause: { viewModel.togglePause() })
                Spacer()
                if let banner = viewModel.assistBanner {
                    AssistBannerView(text: banner.text)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
                ComboButtonView(hud: viewModel.hud, action: { viewModel.onComboButtonTapped() })
                    .padding(.bottom, 24)
            }
            .animation(.spring, value: viewModel.assistBanner)

            if viewModel.isPaused {
                PauseMenuView(
                    onResume: { viewModel.togglePause() },
                    onRestart: { viewModel.retry() },
                    onQuit: { dismiss() }
                )
            }
        }
        .statusBarHidden()
        .fullScreenCover(item: $viewModel.gameOverPayload) { payload in
            GameOverView(payload: payload, onRetry: { viewModel.retry() }, onHome: { dismiss() })
        }
    }

    // MARK: - Gestures

    private var swipeDownGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                if value.translation.height > 40, abs(value.translation.height) > abs(value.translation.width) {
                    viewModel.onSwipeDown()
                }
            }
    }
}
