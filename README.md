# Look Away

A lightweight macOS menu bar app that reminds you to rest your eyes using the **20-20-20 rule**: every 20 minutes, look at something 20 feet away for 20 seconds.

When the work interval ends, Look Away dims every screen with a full-screen break overlay and counts down your rest period. It lives quietly in the menu bar the rest of the time.

## Features

- **Menu bar timer** — shows a live countdown to your next break next to an eye icon.
- **Full-screen break overlay** — covers all connected displays when it's time to rest, with a progress countdown.
- **Skip or snooze** — end a break early, or snooze it and get back to work.
- **Configurable intervals** — pick a work interval (5–60 min) and break duration (10–60 sec).
- **Optional sound** — a gentle beep when a break begins.
- **Pause / Resume / Reset** and a **Preview Break Screen** action, all from the menu bar.
- **Runs as an accessory app** (`LSUIElement`) — no Dock icon, no window clutter.

## Requirements

- macOS 13.0 or later
- Xcode 15+ (Swift 5, SwiftUI + AppKit)

## Building

Open the project in Xcode and build the `LookAway` scheme:

```sh
open LookAway.xcodeproj
```

Or build from the command line:

```sh
xcodebuild -project LookAway.xcodeproj -scheme LookAway -configuration Release build
```

## Usage

Launch the app and it appears in the menu bar showing the countdown to your next break. Click the icon for the menu:

- **Open Look Away** (`⌘O`) — open the main window with settings.
- **Pause / Resume** (`⌘P`) — pause or resume the timer.
- **Reset Timer** (`⌘R`) — restart the current work interval.
- **Preview Break Screen** (`⌘B`) — trigger a break immediately to see the overlay.
- **Quit Look Away** (`⌘Q`).

During a break the overlay counts down; you can skip or snooze it. Settings (work interval, break duration, sound) are persisted between launches.

## Project structure

| File | Responsibility |
|------|----------------|
| `LookAwayApp.swift` | App entry point |
| `AppDelegate.swift` | Menu bar setup, window management, break overlay lifecycle |
| `TimerManager.swift` | Work/break timer state, persistence, and callbacks |
| `MainWindowView.swift` | Main window UI |
| `SettingsView.swift` | Timer and notification settings |
| `BreakOverlayView.swift` | Full-screen break overlay UI |
| `BreakWindow.swift` | Borderless window hosting the overlay on each screen |
