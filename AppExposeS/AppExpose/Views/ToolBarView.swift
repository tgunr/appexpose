//
//  ToolBarView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import SwiftUI

struct ToolbarView: View {
//    @EnvironmentObject var appData: AppData
    @State var iconSize: Double = 32.0
    var body: some View {
        NavigationStack {
            //        Color.clear
        }
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
                Slider(value: $iconSize, in: 16 ... 256, step: 16)
//                    .frame(width: 100)
            }

//            ToolbarItem(id: "apply", placement: .automatic) {
//                Toggle(isOn: appData.$bold, label: {
//                    Image(systemName: "square.and.arrow.down.on.square.fill")
//                    Text("Apply").fontWeight(.heavy)
//                })
//            }
//
//            ToolbarItem(id: "remove", placement: .automatic) {
//                Toggle(isOn: appData.$remove, label: {
//                    Image(systemName: "trash")
//                    Text("Remove").italic()
//                })
//            }
//            ToolbarItem(id: "selectAll", placement: .automatic) {
//                Toggle(isOn: appData.$selectAll, label: {
//                    Image(systemName: "filemenu.and.selection")
//                    Text("Select All").italic()
//                })
//            }
        }
        .navigationTitle("Application Folders")
    }
}

func before() {
}

func after() {
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationView {
            ContentView()
//        }
        .toolbar(id: "mytb") {
            ToolbarItem(id: "before", placement: .automatic) {
                Button(action: before, label: {
                    Text("Before")
                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
                })
            }
        }

//            .toolbar(id: "mytb") {
//            ToolbarItem(id: "before", placement: .automatic) {
//                Button(action: before, label: {
//                    Text("Before")
//                    Image(systemName: "arrowshape.turn.up.left.circle.fill")
//                })
//            }
//        }
    }
}
