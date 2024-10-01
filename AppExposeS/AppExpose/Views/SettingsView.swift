//
//  SettingsView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import SwiftUI

import Foundation

struct Folder: Identifiable, Equatable, Encodable, Decodable {
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

struct FolderListView: View {
    @EnvironmentObject var appData: AppData
    @Binding var selectedFolder: Folder?

    var body: some View {
        let _ = symlog.entry("FolderListView")
        List {
            ForEach(appData.appFolders) { folder in
                FolderRow(selectedFolder: $selectedFolder, folder: folder)
            }

            .onMove(perform: move)
            .onDelete { indexSet in
                appData.appFolders.remove(atOffsets: indexSet)
                SettingsManager.shared.setFolderArray(appData.appFolders, forKey: "folders")
            }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        var appFolders = appData.appFolders
        appFolders.move(fromOffsets: source, toOffset: destination)
    }
}

struct FolderRow: View {
    @EnvironmentObject var appData: AppData
    @Binding var selectedFolder: Folder?
    let folder: Folder

    var body: some View {
        let _ = symlog.entry("FolderRow \(folder.id)")
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
        .onChange(of: selectedFolder) { old,new in
            // Update the selected folder index
            if let newFolder = appData.appFolders.first(where: { $0.id == new?.id }) {
                selectedFolder = newFolder
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appData: AppData
    @State private var fileURL: URL?
    @State private var selectedFolder: Folder? = nil
    @State private var isPresented = false
    
    var body: some View {
        let _ = symlog.entry("SettingsView")
        Form {
            Section(header: Text("Application Folders")) {
                let _ = symlog.value("folders: \(appData.appFolders)")
                FolderListView(selectedFolder: $selectedFolder)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Delete") {
                            deleteSelectedFolder()
                        }
                        .disabled(selectedFolder == nil)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add") {
                            selectDir()
                        }
                    }
                }
                .padding([.leading, .trailing])
            }
            .padding([.top, .leading])
        }
        .onSubmit {
            self.update(url: fileURL)
        }
    }

    private func selectDir() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.begin { response in
            if response == .OK {
                let newurl = openPanel.url
                update(url: newurl)
            }
        }
    }

    private func update(url: URL?) {
        guard let aURL = url else { return }

        let folderName = aURL.lastPathComponent
        let folderURL = aURL

        // Check if a folder with the same name or URL already exists
        let isDuplicate = appData.appFolders.contains { folder in
            folder.url == folderURL
        }

        if !isDuplicate {
            let newFolder = Folder(id: appData.appFolders.count, name: folderName, url: folderURL)
            appData.appFolders.append(newFolder)
            SettingsManager.shared.setFolderArray(appData.appFolders, forKey: "folders")
            appData.appFolders = appData.appFolders // Force update
            self.selectedFolder = newFolder
        } else {
            // Optionally, you can show an alert or message to the user
            print("Folder already exists: \(folderName)")
        }
    }

    func deleteSelectedFolder() {
        if let selectedFolder = selectedFolder, let index = appData.appFolders.firstIndex(where: { $0.id == selectedFolder.id }) {
            appData.appFolders.remove(at: index)
            SettingsManager.shared.setFolderArray(appData.appFolders, forKey: "folders")
            appData.appFolders = appData.appFolders // Force update
            self.selectedFolder = nil
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
