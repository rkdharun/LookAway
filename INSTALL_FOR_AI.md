# Install Guide (for an AI agent)

This file is written for another AI coding agent tasked with building and
installing the **Look Away** macOS app on a user's machine. Follow these steps
in order. Stop and report to the user if any prerequisite check fails.

## 0. Preconditions to verify

Run these and confirm before proceeding:

```sh
sw_vers -productVersion        # must be >= 13.0 (macOS Ventura)
xcodebuild -version            # Xcode must be installed (15+); if this fails, Xcode is missing
xcode-select -p                # should point at an Xcode.app, not just CommandLineTools
```

- If `xcodebuild` is missing or points at `CommandLineTools`, the full Xcode app
  is required (not just Command Line Tools) because this project uses a
  `.xcodeproj` and SwiftUI. Ask the user to install Xcode from the App Store, or
  run `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.
- This is a native Swift/SwiftUI + AppKit app. There is **no** package manager
  step (no npm/pip/brew), no dependencies to fetch, and no `Package.resolved`.

## 1. Build a Release binary

From the repository root (the directory containing `LookAway.xcodeproj`):

```sh
xcodebuild \
  -project LookAway.xcodeproj \
  -scheme LookAway \
  -configuration Release \
  -derivedDataPath ./build \
  build
```

On success the app bundle is at:

```
./build/Build/Products/Release/LookAway.app
```

If the build fails with a code-signing error, retry with signing disabled
(fine for local/personal use):

```sh
xcodebuild -project LookAway.xcodeproj -scheme LookAway -configuration Release \
  -derivedDataPath ./build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  build
```

## 2. Install into /Applications

```sh
cp -R "./build/Build/Products/Release/LookAway.app" /Applications/
```

## 3. First launch

```sh
open /Applications/LookAway.app
```

Because the app is unsigned/un-notarized, Gatekeeper may block the first launch.
If the user reports "app can't be opened", clear the quarantine attribute:

```sh
xattr -dr com.apple.quarantine /Applications/LookAway.app
```

Then open it again. The user may also need to approve it once under
**System Settings → Privacy & Security**.

## 4. Verify it's running

- The app is an **accessory** app (`LSUIElement = true`): it has **no Dock icon
  and no window on launch**. This is expected — do not treat the absent Dock
  icon as a failure.
- Confirm it launched by checking for the process and the menu bar item:

```sh
pgrep -x LookAway && echo "running"
```

- The user should see an **eye icon with a countdown timer** in the menu bar
  (top-right). Clicking it opens the menu; "Open Look Away" (⌘O) shows settings.

## 5. Uninstall (if needed)

```sh
osascript -e 'quit app "Look Away"' 2>/dev/null || pkill -x LookAway
rm -rf /Applications/LookAway.app
```

Settings are stored in `UserDefaults` under bundle id `com.lookaway.app`; to also
wipe preferences:

```sh
defaults delete com.lookaway.app 2>/dev/null || true
```

## Notes

- Deployment target: macOS 13.0. Bundle id: `com.lookaway.app`. Swift 5.
- No network access, no entitlements beyond a default sandbox, no external
  dependencies.
- The pre-built `LookAwayBin` binary and `LookAway.app` in the source tree are
  git-ignored; always build fresh from source per the steps above.
