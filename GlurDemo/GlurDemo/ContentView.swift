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
            
            gradient
        }
        .ignoresSafeArea()
    }
    
    var gradient: some View {
        LinearGradient(colors: [Color("Color 1"), Color("Color 2"), Color("Color 3")], startPoint: .top, endPoint: .bottom)
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: 128)
            .clipShape(.rect(cornerRadius: 57/2))
            .padding(32)
            .background(Color("Black"))
            .glur(offset: 0.3, interpolation: 0.4, radius: 24.0, direction: .down)
    }
    
    var image: some View {
        Image("red")
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: 256)
            .glur(offset: 0.1, interpolation: 0.4, radius: 8.0, direction: .up)
            .clipShape(.rect(cornerRadius: 12.0))
    }
}

#Preview {
    ContentView()
}
