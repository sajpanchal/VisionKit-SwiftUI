//
//  ContentView.swift
//  VisionKitApp
//
//  Created by saj panchal on 2021-10-20.
//

import SwiftUI

struct ContentView: View {
    @State private var recognizedText = "Tap button to start scanning."
    @State private var showingScanningView = false
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
                        self.showingScanningView = true
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
            .sheet(isPresented: $showingScanningView) {
                ScanDocumentView(recognizedText: $recognizedText)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
