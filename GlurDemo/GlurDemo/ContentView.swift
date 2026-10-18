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
    @State private var transparentRadius = 12.0
    @State private var transparentMaskIndex = 0
    @State private var transparentNoise = false
    @State private var transparentDrawingGroup = true

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

                transparentContent
                    .tabItem {
                        Label("Transparency", systemImage: "circle.dashed")
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
    
    /// Transparent padding must remain available to both blur passes. Without
    /// their declared sample reach, the halo ends at the stroke's square bounds.
    var transparentContent: some View {
        VStack(spacing: 16) {
            Circle()
                .strokeBorder(AngularGradient(colors: [.orange.opacity(0), .orange, .white],
                                              center: .center), lineWidth: 10)
                .frame(width: 96, height: 96)
                .padding(32)
                .glur(radius: transparentRadius,
                      mask: transparentMask,
                      noise: transparentNoise ? 0.1 : 0,
                      drawingGroup: transparentDrawingGroup)
                .mask {
                    // Fade only the 45° at the end of the blurred tail.
                    // Applied after the blur, this suppresses light sampled
                    // from the sharp tip without smoothing its discontinuity.
                    AngularGradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .white.opacity(0.15), location: 22.5 / 360),
                        .init(color: .white, location: 45.0 / 360),
                        .init(color: .white, location: 1)
                    ], center: .center)
                }
                .frame(width: 220, height: 220)
                .background(Color.white.opacity(0.05))

            Picker("Mask", selection: $transparentMaskIndex) {
                Text("Angular").tag(0)
                Text("Linear").tag(1)
                Text("Radial").tag(2)
            }
            .pickerStyle(.segmented)

            Text("Radius: \(transparentRadius, specifier: "%.1f")")
            Slider(value: $transparentRadius, in: 0...32)
            Toggle("Noise", isOn: $transparentNoise)
            Toggle("Drawing group", isOn: $transparentDrawingGroup)
        }
        .padding()
        .frame(maxWidth: 360)
    }

    private var transparentMask: GlurMask {
        switch transparentMaskIndex {
        case 1: return .linear()
        case 2: return .radial()
        default:
            return .view(AngularGradient(colors: [.black, .clear], center: .center))
        }
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
