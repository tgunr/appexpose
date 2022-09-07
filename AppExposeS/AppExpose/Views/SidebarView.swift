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
    var body: some View {
        NavigationView {
            List {
                Text("LOCATIONS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                    AppFoldersViews()
                Divider()
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }

                Divider()
                NavigationLink(destination: HelpView()) {
                    Label("Help", systemImage: "gear.badge.questionmark")
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
