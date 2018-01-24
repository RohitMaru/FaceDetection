//
//  FaceDetector.swift
//  FaceDetection
//
//  Created by Rohit Marumamula on 1/23/18.
//  Copyright © 2018 Ryan Davies. All rights reserved.
//

import Foundation
import Vision
import CoreImage
import UIKit

class FaceDetector {
    
    @available(iOS 11.0, *)
    open class func getLandmarks(for source: CIImage, complete: @escaping (VNFaceLandmarks2D?) -> Void) {
        var retLandmarks: VNFaceLandmarks2D? = nil
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            if error == nil {
                if let results = request.results as? [VNFaceObservation] {
                    print("Found \(results.count) faces")
                    
                    for faceObservation in results {
                        guard let landmarks = faceObservation.landmarks else {
                            continue
                        }
                        retLandmarks = landmarks
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
            complete(retLandmarks)
        }
        if let cgImage = convertCIImageToCGImage(inputImage: source) {
            let vnImage = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? vnImage.perform([detectFaceRequest])
        }
    }
    
    class func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if context != nil {
            return context.createCGImage(inputImage, from: inputImage.extent)
        }
        return nil
    }
    
}
