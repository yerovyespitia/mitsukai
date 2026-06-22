import Foundation

struct StreamSource: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let addonName: String
    let title: String
    let description: String
    let metadata: [String]
    let sourceCategory: StreamSourceCategory
    let playbackURL: URL?

    var preferredPlaybackEngine: StreamPlaybackEngine {
        guard playbackURL != nil else { return .native }
        return .mpv
    }

    var nativePlaybackError: String? {
        guard let playbackURL else {
            return "This source does not expose a direct video URL. The native player can only open direct HTTP or HTTPS video streams returned by the addon."
        }

        guard ["http", "https"].contains(playbackURL.scheme?.lowercased()) else {
            return "This source uses an unsupported URL scheme: \(playbackURL.scheme ?? "unknown")."
        }

        return nil
    }

}

enum StreamSourceCategory: String, Codable, Hashable, Sendable {
    case general
    case spanish
}

enum StreamPlaybackEngine: Sendable {
    case native
    case mpv
}

enum StremioStreamClient {
    static func fetchSources(
        from addon: LocalAddon,
        type: CinemetaType,
        id: String
    ) async throws -> [StreamSource] {
        let url = streamURL(from: addon.manifestURL, type: type, id: id)
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let streamResponse = try JSONDecoder().decode(StremioStreamResponse.self, from: data)
        return streamResponse.streams.enumerated().map { index, stream in
            stream.source(
                addonName: addon.name,
                fallbackID: "\(addon.id.uuidString)-\(index)",
                sourceCategory: addon.sourceCategory
            )
        }
    }

    private static func streamURL(from manifestURL: URL, type: CinemetaType, id: String) -> URL {
        var baseURL = manifestURL
        if baseURL.lastPathComponent == "manifest.json" {
            baseURL.deleteLastPathComponent()
        }

        return baseURL
            .appending(path: "stream")
            .appending(path: type.rawValue)
            .appending(path: id)
            .appendingPathExtension("json")
    }
}

private struct StremioStreamResponse: Decodable {
    let streams: [StremioStream]
}

private struct StremioStream: Decodable {
    let name: String?
    let title: String?
    let description: String?
    let url: URL?
    let infoHash: String?
    let fileIdx: Int?

    func source(
        addonName: String,
        fallbackID: String,
        sourceCategory: StreamSourceCategory
    ) -> StreamSource {
        let lines = (title ?? name ?? "Source")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let resolvedTitle = lines.first ?? name ?? "Source"
        let resolvedDescription = description ?? lines.dropFirst().joined(separator: "  ")
        let idParts = [fallbackID, infoHash, fileIdx.map(String.init), resolvedTitle]
            .compactMap { $0 }

        return StreamSource(
            id: idParts.joined(separator: "-"),
            addonName: addonName,
            title: resolvedTitle,
            description: resolvedDescription.isEmpty ? "No source details available." : resolvedDescription,
            metadata: metadata(addonName: addonName, titleLines: lines),
            sourceCategory: sourceCategory,
            playbackURL: url
        )
    }

    private func metadata(addonName: String, titleLines: [String]) -> [String] {
        var values = [addonName]

        if let quality = titleLines.first(where: { $0.range(of: #"(?i)\b(4k|2160p|1080p|720p|480p)\b"#, options: .regularExpression) != nil }) {
            values.append(quality)
        }

        if let seeders = titleLines.first(where: { $0.localizedCaseInsensitiveContains("seed") }) {
            values.append(seeders)
        }

        return values
    }
}
