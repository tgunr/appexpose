//
//  SettingsView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import SwiftUI

import Foundation

struct StringArray: Encodable, Decodable{
    let values: [String]
}

class SettingsManager {
    let defaults = UserDefaults.standard
    static let shared = SettingsManager()

    func setStringArray(_ array: [String], forKey key: String) {
        let stringArray = StringArray(values: array)
        if let data = try? JSONEncoder().encode(stringArray) {
            if let string = String(data: data, encoding: .utf8) {
                defaults.set(string, forKey: key)
            }
        }
    }
    
    func getStringArray(forKey key: String) -> [String]? {
        guard let string = defaults.string(forKey: key) else { return nil }
        do {
            guard let data = string.data(using: .utf8) else { return nil }
            let stringArray = try JSONDecoder().decode(StringArray.self, from: data)
            return stringArray.values
        } catch {
            symlog.error("Error parsing JSON: \(error)")
            return nil
        }
    }
}

struct SettingsView: View {
    @State private var fileURL: URL?

    var body: some View {
        let _ = symlog.info("SettingsView")
        Form {
            Section(header: Text("Application Folders")) {
                ForEach(AppData.shared.folders, id: \.self) { folder in
                    Text(folder)
                }
                Spacer()
                HStack(alignment: .firstTextBaseline) {
                    Text("Location:")
                    DirectorySelectorView(url: self.$fileURL)
                        .onChange(of: fileURL) { oldValue, newValue in
                            update(url: newValue)
                        }
                }
            }
        }
        .onSubmit {
            self.update(url: fileURL)
        }
    }

    func update(url: URL?) {
        if let aURL = url {
//            let thePrefix = "file://"
//            let path = aURL.absoluteString.replacingOccurrences(of: thePrefix, with: "")
            AppData.shared.folders.append(aURL.path)
            SettingsManager.shared.setStringArray(AppData.shared.folders, forKey: "folders")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
