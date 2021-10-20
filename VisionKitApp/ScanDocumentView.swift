//
//  ScanDocumentView.swift
//  VisionKitApp
//
//  Created by saj panchal on 2021-10-20.
//

import SwiftUI
import VisionKit
import UIKit
struct ScanDocumentView: UIViewControllerRepresentable {
    
    @Binding var recognizedText: String
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var recognizedText: Binding<String>
        var parent: ScanDocumentView
        
        init(recognizedText: Binding<String>, parent: ScanDocumentView) {
            self.recognizedText = recognizedText
            self.parent = parent
        }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // do the processing of the scan.
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self)
    }
    
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        //
    }
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    
    
}
