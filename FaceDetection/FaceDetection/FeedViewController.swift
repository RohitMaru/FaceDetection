//
//  ViewController.swift
//  FaceDetection
//
//  Created by Ryan Davies on 02/09/2014.
//  Copyright (c) 2016 Ryan Davies. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation
import Vision
import Foundation

class FeedViewController: UIViewController {
    lazy var captureSessionController: CaptureSessionController = {
        let controller = CaptureSessionController()
        controller.delegate = self
        return controller
    }()
    
    var blurView = UIVisualEffectView()
    var webView = UIWebView()
    
    var faceDetected = false
    var imageView: UIImageView {
        get {
            return self.view as! UIImageView
        }
    }
    
    override func loadView() {
        self.view = UIImageView()
    }
    
    override func viewDidLoad() {
        webView = UIWebView(frame: self.view.bounds)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSessionController.startCaptureSession()
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
        blurView.alpha = 0;
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSessionController.stopCaptureSession()
    }
}

extension FeedViewController : CaptureSessionControllerDelegate {
    func captureSessionController(_ captureSessionController: CaptureSessionController, didStartRunningCaptureSession captureSession: AVCaptureSession) {
        print("Capture session started.")
    }
    
    func captureSessionController(_ captureSessionController: CaptureSessionController, didStopRunningCaptureSession captureSession: AVCaptureSession) {
        print("Capture session stopped.")
    }
    
    func captureSessionController(_ captureSessionController: CaptureSessionController, didFailWithError error: Error) {
        print("Failed with error: \(error)")
    }
    
    func captureSessionController(_ captureSessionController: CaptureSessionController, didUpdateWithSampleBuffer sampleBuffer: CMSampleBuffer) {
        if let filter = FaceObscurationFilter(CMSampleBuffer: sampleBuffer) {
            filter.detectFace(complete: { [weak self] (detected, detectedImage) in
                if detected {
                    if let detected = self?.faceDetected, !detected {
                        self?.faceDetected = true
                        print("rohit check: face detected")
                        DispatchQueue.global().async {
                            if #available(iOS 11.0, *) {
                                FaceDetector.getLandmarks(for: filter.inputImage, complete: { (landmarks) in
//                                    VNFaceLandmarks2D
                                    if let landmarksLocal = landmarks {
                                        self?.didFindFace(landmarks: landmarksLocal)
                                    }
                                })
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                }
                else {
                    print("rohit check: looking for faces")
                }
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(ciImage: filter.inputImage)
                    if let detected = self?.faceDetected, detected {
                        self?.blurView.alpha = 0.8
                    }
                }
            })
        }
        else {
            print("rohit check: face detected || filter problem")
        }
    }
    
    @available(iOS 11.0, *)
    func didFindFace(landmarks: VNFaceLandmarks2D) {
//        let allPoints = landmarks.allPoints
//        print("landmarks: \(allPoints?.normalizedPoints)")
//        let dict = ["leftEye": landmarks.leftEye, "rightEye": landmarks.rightEye, "leftEyebrow": landmarks.leftEyebrow, "rightEyebrow": landmarks.rightEyebrow, "nose": landmarks.nose];
//        do {
//            let data = try JSONEncoder().encode(dict)
//            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//
//        }
//        catch let error as NSError {
//            print(error.localizedDescription)
//        }
        DispatchQueue.main.async { [weak self] in
            var hasSubviews = false
            self?.view.subviews.forEach { (subview) in
                if let _ = subview as? UIWebView {
                    hasSubviews = true
                }
            }
            if !hasSubviews {
                self?.view.addSubview((self?.webView)!)
                if let url = URL(string: "https://www.yahoo.com") {
                    self?.webView.loadRequest(URLRequest(url: url))
                }
            }
        }
    }
    
    
}
