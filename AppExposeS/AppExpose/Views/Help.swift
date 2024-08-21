//
//  WelcomeView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        HStack {
            Text("""
                 Use AppExpose to enhance your application folders. Plain folders used to organize your application can display up to 9 applications found in the contents of the folder.
                 """)
            .font(.body)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .padding([.top, .leading, .trailing])
        .frame(width: 600.0)
        }
        Spacer()
    }
}

struct Help_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
