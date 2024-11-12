//
//  Extensions.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import Foundation

// https://stackoverflow.com/questions/62562534/swiftui-what-is-appstorage-property-wrapper/62563773#62563773
extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

//struct ContentView: View {
//    @AppStorage("itemsInt") var itemsInt = [1, 2, 3]
//    @AppStorage("itemsBool") var itemsBool = [true, false, true]
//
//    var body: some View {
//        VStack {
//            Text("itemsInt: \(String(describing: itemsInt))")
//            Text("itemsBool: \(String(describing: itemsBool))")
//            Button("Add item") {
//                itemsInt.append(Int.random(in: 1...10))
//                itemsBool.append(Int.random(in: 1...10).isMultiple(of: 2))
//            }
//        }
//    }
//}
