//
//  AppFolderDetailView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/19/24.
//
//
import SwiftUI
// AppFolderDetailView.swift
struct AppFolderDetailView: View {
    @Binding var entry: AppEntry
    @Binding var showDetailView: Bool
    @State private var selectMode: Bool = false
    @State private var customIcon: Image? = nil

    var body: some View {
        HStack {
            VStack {
                header
                scrollview
                tools
            }
            .frame(maxWidth: .infinity)

            // Sidebar for custom icon preview
            VStack {
                Text("Custom Icon Preview")
                    .font(.headline)
                    .padding()

                if let icon = customIcon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128, height: 128)
                        .padding()
                } else {
                    Text("No custom icon yet")
                        .foregroundColor(.gray)
                        .padding()
                }

                Button("Generate Icon") {
                    // Here you would implement the logic to generate the custom icon
                    // For now, we'll just set a placeholder image
                    customIcon = Image(systemName: "star.square.fill")
                }
                .padding()
            }
            .frame(width: 200)
            .background(Color.secondary.opacity(0.1))
        }
    }

    var header: some View {
        Group {
            Text(entry.name ?? "")
                .font(.title)
                .padding()
        }
        .toolbar {
            ToolbarItem(id: "selectModeToggle") {
                Toggle(isOn: $selectMode, label: {
                    Text(selectMode ? "Done" : "Select")
                })
            }
        }
    }

    var scrollview: some View {
        ScrollView {
            LazyHStack {
                ForEach(entry.children.indices, id: \.self) { index in
                    HStack {
                        EntryView(entry: entry.children[index], selectMode: $selectMode)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    var tools: some View {
        Group {
            if selectMode {
                HStack {
                    Button("Select Entries") {
                        toggleSelect()
                    }
                }
            }
        }
    }

    func toggleSelect() {
        selectMode.toggle()
    }
}

struct EntryView: View {
    @ObservedObject var entry: AppEntry
    @Binding var selectMode: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                if let appImage = entry.appImage {
                    Image(nsImage: appImage)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .aspectRatio(contentMode: .fit)
                }
                Text(entry.name ?? "")
            }
            .padding()
            .onTapGesture {
                if selectMode {
                    entry.isSelected.toggle()
                    if entry.isSelected {
                        symlog.info("EntryView: isSelected is true")
                    } else {
                        symlog.info("EntryView: isSelected is false")
                    }
                }
            }
            if entry.isSelected {
                Star()
                    .padding(5)
            }
        }
    }
}

struct Star: View {
    var color = Color.blue
    var body: some View {
        Image(systemName: "star.fill")
            .foregroundStyle(color)
            .frame(width: 30, height: 30)
    }
}

// Preview Configuration
struct AppFolderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        @State var entry = AppEntry(withURL: URL(fileURLWithPath: "/Users/davec/Applications/WebApps"))
        @State var showDetailView = true
        entry.isSelected = true
        return AppFolderDetailView(entry: $entry, showDetailView: $showDetailView)
    }
}
