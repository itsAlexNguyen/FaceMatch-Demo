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
        isBackCamera = true
    }
    func takePhoto() -> UIImage? {
        var returnImage: UIImage?
        previewLayer?.opacity = 0.4
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    returnImage = image
                }
            })
        }
        return returnImage
    }
    func changeCamera() {
        captureSession?.removeInput(input)
        guard var backCamera = AVCaptureDevice.devices().filter({ $0.position == .Front })
            .first as? AVCaptureDevice else {
                fatalError("No front facing camera found")
        }
        
        if !isBackCamera {
            backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            isBackCamera = true
        } else {
            isBackCamera = false
        }
        
        var error: NSError?
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        captureSession?.addInput(input)
    }
    
    func setSize(size: CGRect){
        previewLayer!.frame = size
        isBackCamera = true
    }

}
