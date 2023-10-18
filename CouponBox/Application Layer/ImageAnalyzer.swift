//
//  ImageAnalyzer.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import Foundation
import Vision

final class ImageAnalyzer: ImageAnalyzable {
    func recognizeBarcode(from imageData: Data, handle: @escaping ([String]) -> Void) {
        guard let image = imageData.cgImage else { return }
        
        let request = VNDetectBarcodesRequest { request, error in
            guard error == nil else { return }
            handle(request.results?.compactMap {
                ($0 as? VNBarcodeObservation)?.payloadStringValue
            } ?? [])
        }
        request.revision = VNDetectBarcodesRequestRevision1
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
            } catch {
                printLog(error)
                handle([])
            }
        }
    }
    
    func recognizeText(from imageData: Data, handle: @escaping ([String]) -> Void) {
        guard let image = imageData.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else { return }
            handle(request.results?.compactMap {
                ($0 as? VNRecognizedTextObservation)?.topCandidates(1).first?.string
            } ?? [])
        }
        request.recognitionLanguages = ["ko", "en"]
        request.recognitionLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
            } catch {
                printLog(error)
                handle([])
            }
        }
    }
}
