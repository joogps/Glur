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
                .ignoresSafeArea()
            
            TabView {
                gradient
                image
            }
            #if os(iOS)
            .tabViewStyle(.page)
            #endif
            .padding(.vertical)
        }
    }
    
    var gradient: some View {
        LinearGradient(colors: [Color("Color 1"), Color("Color 2"), Color("Color 3")], startPoint: .top, endPoint: .bottom)
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: 128)
            .clipShape(.rect(cornerRadius: 57/2))
            .padding(32)
            .background(Color("Black"))
            .glur(radius: 32.0, offset: 0.3, interpolation: 0.5)
    }
    
    var image: some View {
        Image("Sunburn")
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: 256)
            .glur(radius: 8.0, offset: 0.7, interpolation: 0.2, direction: .down)
            .overlay {
                LinearGradient(stops: [.init(color: .clear, location: 0.5), .init(color: .black.opacity(0.6), location: 0.8)], startPoint: .top, endPoint: .bottom)
            }
            .clipShape(.rect(cornerRadius: 12.0))
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading) {
                    Text("Sunburn")
                        .font(.headline)
                    Text("Dominic Fike")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
    }
}

#Preview {
    ContentView()
}
