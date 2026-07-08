# Mochi Dash — Debbie & Alex's Kawaii Runner

A complete, from-scratch iOS game project (SwiftUI + SpriteKit, MVVM) built
in the cozy, colorful style of kawaii café/bubble-tea aesthetics. Debbie and
Alex auto-run together through six themed worlds, dodging obstacles,
collecting mochi/boba/stars, and helping each other survive. Sessions are
tuned for 2–5 minutes: easy to pick up, hard to put down.

This scaffold is **code-complete and ready to open in Xcode 16+** on iOS 18.
It ships with no external sprite-art or audio *assets*, but every visual is
drawn procedurally at a genuinely polished level — glossy sphere-shaded
characters, gradient sticker cards, a multi-layer parallax sky with a
sun/moon and drifting clouds, and a consistent glossy "candy UI" — using
runtime-baked Core Graphics textures (see "Graphics" below). Every sound
effect is a documented "please add this file" slot, so the whole game runs
and is fully playable today, and is a drop-in target for real art/audio/IAP
configuration before an App Store submission.

## Opening the project

1. Open `KawaiiRunner.xcodeproj` in Xcode 16 or later.
2. Select the `KawaiiRunner` scheme (auto-created by Xcode on first open)
   and an iOS 18+ simulator (e.g. iPhone 16).
3. Build & run — no signing, packages, or configuration is required to see
   the game running with placeholder visuals and silent (but fully wired)
   audio hooks.
4. The project uses Xcode 16's **file-system-synchronized groups**: every
   Swift file physically present under `KawaiiRunner/` is automatically part
   of the target. Add new files straight from Finder/Xcode's file navigator
   — there is nothing to register in the `.pbxproj`.

### Before shipping to the App Store

- Replace the procedural placeholder visuals (see "Placeholder art" below)
  with real sprite art.
- Add the audio files listed in `KawaiiRunner/Resources/Audio/AUDIO_GUIDE.md`.
- Swap the generated placeholder App Icon (`Assets.xcassets/AppIcon.appiconset/icon-1024.png`)
  for a professionally designed one — it's a real, App Store-shaped 1024×1024
  PNG today (matches the in-game character style) but is still a placeholder.
- Register the Game Center leaderboard ID and StoreKit products referenced
  in `GameCenterManager` and `IAPManager` in App Store Connect, and add a
  `StoreKit Configuration File` for local testing.
- Review `PRODUCT_BUNDLE_IDENTIFIER` (`com.debbiealex.kawaiirunner`) and set
  your own team/signing in the target's Signing & Capabilities tab.

## Architecture

**MVVM**, with SpriteKit deliberately walled off behind one seam:

```
Models        Pure data & game-balance constants. No UIKit/SpriteKit imports.
Managers      Singletons owning one cross-cutting concern each (save, audio,
              economy, missions, achievements, IAP, Game Center, haptics).
Game/         SpriteKit only lives here. GameScene is the single class that
              touches SpriteKit APIs directly; everything else talks to it
              through GameSceneDelegate / GameHUDState / RunSummary.
ViewModels/   @MainActor ObservableObjects bridging Managers + GameScene to
              SwiftUI. Own all @Published state; views never reach into
              Managers or GameScene directly.
Views/        SwiftUI only. Presentation + gesture handling; no game logic.
Extensions/   Shared cross-layer helpers (hex colors, view modifiers).
```

Why this split: SpriteKit's imperative, per-frame world doesn't map cleanly
onto SwiftUI's declarative state model. Rather than fighting that, `GameScene`
runs its own authoritative simulation and reports a small, immutable
snapshot (`GameHUDState`) up through a delegate once per frame; SwiftUI only
ever renders that snapshot. This keeps the SpriteKit layer swappable
(you could replace it with Metal/RealityKit later touching only `GameView`
and `GameViewModel`) and keeps the SwiftUI layer trivially previewable.

### Folder-by-folder file guide

