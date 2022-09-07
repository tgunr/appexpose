//
//  SettingsView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import SwiftUI

struct AppFolder: Identifiable, Hashable {
    let id = UUID()
    let path: String
}

struct SettingsView: View {
    @AppStorage("itemsString") var appFolders = [""]
    @State var selectedItem: String? = nil
    var body: some View {
//        var folders = appFolders.map({ AppFolder(path: $0) })
        NavigationStack {
            List(selection: $selectedItem) {
                ForEach(appFolders, id: \.self) { Text($0) }
            }
            .onDeleteCommand(perform: ({
                if
                    let sel = self.selectedItem,
                    let idx = self.appFolders.firstIndex(of: sel) {
                    print("delete: \(sel)")
                    self.appFolders.remove(at: idx)
                }
            }))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.default, value: selectedItem)
        }
    }

    func deleteItemsID(offsets: IndexSet) {
    }
}

// struct SelectableRow: View {
//    var person: String
//
//    @Binding var selectedItems: Set<UUID>
//    var isSelected: Bool {
//        selectedItems.contains(person.id)
//    }
//
//    var body: some View {
//        GeometryReader { geo in
//            HStack {
//                Text(self.person.name).frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
//            }.background(self.isSelected ? Color.gray : Color.clear)
//            .tapAction {
//                if self.isSelected {
//                    self.selectedItems.remove(self.person.id)
//                } else {
//                    self.selectedItems.insert(self.person.id)
//                }
//            }
//        }
//    }
// }

struct SettingsView1: View {
    @AppStorage("itemsString") var appFolders = [""]
    @State private var location: String = ""

    var body: some View {
        VStack {
            Text("appFolders: \(String(describing: appFolders))")
//            ForEach(appFolders, content: loc in {
//                Text("loc: \(loc)")
//            })
//            List(appFolders) { loc in
//                Text("loc: \(loc)")
//            }
            Form {
                TextField("Location", text: $location, prompt: Text("enter application folder"))
            }
            Button("Add item") {
                appFolders.append(location)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
