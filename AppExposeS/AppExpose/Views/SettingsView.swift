//
//  SettingsView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import SwiftUI

import Foundation

struct Folder: Identifiable, Encodable, Decodable {
    let id: Int
    var name: String
    var url: URL
}

struct FolderArray: Encodable, Decodable {
    let values: [Folder]
}

class SettingsManager {
    let defaults = UserDefaults.standard
    static let shared = SettingsManager()

    func setFolderArray(_ array: [Folder], forKey key: String) {
        let stringArray = FolderArray(values: array)
        if let data = try? JSONEncoder().encode(stringArray) {
            if let string = String(data: data, encoding: .utf8) {
                defaults.set(string, forKey: key)
            }
        }
    }

    func getFolderArray(forKey key: String) -> [Folder]? {
        guard let string = defaults.string(forKey: key) else { return nil }
        do {
            guard let data = string.data(using: .utf8) else { return nil }
            let stringArray = try JSONDecoder().decode(FolderArray.self, from: data)
            return stringArray.values
        } catch {
            symlog.error("Error parsing JSON: \(error)")
            return nil
        }
    }
}

struct SettingsView: View {
    @State private var fileURL: URL?
    @State private var folders: [Folder] = AppData.shared.folders
    @State private var selectedFolder: Folder? = nil

    var body: some View {
        let _ = symlog.info("SettingsView")
        Form {
            Section(header: Text("Application Folders")) {
                List {
                    HStack {
                        Text("Name")
                            .frame(width: 150, alignment: .leading)
                        Text("URL")
                    }
                    ForEach($folders, editActions: [.move, .delete]) { folder in
                        HStack {
                            Text(folder.name.wrappedValue)
                                .frame(width: 150, alignment: .leading)
                            Text(folder.url.wrappedValue.path)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFolder = folder.wrappedValue
                        }
                    }
                    .onDelete { indexSet in
                            folders.remove(atOffsets: indexSet)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Delete") {
                            self.fileURL = nil
                        }
                    }
                    ToolbarItem {
                        Button("Edit") {
                            self.fileURL = nil
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            self.folders = AppData.shared.folders
                        }
                    }
                }
                .padding([.leading, .trailing])
                Spacer()
                HStack(alignment: .firstTextBaseline) {
                    Text("Location:")
                    DirectorySelectorView(url: self.$fileURL)
                        .onChange(of: fileURL) { _, newValue in
                            update(url: newValue)
                        }
                }
            }
            .padding([.top, .leading])
        }
        .onSubmit {
            self.update(url: fileURL)
        }
    }

    func update(url: URL?) {
        if let aURL = url {
            let folder = Folder(id: AppData.shared.folders.count, name: aURL.lastPathComponent, url: aURL)
            AppData.shared.folders.append(folder)
            SettingsManager.shared.setFolderArray(AppData.shared.folders, forKey: "folders")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