**Models/** — `CharacterType` (Debbie/Alex), `BuddyAssist` (the 3 cooperative
moves), `CollectibleType` (7 pickups from the brief), `ObstacleType` (6
hazards + how to avoid each), `PowerUpType` (Magnet/Shield), `WorldTheme` (6
worlds with palettes + music cues), `PlayerProfile` (the entire save file),
`ShopItem`/`Mission`/`Achievement`/`DailyReward`/`LeaderboardEntry`,
`SoundEffect` (every SFX name).

**Managers/** — `SaveManager` (JSON persistence), `AudioManager` (music/SFX),
`HapticsManager`, `EconomyManager` (currency + run scoring), `MissionManager`
(daily/weekly/streak/wheel), `AchievementManager`, `GameCenterManager`,
`IAPManager` (StoreKit 2 + rewarded-ad hook).

**Game/** — `GameScene` (the runner loop), `PlayerNode` + `CharacterFigureNode`
(the duo + procedural art), `ObstacleNode`/`CollectibleNode`/`PowerUpNode`,
`ParallaxBackgroundManager`, `DifficultyDirector` (pacing/spawning),
`ComboSystem`, `PhysicsCategory`, `ParticleFactory` +
`ParticleTextureFactory` (runtime-generated particle textures).

**ViewModels/** — one per screen: `GameViewModel`, `HomeViewModel`,
`ShopViewModel`, `SettingsViewModel`, `DailyRewardsViewModel`,
`MissionsViewModel`, `AchievementsViewModel`, `LeaderboardViewModel`.

**Views/** — `RootView` (navigation host), `HomeView`, `CharacterSelectView`,
`GameView` (SpriteView host + gestures + HUD), `PauseMenuView`,
`GameOverView`, `ShopView`, `InventoryView`, `MissionsView`,
`AchievementsView`, `LeaderboardView`, `SettingsView`, `DailyRewardsView` +
`LuckyWheelView`, and `Views/Components/*` (`KawaiiButton`, `CurrencyBadge`,
`ProgressBarView`, `SectionHeader`, `GameHUDView`, `ComboButtonView`,
`AssistBannerView`) — the shared visual language used by every screen.

## Gameplay systems

### Core loop & controls (one-handed)
Debbie & Alex auto-scroll forward. Input is a single-thumb gesture set on
`GameView`, forwarded to `GameScene` via `GameViewModel`:

| Gesture | Action |
|---|---|
| Tap | Jump |
| Double tap | Double jump (mid-air, once per airtime) |
| Swipe down | Slide (auto-releases after ~0.5s) |
| Long press | Dash (invincible burst; ends on release) |
| Tap combo button | Team Combo Move (once meter is full) |

### Physics
Real SpriteKit physics (`SKPhysicsBody`, `SKPhysicsWorld.gravity`,
`SKPhysicsContactDelegate`) drive jumping/falling and all collisions.
`PhysicsCategory` defines four bitmask categories (player/obstacle/
collectible/ground); `GameScene.didBegin(_:)` is the single place contacts
are resolved. Sliding swaps in a shorter/wider physics body; jump/double
jump apply upward impulses; the player never collides bodily with obstacles
(`collisionBitMask` excludes them) — only a *contact* is reported, so
`GameScene` can decide what happens (see cooperative defense below) instead
of SpriteKit's default bounce/stop resolution.

### Cooperative "help each other" system
The signature feature from the brief, implemented as a layered defense in
`GameScene.handleObstacleContact(_:)`, evaluated in order on every obstacle
contact:
1. **Dash or Combo invincibility** — always passes through for free.
2. **Team Lift** (`BuddyAssist.lift`) — if you didn't jump in time for a
   jump-required obstacle, Debbie/Alex automatically lift each other over it
   (6s cooldown), with an assist banner + haptic + sound.
3. **Shield pickup** — an active Shield (from a `PowerUpNode`) absorbs the
   hit and breaks.
4. **Buddy Block** (`BuddyAssist.shieldBlock`) — otherwise, if off its own
   10s cooldown, the buddy steps in and blocks the hit for free.
5. Only if none of the above apply does the run actually end.

The **Team Combo Move** (`BuddyAssist.comboMove`) is separate: collecting
Hearts/Stars fills a shared `ComboSystem` meter; once full, tapping the
combo button grants ~4s of full invincibility + a 2× score multiplier, with
a confetti burst and a glowing aura on both characters.

### Worlds & difficulty
`DifficultyDirector` tracks distance, ramps scroll speed smoothly, and
cycles through `WorldTheme.runOrder` every 350m (looping back to Mochi Café
at higher difficulty). It also guarantees fairness: obstacle spawn intervals
never drop below a reaction-time floor, and the same avoidance method
(jump/slide/dash) never repeats back-to-back. Each world biases its
obstacle/collectible mix and supplies its own four-layer backdrop palette
(sky zenith/horizon, sun-or-moon, mid-ground props, ground), cross-faded in
smoothly by `ParallaxBackgroundManager` on transition.

### Score system
`GameScene` accumulates score two ways: a small continuous trickle
proportional to distance scrolled (scaled by the Combo multiplier), plus a
flat bonus per collectible. `EconomyManager.applyRunSummary(_:)` is the only
place a finished run's score, coins, tokens and XP get written to
`PlayerProfile`, so there is one source of truth for "what happened this run."

### Save system
`SaveManager` holds the single `PlayerProfile` (currencies, unlocks,
equipped cosmetics, achievement/mission progress, streak state, run history,
settings) as `@Published`, persisted as JSON to the Documents directory.
Writes are debounced (`scheduleSave()`) so rapid in-run updates coalesce
into one disk write; `saveNow()` is available for "must persist immediately"
moments (e.g. after a purchase).

### Achievement & mission systems
`Achievement.all` defines a Bronze/Silver/Gold tier tree per stat family
(mochi collected, distance run, combos triggered, etc). `AchievementManager`
increments lifetime progress after every run and auto-unlocks + pays out
tiers as they're crossed. `MissionManager` rolls 3 random Daily + 3 random
Weekly missions from a larger pool, tracks progress the same way, and
auto-claims rewards the instant a mission completes — no separate "claim"
tap needed, keeping the loop frictionless for short sessions. It also owns
the 7-day login streak and the Day-7 Lucky Wheel (weighted random prize
table in `LuckyWheelPrize`).

### Audio manager
`AudioManager` plays one looping music track + one looping ambience bed per
world (cross-fading is handled by `ParallaxBackgroundManager`'s visual
transition running alongside `AudioManager.playMusic(for:)` swapping
tracks), plus a small recycling pool of one-shot SFX players so overlapping
sounds don't cut each other off. It never ships audio files — see
`Resources/Audio/AUDIO_GUIDE.md` for exact file names + creative direction
per track. Every playback call fails silently if the named resource isn't
bundled yet, so audio can be produced independently of gameplay code.

### Particle systems
`ParticleTextureFactory` renders small soft-dot/star/confetti textures at
runtime with Core Graphics (no image assets needed). `ParticleFactory`
turns those into tuned `SKEmitterNode`s for every moment that needs one:
collect sparkles, jump/land dust, dash trails, shield auras, magnet
sparkle, and the big Combo Move confetti burst.

### Placeholder art
No sprite/image assets ship with this project. `CharacterFigureNode` draws
Debbie & Alex as rounded shape-based "blobs" with big eyes, ears and blush
(the kawaii "faces on everything" look) purely in SpriteKit; obstacles and
collectibles render as a rounded card + emoji. Every placeholder is
isolated to one small "build visual" method per node class, so swapping in
real texture atlases later is a localized change.

## Monetisation

Strictly cosmetic and optional, per the brief's no-pay-to-win rule:
`ShopItem.catalog` defines outfits/hats/backpacks/pets/trails/backgrounds
priced in Coins, Coco Tokens, or a one-time Premium unlock. `IAPManager`
(StoreKit 2) handles real purchases + restore; `MockRewardedAdProvider`
stands in for a rewarded-video SDK so the "watch an ad to double this run's
coins" flow (see `GameOverView`) works end-to-end today — swap in a real ad
SDK by implementing `RewardedAdProviding`.

## What's intentionally out of scope here

- Real sprite/texture art, music and SFX audio files (see guides above).
- A configured StoreKit Configuration file / App Store Connect products.
- Unit/UI test targets (the architecture — small, pure `Models` and
  injectable managers — is written to make adding them straightforward).
- Cloud save sync (the seam is `SaveManager`; swap its file-based storage
  for CloudKit/NSUbiquitousKeyValueStore without touching any other layer).
