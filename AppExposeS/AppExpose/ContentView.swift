//
//  ContentView.swift
//  AppExpose
//
//  Created by Dave Carlton on 8/21/22.
//

import SwiftUI

struct TopBarView: View {
    @State private var val: Double = 0.7
    @State private var bold = true
    @State private var italic = false
        
    var body: some View {
        NavigationView {
            VStack {
                Text("Application Folders")
                List {
                    Text("Folder")
                    Text("Folder")
                    Text("Folder")
                    Text("Folder")
                    Text("Folder")
                    Text("Folder")
                }
            }
        }
                .toolbar(content: {
                    Text("Offline").foregroundColor(.red)
                    
                    Button(action: connect, label: { Image(systemName: "network") })
                    
                    Slider(value: $val, in: 0...1, label: { Text("Volume")})
                        .frame(width: 200)
                    
                    Toggle(isOn: $bold, label: { Text("B").fontWeight(.heavy) })
                    
                    Toggle(isOn: $italic, label: { Text("I").italic() })
                })
                .navigationTitle("My Application")
            
        }
    
    func connect() {
        
    }
}

struct ContentView: View {
    var body: some View {
            TopBarView()
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView()
    }
}
