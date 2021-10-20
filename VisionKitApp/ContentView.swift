//
//  ContentView.swift
//  VisionKitApp
//
//  Created by saj panchal on 2021-10-20.
//

import SwiftUI

struct ContentView: View {
    @State private var recognizedText = "Tap button to start scanning."
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.gray.opacity(0.2))
                    }
                    Text(recognizedText)
                        .padding()
                }
                .padding()
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // start scanning
                    }) {
                        Text("Start Scanning")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Capsule().fill(Color.blue))
                }
                .padding()
            }
            .navigationBarTitle("Text Recognizer")
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
