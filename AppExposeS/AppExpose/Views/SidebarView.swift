//
//  SidebarView.swift
//  SimpleSidebarUI
//
//  Created by Justin Bush on 2021-03-03.
//
//  Reference
//  https://github.com/1998code/SwiftUI2-MacSidebar
//

import SwiftUI

struct SidebarView: View {
    @AppStorage("itemsString") var appFolders = [""]
    @State var selectedItem: String? = nil
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: WelcomeView()) {
                    Label("Welcome", systemImage: "star")
                }

                Spacer()

                Text("LOCATIONS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                Group {
                    ForEach(appFolders, id: \.self) {
                        let fname = $0
                        NavigationLink(destination: ContentView()) {
                            Label(fname, systemImage: "folder")
                        }
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

                Spacer()

                Text("SETTINGS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                Group {
//                    NavigationLink(destination: ContentView()) {
//                        Label("Notifications", systemImage: "bell")
//                    }
                    NavigationLink(destination: SettingsView()) {
                        Label("Add Location", systemImage: "gear")
                    }
                }

                Spacer()

                Divider()
                NavigationLink(destination: ContentView()) {
                    Label("Sign Out", systemImage: "arrow.backward")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Explore")
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }

            ContentView()
        }
    }
}

// Toggle Sidebar Function
func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
