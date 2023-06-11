//
//  ContentView.swift
//  GlurApp
//
//  Created by João Gabriel Pozzobon dos Santos on 10/06/23.
//

import SwiftUI
import Glur

struct ContentView: View {
    var body: some View {
        Image(.red)
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .blur(offset: 0.5, interpolation: 0.1)
            .padding()
    }
}

#Preview {
    ContentView()
}
