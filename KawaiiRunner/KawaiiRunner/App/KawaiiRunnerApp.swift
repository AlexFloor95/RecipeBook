import SwiftUI

/// App entry point. Kept intentionally thin — all real setup lives in the
/// singleton managers (`SaveManager`, `AudioManager`, ...), which lazily
/// initialize themselves on first access, and in `RootView`, which owns
/// navigation between the Home screen and every other feature screen.
@main
struct KawaiiRunnerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light) // the kawaii palette is designed for a light backdrop
        }
    }
}
