//
//  RemoteImageView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/6/24.
//


import RemoteImage
import SwiftUI

struct RemoteImageView: View {
    let url: URL

    var body: some View {
        RemoteImage(type: .url(url)) { error in
            Text(error.localizedDescription)
        } imageView: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } loadingView: {
            Text("Loading ...")
        }
    }
}
