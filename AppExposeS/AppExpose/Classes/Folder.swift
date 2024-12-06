//
//  Folder.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/2/24.
//

struct Folder: Identifiable, Equatable, @preconcurrency Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var url: URL
    var entries: [AppEntry]

    enum CodingKeys: String, CodingKey {
        case id, name, url, entries
    }

    init(id: UUID, name: String, url: URL, entries: [AppEntry]) {
        self.id = id
        self.name = name
        self.url = url
        self.entries = entries
    }

    @MainActor func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url.absoluteString, forKey: .url)
        var entriesContainer = container.nestedUnkeyedContainer(forKey: .entries)
        for entry in entries {
            try entriesContainer.encode(entry.nonisolatedEncode())
        }
    }

    @MainActor
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let urlString = try container.decode(String.self, forKey: .url)
        url = URL(string: urlString)!
        var entriesContainer = try container.nestedUnkeyedContainer(forKey: .entries)
        var decodedEntries: [AppEntry] = []
        while !entriesContainer.isAtEnd {
            let entryData = try entriesContainer.decode(AppEntry.CodableRepresentation.self)
            decodedEntries.append(AppEntry(from: entryData))
        }
        entries = decodedEntries
    }
}

struct FolderArray: Encodable, Decodable {
    let values: [Folder]
}
