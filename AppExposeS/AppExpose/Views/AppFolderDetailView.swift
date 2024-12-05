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
    var body: some View {
        VStack {
            header
                .toolbar {
                    ToolbarItem(id: "selectModeToggle") {
                        Toggle(isOn: $selectMode, label: {
                            Text(selectMode ? "Done" : "Select") // Update text based on state
                        })
                    }
                }
            scrollview
        }
    }

    var header: some View {
        Text(entry.name ?? "")
            .font(.title)
            .padding()
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
                        .aspectRatio(contentMode: .fit)
                }
                Text(entry.name ?? "")
            }
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
