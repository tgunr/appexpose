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
                Group {
                    AppFoldersViews()
                }

                Text("SETTINGS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                Group {
                    NavigationLink(destination: SettingsView()) {
                        Label("Add Location", systemImage: "gear")
                    }
                }
                
                Divider()
                NavigationLink(destination: WelcomeView()) {
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
