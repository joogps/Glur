//
//  ContentView.swift
//  GlurDemo
//
//  Created by João Gabriel Pozzobon dos Santos on 10/06/23.
//

import SwiftUI
import Glur
import GlurBackdrop

struct ContentView: View {
    var body: some View {
        ZStack {
            Color("Black")
                .ignoresSafeArea()
            
            TabView {
                icon
                    .tabItem {
                        Label("Icon", systemImage: "star")
                    }
                
                albumCover
                    .tabItem {
                        Label("Album", systemImage: "photo")
                    }

                scroll
                    .tabItem {
                        Label("Backdrop", systemImage: "square.stack")
                    }
            }
            #if os(iOS)
            .tabViewStyle(.page)
            #else
            .padding()
            #endif
            .padding(.vertical)
        }
        .preferredColorScheme(.dark)
    }
    
    var icon: some View {
        LinearGradient(colors: [Color("Color 1"), Color("Color 2"), Color("Color 3")], startPoint: .top, endPoint: .bottom)
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: 128)
            .clipShape(.rect(cornerRadius: 57/2))
            .padding(32)
            .background(Color("Black"))
            .glur(radius: 32.0, offset: 0.3, interpolation: 0.5)
    }
    
    /// A `ScrollView` is backed by the platform, so the shader can't be applied to it.
    /// `GlurView` sits on top instead, blurring whatever scrolls underneath.
    var scroll: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<12) { index in
                    LinearGradient(colors: [Color("Color 1"), Color("Color 3")],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                    .frame(height: 72)
                    .clipShape(.rect(cornerRadius: 12.0))
                    .overlay(alignment: .leading) {
                        Text("Row \(index)")
                            .font(.headline)
                            .padding()
                    }
                }
            }
            .padding()
        }
        .overlay(alignment: .top) {
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
                GlurView(radius: 12.0, offset: 0.0, interpolation: 1.0, direction: .up)
                    .frame(height: 120)
            }
        }
    }

    var albumCover: some View {
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
