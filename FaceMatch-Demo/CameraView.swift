//
//  CameraView.swift
//  FaceMatch-Demo
//
//  Created by Alex Nguyen on 2016-06-12.
//  Copyright © 2016 Alex Nguyen. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView {
    var input: AVCaptureDeviceInput!
    var isBackCamera: Bool!
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func awakeFromNib() {
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                self.layer.addSublayer(previewLayer!)
                captureSession!.startRunning()
            }
        }
        previewLayer?.opacity = 1.0
        previewLayer?.zPosition = -1
    }
    
    func setSize(size: CGRect){
        previewLayer!.frame = size
        isBackCamera = true
    }

}
