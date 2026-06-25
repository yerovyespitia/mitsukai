import Foundation

enum StreamSourceResolver {
    static func fetchAllSources(
        from addons: [LocalAddon],
        type: CinemetaType,
        id: String
    ) async -> [StreamSource] {
        await withTaskGroup(of: [StreamSource].self) { group in
            for addon in addons {
                group.addTask {
                    (try? await StremioStreamClient.fetchSources(from: addon, type: type, id: id)) ?? []
                }
            }

            var allSources: [StreamSource] = []
            for await addonSources in group {
                allSources.append(contentsOf: addonSources)
            }
            return allSources
        }
    }

    static func firstSource(
        from addons: [LocalAddon],
        type: CinemetaType,
        id: String
    ) async -> StreamSource? {
        for addon in addons {
            let sources = (try? await StremioStreamClient.fetchSources(from: addon, type: type, id: id)) ?? []
            if let source = sources.first {
                return source
            }
        }

        return nil
    }

    static func matchingSource(
        for storedSource: StreamSource,
        in sources: [StreamSource]
    ) -> StreamSource? {
        sources.first { $0.id == storedSource.id }
            ?? sources.first { $0.playbackURL == storedSource.playbackURL }
            ?? sources.first { $0.title == storedSource.title }
            ?? sources.first
    }
}
