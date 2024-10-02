//
//  Folder.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/2/24.
//


struct Folder: Identifiable, Equatable, Codable, Hashable {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url.absoluteString, forKey: .url)
        try container.encode(entries, forKey: .entries)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let urlString = try container.decode(String.self, forKey: .url)
        url = URL(string: urlString)!
        entries = try container.decode([AppEntry].self, forKey: .entries)
    }
}

struct FolderArray: Encodable, Decodable {
    let values: [Folder]
}

