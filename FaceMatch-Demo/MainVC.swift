//
//  ViewController.swift
//  FaceMatch-Demo
//
//  Created by Alex Nguyen on 2016-06-12.
//  Copyright © 2016 Alex Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import ProjectOxfordFace

class MainVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var shutterBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    var imagePicker: UIImagePickerController!
    var phototaken: UIImage?
    var selectedPhoto: UIImage?
    var faceIdPhotoTaken: String?
    var faceIdSelectedPhoto: String?
    var isIdentical: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cameraView.setSize(cameraView.bounds)
    }
    @IBAction func takePhoto(sender: AnyObject) {
        print("take photo")
        if selectedImage.hidden {
        if let videoConnection = cameraView.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            cameraView.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.selectedImage.image = image
                    self.phototaken = image
                    self.selectedImage.hidden = false
                    self.shutterBtn.setImage(UIImage(named: "select"), forState: .Normal)
                    self.cancelBtn.hidden = false
                    self.shutterBtn.alpha = 1
                }
            })
        }
        } else {
            print("user selected image")
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnPressed(sender: AnyObject) {
        cancel()
    }
    @IBAction func switchCamera(sender: AnyObject) {
        print("switched camera")
        cameraView.changeCamera()
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        selectedPhoto = image
        doProcessing()
    }
    func getFaceIDFromPhotoTaken(){
        var foundFace = false
        if let img = phototaken, let imgData = UIImageJPEGRepresentation(img, 0.6){
            FaceService.instance.client.detectWithData(imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces: [MPOFace]!, err:NSError!) in
                if err == nil {
                    var faceId: String?
                    print("test")
                    for face in faces {
                        faceId = face.faceId
                        print(faceId)
                        self.faceIdPhotoTaken = faceId
                        foundFace = true
                        self.checkMatch()
                        break
                    }
                } else {
                    print(err.debugDescription)
                }
                if !foundFace {
                    self.showAlert("Error finding face", msg: "Unable to find a face in the photo, please try again :(")
                }
            })
        }
    }
    
    func checkMatch(){
        if let myImg = selectedPhoto, let imgData = UIImageJPEGRepresentation(myImg, 0.8){
            FaceService.instance.client.detectWithData(imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces: [MPOFace]!, err: NSError!) in
                if err == nil {
                    var faceId: String?
                    for face in faces {
                        faceId = face.faceId
                        break
                    }
                    if faceId != nil {
                        FaceService.instance.client.verifyWithFirstFaceId(self.faceIdPhotoTaken, faceId2: faceId, completionBlock: { (result: MPOVerifyResult!, err: NSError!) in
                            if err == nil {
                                print(result.confidence)
                                print(result.isIdentical)
                                self.isIdentical = result.isIdentical
                                self.printResult()
                                print(result.debugDescription)
                            } else {
                                self.showAlert("Error finding face", msg: "Unable to find a face in the photo, please try again :(")
                                print(err.debugDescription)
                            }
                        })
                    } else {
                        self.showAlert("Error finding face", msg: "Unable to find a face in the photo, please try again :(")
                    }
                }
            })
        }
    }
    func cancel() {
        cancelBtn.hidden = true
        selectedImage.hidden = true
        shutterBtn.setImage(UIImage(named: "shutter"), forState: .Normal)
        shutterBtn.alpha = 0.4
    }
    func printResult(){
        if let result = isIdentical {
        if result {
            showAlert("MATCH!", msg: "We have a match!")
            cancel()
        } else {
            showAlert("NO MATCH!", msg: "We don't have a match!")
            cancel()
        }
        }
    }
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func doProcessing(){
        print("processing photos")
        getFaceIDFromPhotoTaken()
    }
}

