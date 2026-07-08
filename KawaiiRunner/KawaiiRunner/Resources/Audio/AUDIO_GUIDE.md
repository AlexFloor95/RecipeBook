# Audio Guide

No audio files ship with this scaffold. `AudioManager` is fully wired up and
will play anything you drop into the app bundle under the exact names below
— it fails silently if a file isn't present yet, so the game is completely
playable (just quiet) before audio is produced.

Supported formats: `.m4a` (preferred, smallest), `.caf`, `.mp3`, `.wav`.
Drop files directly into the `KawaiiRunner` folder (or a subgroup) in Xcode
with **no extension mismatch** — `AudioManager` tries `m4a`, `caf`, `mp3`,
`wav` in that order for every name.

## Music (looping, per world) — `WorldTheme.musicTrackName`

| File name | World | Mood direction |
|---|---|---|
| `music_mochiCafe` | Mochi Café | Warm lo-fi hip-hop, soft vinyl crackle, marimba |
| `music_sakuraPark` | Sakura Park | Airy lo-fi, koto plucks, gentle wind chimes |
| `music_bubbleTeaStreet` | Bubble Tea Street | Upbeat lo-fi, tapioca-pearl percussion, synth bass |
| `music_cozyMarket` | Cozy Market | Acoustic guitar lo-fi, light hand-clap percussion |
| `music_nightFestival` | Night Festival | Dreamy lo-fi city-pop, distant taiko drums |
| `music_rooftopGarden` | Rooftop Garden | Chill lo-fi, rain-stick shakers, soft flute |

Target ~90-100 BPM, seamless loop points, -14 LUFS integrated for consistent
perceived loudness across tracks.

## Ambience beds (looping, layered under music) — `WorldTheme.ambienceTrackName`

| File name | Suggested content |
|---|---|
| `ambience_mochiCafe` | Café chatter, espresso machine hiss, cup clinks |
| `ambience_sakuraPark` | Birdsong, rustling sakura leaves, distant kids playing |
| `ambience_bubbleTeaStreet` | Street bustle, shaker cups, bicycle bells |
| `ambience_cozyMarket` | Market vendor calls, fabric rustle, wind chimes |
| `ambience_nightFestival` | Festival crowd murmur, paper lanterns creaking, distant fireworks |
| `ambience_rooftopGarden` | Light wind, wind chimes, distant city hum |

## Sound effects (one-shot) — `SoundEffect.fileName`

| File name | Trigger | Style note |
|---|---|---|
| `sfx_uiTap` | Generic button tap | Soft pop |
| `sfx_uiConfirm` | Confirm/purchase | Bright chime |
| `sfx_jump` | Jump | Light "boing" |
| `sfx_doubleJump` | Double jump | Higher-pitched boing + sparkle |
| `sfx_slide` | Slide | Quick whoosh |
| `sfx_dash` | Dash | Fast whoosh + sparkle burst |
| `sfx_land` | Landing | Soft thud |
| `sfx_collectSoft` | Mochi / bubble tea / flower pickup | Cute "pop" |
| `sfx_collectSparkle` | Heart / star pickup | Sparkly chime |
| `sfx_collectToken` | Coco Token pickup | Rich coin chime |
| `sfx_magnetActivate` | Magnet power-up | Magnetic "zwoop" |
| `sfx_shieldActivate` | Shield power-up gained / Buddy Block | Protective "shimmer" |
| `sfx_shieldBreak` | Shield absorbs a hit | Glass-like crack, still cute |
| `sfx_obstacleHit` | Obstacle collision (unused if always absorbed — reserved for future) | Soft bonk |
| `sfx_comboReady` | Combo Meter fills | Rising arpeggio |
| `sfx_comboActivate` | Team Combo Move triggered | Big celebratory sting |
| `sfx_buddyLift` | Team Lift assist | Playful "hup!" |
| `sfx_gameOver` | Run ends | Gentle descending tone (never harsh) |
| `sfx_newHighScore` | New high score | Triumphant jingle |
| `sfx_purchase` | Shop purchase | Cash register "cha-ching" (soft) |
| `sfx_rewardUnlock` | Achievement/mission reward | Sparkly fanfare |
| `sfx_wheelSpin` | Lucky Wheel spinning | Ratchet/tick loop |
| `sfx_wheelWin` | Lucky Wheel result | Bright win jingle |

Keep every SFX under ~600ms, layered with a touch of pitch randomization in
a future pass to avoid repetition fatigue during long sessions.
