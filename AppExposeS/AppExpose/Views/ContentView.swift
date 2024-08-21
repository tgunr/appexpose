//
//  ContentView.swift
//  AppExpose
//
//  Created by Dave Carlton on 8/21/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("itemsString") var appFolders = [""]
    @State var selectedItem: String? = nil

    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack {
                Form {
                    List(selection: $selectedItem) {
                        ForEach(appFolders, id: \.self) {
                            let fname = $0
                            HStack {
                                Text(fname)
                            }
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
            }
        }
    }
    
    func connect() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
