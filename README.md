# Orzen

Orzen is a local-first media server experience for the Apple ecosystem. It is
designed as a native place to browse movies, series, collections, search
catalogs, and manage media-related addons from a polished desktop interface.

The project currently focuses on macOS and uses remote catalog metadata from
Cinemeta/Stremio to populate movie and series shelves while keeping local
fallback content available when the network catalog cannot be reached.

## What Orzen Does

- Presents a native media library interface for movies and TV series.
- Loads popular, new, featured, and genre-based catalogs from Cinemeta.
- Provides dedicated views for Home, Search, Series, Movies, Collections, and
  Addons.
- Caches catalog and detail responses in memory during the app session.
- Displays poster and backdrop artwork through reusable SwiftUI components.
- Keeps a local fallback catalog so the interface remains usable offline or when
  remote metadata is unavailable.

## Apple Ecosystem Focus

Orzen is being built as an Apple-native media hub. The current Xcode target is a
macOS application, making it suitable for:

- MacBook Air and MacBook Pro
- iMac
- Mac mini
- Mac Studio
- Mac Pro

Current minimum supported operating system:

- macOS 14.2 or later

Because the app is written with SwiftUI, the project has a strong foundation for
future Apple platform expansion, such as iPadOS or tvOS, but those targets are
not enabled in the project yet.

## Tech Stack

- Swift
- SwiftUI
- Xcode project format
- Foundation networking with `URLSession`
- Swift concurrency with `async` / `await`
- In-memory actor-based catalog caches
- Cinemeta/Stremio metadata API
- SF Symbols for native Apple iconography

## Project Structure

```text
orzen/
  OrzenApp.swift              App entry point and macOS window configuration
  ContentView.swift           Main navigation routing and home/addons views
  Sidebar.swift               Sidebar navigation and shared layout constants
  Components/                 Reusable catalog, artwork, and info components
  Features/                   Movies, series, search, and collections screens
  Models/                     Catalog models and Cinemeta client code
  Assets.xcassets/            App icons, accent color, and visual assets
```

## Requirements

- macOS 14.2 or later
- Xcode with SwiftUI support
- Internet access for live Cinemeta catalog metadata
- Homebrew `mpv` installed locally for its `libmpv` playback library, used by
  MKV, HEVC/x265, and other non-native in-app playback paths (`brew install mpv`)

## Development

1. Open `Orzen.xcodeproj` in Xcode.
2. Select the `Orzen` scheme.
3. Choose a macOS run destination.
4. Build and run the app.

The app uses `URLSession` to fetch catalog data at runtime. If remote content
cannot be loaded, Orzen falls back to local placeholder catalog items so the UI
can still be developed and tested.
