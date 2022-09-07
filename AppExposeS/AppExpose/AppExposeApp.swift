//
//  AppExposeApp.swift
//  AppExpose
//
//  Created by Dave Carlton on 8/21/22.
//

import AppKit
import SwiftUI

class appData: NSObject, ObservableObject {
    static let shared = appData()
    @Published var folders = Array<String>()
    var progress: Progress?
    override init() {
    }
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @EnvironmentObject private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ToolbarView()
            SidebarView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(appData.shared)
        }
//        Settings {
//            PreferencesView(model: model)
//        }
//        }.commands {
        // This is optional, but adds menu items for toolbar customization
//            ToolbarCommands()
//        }
    }
}

struct ToolbarView: View {
    @State private var size: Double = 0.7
    @State private var bold = true
    @State private var remove = false
    @State private var selectAll = false
    var body: some View {
        Text("Top")
//        Color.clear
            .toolbar(id: "mytb") {
                ToolbarItem(id: "before", placement: .automatic) {
                    Button(action: before, label: {
                        Text("Before")
                        Image(systemName: "arrowshape.turn.up.left.circle.fill")
                    })
                }

                ToolbarItem(id: "after", placement: .automatic) {
                    Button(action: after, label: {
                        Text("After")
                        Image(systemName: "arrowshape.turn.up.right.circle.fill")
                    })
                }

                ToolbarItem(id: "size", placement: .automatic) {
                    Slider(value: $size, in: 0 ... 1, label: { Text("Size") })
                        .frame(width: 100)
                }

                ToolbarItem(id: "apply", placement: .automatic) {
                    Toggle(isOn: $bold, label: {
                        Image(systemName: "square.and.arrow.down.on.square.fill")
                        Text("Apply").fontWeight(.heavy)
                    })
                }

                ToolbarItem(id: "remove", placement: .automatic) {
                    Toggle(isOn: $remove, label: {
                        Image(systemName: "trash")
                        Text("Remove").italic()
                    })
                }
                ToolbarItem(id: "selectAll", placement: .automatic) {
                    Toggle(isOn: $selectAll, label: {
                        Image(systemName: "filemenu.and.selection")
                        Text("Select All").italic()
                    })
                }
            }
            .navigationTitle("Application Folders")
    }

    func before() {
    }

    func after() {
    }
}

func before() {
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ToolbarView()
        }
        .toolbar(id: "mytb") {
            ToolbarItem(id: "before", placement: .automatic) {
                Button(action: before, label: {
                    Text("Before")
                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
                })
            }
        }
    }
}
