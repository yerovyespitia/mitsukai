import Foundation

enum ExternalSubtitleResolver {
    static func fetchSubtitles(
        from addons: [LocalAddon],
        type: CinemetaType,
        id: String,
        allowedLanguageCodes: Set<String>
    ) async -> [ExternalSubtitleTrack] {
        await withTaskGroup(of: [ExternalSubtitleTrack].self) { group in
            for addon in addons {
                group.addTask {
                    (try? await StremioSubtitleClient.fetchSubtitles(
                        from: addon,
                        type: type,
                        id: id,
                        allowedLanguageCodes: allowedLanguageCodes
                    )) ?? []
                }
            }

            var allSubtitles: [ExternalSubtitleTrack] = []
            for await addonSubtitles in group {
                allSubtitles.append(contentsOf: addonSubtitles)
            }
            return allSubtitles
        }
    }
}
