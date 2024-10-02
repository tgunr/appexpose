//
//  ContentView.swift
//  AppExpose
//
//  Created by Dave Carlton on 8/21/22.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appData: AppData
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            AppFoldersView()
                .tag(0)
            SettingsView()
                .tag(1)
            HelpView()
                .tag(2)
        }
        .tabViewStyle(.automatic)

        FloatingTabBar(selectedTab: $selectedTab)
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let items: [BottomBarItem] = [
        BottomBarItem(icon: "folder", title: "Applications", color: .purple),
        BottomBarItem(icon: "gear", title: "Settings", color: .purple),
        BottomBarItem(icon: "questionmark.circle", title: "Help", color: .pink),
        BottomBarItem(icon: "magnifyingglass", title: "Search", color: .orange),
    ]

    var body: some View {
        HStack {
            ForEach(0 ..< items.count) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    HStack {
                        Image(systemName: items[index].icon)
                            .foregroundColor(index == selectedTab ? items[index].color : .gray)
                        if index == selectedTab {
                            Text(items[index].title)
                                .foregroundColor(items[index].color)
                                .transition(.slide)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        .padding(.horizontal)
    }
}

struct BottomBarItem {
    let icon: String
    let title: String
    let color: Color
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData.shared)
    }
}
