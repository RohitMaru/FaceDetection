//
//  CoreImageAdditions.swift
//  FaceDetection
//
//  Created by Ryan Davies on 27/03/2016.
//  Copyright © 2016 Ryan Davies. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

extension CMSampleBuffer {
    var imageBuffer: CVImageBuffer? {
        get {
            return CMSampleBufferGetImageBuffer(self)
        }
    }
}

extension CIImage {
    convenience init?(CMSampleBuffer sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = sampleBuffer.imageBuffer else {
            return nil
        }
        self.init(cvPixelBuffer: imageBuffer)
    }
}

/*: CIFilter feels very Objective-C oriented, and there's no clear benefit to
 subclassing CIFilter over declaring our own protocol with the same signature.
 For new filters, conform to the `Filter` protocol instead of subclassing
 `CIFilter` unless necessary.
 */
protocol Filter {
    var inputImage: CIImage { get }
    var outputImage: CIImage? { get }
    
    init(inputImage: CIImage)
}

// This makes it easier to create filters from `CMSampleBuffer`.
extension Filter {
    init?(CMSampleBuffer sampleBuffer: CMSampleBuffer) {
        guard let image = CIImage(CMSampleBuffer: sampleBuffer) else {
            return nil
        }
        image 
        self.init(inputImage: image)
    }
    
    func imageFromSampleBuffer(sampleBuffer : CMSampleBuffer) -> UIImage
    {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        let  imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly);
        
        
        // Get the number of bytes per row for the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!);
        
        // Get the number of bytes per row for the pixel buffer
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!);
        // Get the pixel buffer width and height
        let width = CVPixelBufferGetWidth(imageBuffer!);
        let height = CVPixelBufferGetHeight(imageBuffer!);
        
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext.init(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context?.makeImage();
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags.readOnly);
        
        // Create an image object from the Quartz image
        let image = UIImage.init(cgImage: quartzImage!);
        
        return (image);
    }
}
