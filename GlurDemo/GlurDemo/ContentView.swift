//
//  ContentView.swift
//  GlurDemo
//
//  Created by João Gabriel Pozzobon dos Santos on 10/06/23.
//

import SwiftUI
import Glur

struct ContentView: View {
    var body: some View {
        ZStack {
            Color("Black")
            
            LinearGradient(colors: [Color("Color 1"), Color("Color 2"), Color("Color 3")], startPoint: .top, endPoint: .bottom)
                .aspectRatio(1.0, contentMode: .fit)
                .frame(width: 128)
                .clipShape(.rect(cornerRadius: 57/2))
                .padding(32)
                .background(Color("Black"))
                .drawingGroup()
                .glur(offset: 0.3, interpolation: 0.3, radius: 24.0)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
