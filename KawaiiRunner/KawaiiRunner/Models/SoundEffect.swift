import Foundation

/// Every short one-shot sound effect the game can play. `AudioManager` maps
/// each case to a file name it will look for in the app bundle. No audio
/// files ship with this scaffold — see `Resources/Audio/AUDIO_GUIDE.md` for
/// concrete style suggestions and the exact file names to add.
enum SoundEffect: String, CaseIterable, Hashable {
    case uiTap
    case uiConfirm
    case jump
    case doubleJump
    case slide
    case dash
    case land
    case collectSoft
    case collectSparkle
    case collectToken
    case magnetActivate
    case shieldActivate
    case shieldBreak
    case obstacleHit
    case comboReady
    case comboActivate
    case buddyLift
    case gameOver
    case newHighScore
    case purchase
    case rewardUnlock
    case wheelSpin
    case wheelWin

    /// File name (without extension) this effect expects to find bundled as
    /// a `.caf` / `.m4a` resource. Kept separate from the case name so audio
    /// assets can use friendlier, sound-designer facing names.
    var fileName: String {
        "sfx_\(rawValue)"
    }
}
