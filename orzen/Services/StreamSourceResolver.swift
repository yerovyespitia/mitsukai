import Foundation

enum StreamSourceResolver {
    private static let addonFetchTimeoutSeconds: UInt64 = 12

    static func fetchAllSources(
        from addons: [LocalAddon],
        type: CinemetaType,
        id: String
    ) async -> [StreamSource] {
        await withTaskGroup(of: [StreamSource].self) { group in
            for addon in addons {
                group.addTask {
                    await fetchSourcesWithTimeout(from: addon, type: type, id: id)
                }
            }

            var allSources: [StreamSource] = []
            for await addonSources in group {
                allSources.append(contentsOf: addonSources)
            }
            return sortedSourcesForCurrentPlatform(allSources)
        }
    }

    static func firstSource(
        from addons: [LocalAddon],
        type: CinemetaType,
        id: String
    ) async -> StreamSource? {
        for addon in addons {
            let sources = sortedSourcesForCurrentPlatform(
                await fetchSourcesWithTimeout(from: addon, type: type, id: id)
            )
            if let source = firstPlayableSourceForCurrentPlatform(in: sources) {
                return source
            }
        }

        return nil
    }

    static func matchingSource(
        for storedSource: StreamSource,
        in sources: [StreamSource]
    ) -> StreamSource? {
        let matchedSource = sources.first { $0.id == storedSource.id }
            ?? sources.first { $0.playbackURL == storedSource.playbackURL }
            ?? sources.first { $0.title == storedSource.title }

        #if os(iOS)
        if let matchedSource,
           NativePlaybackCompatibilityResolver.compatibility(for: matchedSource).canAttemptPlayback {
            return matchedSource
        }

        return NativePlaybackCompatibilityResolver.bestNativeSource(in: sources)
            ?? matchedSource
            ?? sources.first
        #else
        return matchedSource ?? sources.first
        #endif
    }

    private static func sortedSourcesForCurrentPlatform(_ sources: [StreamSource]) -> [StreamSource] {
        #if os(iOS)
        return NativePlaybackCompatibilityResolver.sortedForNativePlayback(sources)
        #else
        return sources
        #endif
    }

    private static func firstPlayableSourceForCurrentPlatform(in sources: [StreamSource]) -> StreamSource? {
        #if os(iOS)
        return NativePlaybackCompatibilityResolver.bestNativeSource(in: sources) ?? sources.first
        #else
        return sources.first
        #endif
    }

    private static func fetchSourcesWithTimeout(
        from addon: LocalAddon,
        type: CinemetaType,
        id: String
    ) async -> [StreamSource] {
        await withTaskGroup(of: [StreamSource]?.self) { group in
            group.addTask {
                (try? await StremioStreamClient.fetchSources(from: addon, type: type, id: id)) ?? []
            }

            group.addTask {
                try? await Task.sleep(nanoseconds: addonFetchTimeoutSeconds * 1_000_000_000)
                return nil
            }

            let sources = await group.next() ?? nil
            group.cancelAll()
            return sources ?? []
        }
    }
}
