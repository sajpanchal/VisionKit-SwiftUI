//
//  ScanDocumentView.swift
//  VisionKitApp
//
//  Created by saj panchal on 2021-10-20.
//

import SwiftUI
import VisionKit
import UIKit
import Vision
struct ScanDocumentView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedText: String
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var recognizedText: Binding<String>
        var parent: ScanDocumentView
        
        init(recognizedText: Binding<String>, parent: ScanDocumentView) {
            self.recognizedText = recognizedText
            self.parent = parent
        }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let extractedImages =  extractImages(from: scan)
            let processedText = recognizeText(from: extractedImages)
            recognizedText.wrappedValue = processedText
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            var extractedImages = [CGImage]()
            for index in 0..<scan.pageCount {
                let extractedImage = scan.imageOfPage(at: index)
                guard let cgImage = extractedImage.cgImage else {
                    continue
                }
                extractedImages.append(cgImage)
            }
            return extractedImages
        }
        
        func recognizeText(from images: [CGImage]) -> String {
            var entireRecognizedText = ""
            let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
                guard error == nil else {
                    return
                }
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                let maximumRecognitionCandidates = 1
                for observation in observations {
                    guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else {
                        continue
                    }
                    entireRecognizedText += "\(candidate.string)"
                }
            }
            recognizeTextRequest.recognitionLevel = .accurate
            for image in images {
                let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
                try? requestHandler.perform([recognizeTextRequest])
            }
            let formattedDate = getFormattedDate(subString: entireRecognizedText)
            
            return formattedDate
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

