//
//  ContentView.swift
//  AvatarViewer
//
//  Created by Richard Woollcott on 21/10/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            SceneKitView()
                .frame(height: 700) // Adjust as needed
            Text("Your 3D Avatar!")
        }
        .padding()
    }
}

/*
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}*/

#Preview {
    ContentView()
}
