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
    @StateObject private var appData = AppData.shared
    @State private var fileURL: URL?
    @State private var selectedFolder: Folder? = nil
    @State private var isPresented = false
    
    func update(url: URL?) {
        guard let aURL = url else { return }

        let folderName = aURL.lastPathComponent
        let folderURL = aURL

        // Check if a folder with the same name or URL already exists
        let isDuplicate = appData.folders.contains { folder in
            folder.name == folderName || folder.url == folderURL
        }

        if !isDuplicate {
            let newFolder = Folder(id: AppData.shared.folders.count, name: folderName, url: folderURL)
            appData.folders.append(newFolder)
            SettingsManager.shared.setFolderArray(appData.folders, forKey: "folders")
        } else {
            // Optionally, you can show an alert or message to the user
            print("Folder already exists: \(folderName)")
        }
    }

    func deleteSelectedFolder() {
        if let selectedFolder = selectedFolder, let index = appData.folders.firstIndex(where: { $0.id == selectedFolder.id }) {
            appData.folders.remove(at: index)
            SettingsManager.shared.setFolderArray(appData.folders, forKey: "folders")
            self.selectedFolder = nil
        }
    }

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
                    ForEach(appData.folders) { folder in
                        HStack {
                            Text(folder.name)
                                .frame(width: 150, alignment: .leading)
                            Text(folder.url.path)
                        }
                        .contentShape(Rectangle())
                        .background(selectedFolder?.id == folder.id ? Color.blue.opacity(0.3) : Color.clear)
                        .onTapGesture {
                            selectedFolder = folder
                        }
                    }
                    .onDelete { indexSet in
                        AppData.shared.folders.remove(atOffsets: indexSet)
                        SettingsManager.shared.setFolderArray(AppData.shared.folders, forKey: "folders")
                    }
                }

                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Delete") {
                            deleteSelectedFolder()
                        }
                        .disabled(selectedFolder == nil)
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