func getFormattedDate(subString: String) -> String {
    var subString = subString
    var formattedDate = "error"
    var patternArray = [#"^EXP(.| |/|-|)[0-9]{2}(.| |/|-|)[0-9]{2}$"#,//0
                        #"^EXP(.| |\/|-|)[0-9]{4}(.| |\/|-|)[0-9]{2}$"#,//1
                        #"^EXP(.| |\/|-|)[0-9]{2}(.| |\/|-|)[0-9]{4}$"#,//2
                        #"^EXP(.| |\/|-|)(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(.| |\/|-|)[0-9]{4}$"#,//3
                        #"^EXP(.| |\/|-|)(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(.| |\/|-|)[0-9]{4}$"#,//4
                        #"^EXP(.| |\/|-|)(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(.| |\/|-|)[0-9]{4}$"#,//5
                        #"^BB(.| |\/|-|)[0-9]{2}(.| |\/|-|)[0-9]{4}$"#,//6
                        #"^BB(.| |\/|-|)(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(.| |\/|-|)[0-9]{4}$"#,//7
                        #"^BB(.| |\/|-|)(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(.| |\/|-|)[0-9]{4}$"#,//8
                        #"^BB(.| |\/|-|)(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(.| |\/|-|)[0-9]{4}$"#,//9
                        #"^[0-9]{2}(.| |\/|-|)(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(.| |\/|-|)[0-9]{4}$"#,//10
                        #"^[0-9]{2}(.| |\/|-|)(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(.| |\/|-|)[0-9]{4}$"#,//11
                        #"^[0-9]{2}(.| |\/|-|)(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(.| |\/|-|)[0-9]{4}$"#,//12
                        #"^[0-9]{2}(.| |\/|-|)(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(.| |\/|-|)[0-9]{2}$"#,//13
                        #"^[0-9]{2}(.| |\/|-|)(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(.| |\/|-|)[0-9]{2}$"#,//14
                        #"^[0-9]{2}(.| |\/|-|)(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(.| |\/|-|)[0-9]{2}$"#,//15
                        #"^[0-9]{4}(.| |\/|-|)(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(.| |\/|-|)[0-9]{2}$"#,//16
                        #"^[0-9]{4}(.| |\/|-|)(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(.| |\/|-|)[0-9]{2}$"#,//17
                        #"^[0-9]{4}(.| |\/|-|)(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(.| |\/|-|)[0-9]{2}$"#,//18
                        #"^[0-9]{4}(.| |\/|-|)[0-1][0-9](.| |\/|-|)[0-9]{2}$"#,//19
                        #"^[0-1][0-9](.| |\/|-|)[0-9]{2}(.| |\/|-|)[0-9]{4}$"#,//20
                        #"^[0-1][0-9](.| |\/|-|)[0-9]{2}(.| |\/|-|)[0-9]{2}$"#,//21
                        #"^(JA|FE|MR|AP|AL|MY|MA|JU|JN|JL|AU|SE|OC|NO|NV|DE)(.| |/|-|)[0-9]{2}$"#,//22
                        #"^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|SEPT|OCT|NOV|DEC)(.| |/|-|)[0-9]{2}$"#,//23
                        #"^(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)(.| |/|-|)[0-9]{2}$"#,//24
                        
    ]
  
    var counter = 0
    for pattern in patternArray {
        subString = subString.replacingOccurrences(of: ". ", with: ".")
        subString = subString.replacingOccurrences(of: "- ", with: "-")
        subString = subString.replacingOccurrences(of: "/ ", with: "/")
        
        let regex = try! NSRegularExpression(pattern: pattern)
        if findSubString(regex: regex, subString: subString) != "" {
            let dateStr = findSubString(regex: regex, subString: subString)
           // let dateformatter = DateFormatter()
            var dt = dateStr.split {[".","/"," "].contains($0)}
            dt.removeAll(where: { i in
                if Int(i) == nil {
                    switch i.uppercased() {
                    case "JA","FE","MA","AP","MY","JU","JL","AU","SE","OC","NO","DE":
                        return false
                    case "EXP", "BB","EXPY", "BEST BEFORE" :
                        return true
                    default:
                        return false
                    }
                }
                else {
                    return false
                }
            })
            
            print(dt)
            var newdt: [String] = dt.map { i -> String in
                switch i.uppercased() {
                case "JA","JAN","JANUARY":
                    return "01"
                case "FE","FEB","FEBRUARY":
                    return "02"
                case "MR","MAR","MARCH":
                    return "03"
                case "AP","AL","APR","APRIL":
                    return "04"
                case "MY","MA","MAY":
                    return "05"
                case "JN","JU","JUN","JUNE":
                    return "06"
                case "JL","JUL","JULY":
                    return "07"
                case "AU","AUG","AUGUST":
                    return "08"
                case "SE","SEP","SEPT","SEPTEMBER":
                    return "09"
                case "OC","OCT","OCTOBER":
                    return "10"
                case "NO", "NV","NOV","NOVEMBER":
                    return "11"
                case "DE","DEC","DECEMBER":
                    return "12"
                default:
                    return String(i)
                }
                
            }
         
            print("array item index: \(counter)")
            if newdt.count == 2 {
                newdt.insert("01", at: 0)
            }
            print(newdt)
            let ddmmyy = arrangeDateArray(dateArr: newdt, counter: counter)
            let myYear: Int = ddmmyy[2]
            let myMonth: Int = ddmmyy[1]
            let myDay: Int = ddmmyy[0]
          let currDate = getMyDate(year: myYear, month: myMonth, day: myDay)
            print(currDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            formattedDate = dateFormatter.string(from: currDate)
            print("formatted date:\(formattedDate)")
            
            break
        }
        counter += 1
    }
     return formattedDate
}


func arrangeDateArray(dateArr:[String], counter: Int) -> [Int]{
    var ddmmyy:[Int] = [00,00,00]
    switch counter {
    case 0:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 1:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[2])!
        ddmmyy[2] = Int(dateArr[1])!
        return ddmmyy
    case 2:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 3:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 4:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 5:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 6:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 7:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 8:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 9:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 10:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 11:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 12:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 13:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 14:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 15:
        ddmmyy[0] = Int(dateArr[0])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 16:
        ddmmyy[0] = Int(dateArr[2])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[0])!
        return ddmmyy
    case 17:
        ddmmyy[0] = Int(dateArr[2])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[0])!
        return ddmmyy
    case 18:
        ddmmyy[0] = Int(dateArr[2])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[0])!
        return ddmmyy
    case 19:
        ddmmyy[0] = Int(dateArr[2])!
        ddmmyy[1] = Int(dateArr[1])!
        ddmmyy[2] = Int(dateArr[0])!
        return ddmmyy
    case 20:
        ddmmyy[0] = Int(dateArr[1])!
        ddmmyy[1] = Int(dateArr[0])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 21:
        ddmmyy[0] = Int(dateArr[1])!
        ddmmyy[1] = Int(dateArr[0])!
        ddmmyy[2] = Int(dateArr[2])!
        return ddmmyy
    case 22:
        ddmmyy[0] = Int(dateArr[2])!
        ddmmyy[1] = Int(dateArr[1])!
        let components = Calendar.current.dateComponents([.year], from: Date())
        ddmmyy[2] = (components.year)!
        return ddmmyy
    case 23:
        ddmmyy[0] = Int(dateArr[2])!
        ddmmyy[1] = Int(dateArr[1])!
        let components = Calendar.current.dateComponents([.year], from: Date())
        ddmmyy[2] = (components.year)!
        return ddmmyy
    case 24:
        ddmmyy[0] = Int(dateArr[2])!
        ddmmyy[1] = Int(dateArr[1])!
        let components = Calendar.current.dateComponents([.year], from: Date())
        ddmmyy[2] = (components.year)!
        return ddmmyy
    default:
        return ddmmyy
        
        
        
    }
}

func findSubString(regex: NSRegularExpression, subString: String) -> String {
    let matches = regex.matches(in: subString, options: [], range: NSRange(location: 0, length: subString.utf16.count))
    if let match = matches.first {
        let range = match.range(at: 0)
        if let swiftRange = Range(range, in: subString) {
            let result = subString[swiftRange]
           // print("substring is: ",result)
            return String(result)
        }
    }
    return ""
}

func getMyDate(year: Int, month: Int, day: Int) -> Date {
    let components = DateComponents(year: year, month: month, day: day)
    
    return Calendar.current.date(from: components)!
}
