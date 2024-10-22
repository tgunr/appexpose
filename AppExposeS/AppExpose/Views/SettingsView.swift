//
//  SettingsView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import SwiftUI

import Foundation

class SettingsManager {
    let defaults = UserDefaults.standard
    @MainActor static let shared = SettingsManager()
    
    func setFolderArray(_ array: [Folder], forKey key: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys // This ensures consistent encoding order
        
        if let data = try? encoder.encode(array) {
            defaults.set(data, forKey: key)
        }
    }
    
    func getFolderArray(forKey key: String) -> [Folder]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([Folder].self, from: data)
    }
}

struct FolderListView: View {
    @EnvironmentObject var appData: AppData
    @Binding var selectedFolder: Folder?

    var body: some View {
//        let _ = symlog.entry("FolderListView folders: \(appData.appFolders)")
        List(selection: $selectedFolder) {
            ForEach(appData.appFolders) { folder in
//                let _ = symlog.value("folder: \(folder)")
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
            symlog.info("FolderRow: tapped")
            selectedFolder = folder
        }
        .onChange(of: selectedFolder) { _, new in
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
    @FocusState private var isFocused: Bool

    var body: some View {
        let _ = symlog.entry("\(#function)• SettingsView")
        Form {
            Section(header: Text("Application Folders")) {
                ZStack {
                    FolderListView(selectedFolder: $selectedFolder)
                        .focused($isFocused)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button(action: {
                                    moveUp()
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.up")
                                    }
                                }
                                .disabled(selectedFolder == nil)
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button(action: {
                                    moveDown()
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.down")
                                    }
                                }
                                .disabled(selectedFolder == nil)
                            }
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
            }
            .padding([.top, .leading])
        }
        .onTapGesture {
            symlog.info("SettingsView: tapped")
            selectedFolder = nil
        }
        .onSubmit {
            self.update(url: fileURL)
        }
    }

    private func moveDown() {
        guard let selectedFolder else { return }
        guard let index = appData.appFolders.firstIndex(where: { $0.id == selectedFolder.id }),
              index < appData.appFolders.count - 1 else { return }
        appData.appFolders.swapAt(index, index + 1)
        SettingsManager.shared.setFolderArray(appData.appFolders, forKey: "folders")
    }

    private func moveUp() {
        guard let selectedFolder else { return }
        guard let index = appData.appFolders.firstIndex(where: { $0.id == selectedFolder.id }),
              index > 0 else { return }
        appData.appFolders.swapAt(index, index - 1)
        SettingsManager.shared.setFolderArray(appData.appFolders, forKey: "folders")
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
//            let _ = symlog.value("folders count: \(appData.appFolders.count)")
            let newFolder = Folder(id: UUID(), name: folderName, url: folderURL, entries: [])
//            let _ = symlog.value("folders old: \(appData.appFolders)")
            appData.appFolders.append(newFolder)
//            let _ = symlog.value("folders new: \(appData.appFolders)")
            SettingsManager.shared.setFolderArray(appData.appFolders, forKey: "folders")
//            appData.appFolders = appData.appFolders // Force update
            selectedFolder = newFolder
        } else {
//            appData.appFolders = appData.appFolders // Force update
            print("Folder already exists: \(folderName)")
        }
    }

    func deleteSelectedFolder() {
        if let selectedFolder = selectedFolder, let index = appData.appFolders.firstIndex(where: { $0.id == selectedFolder.id }) {
            appData.appFolders.remove(at: index)
            SettingsManager.shared.setFolderArray(appData.appFolders, forKey: "folders")
//            appData.appFolders = appData.appFolders // Force update
            self.selectedFolder = nil
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
