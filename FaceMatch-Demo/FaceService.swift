//
//  FaceService.swift
//  FaceMatch-Demo
//
//  Created by Alex Nguyen on 2016-06-12.
//  Copyright © 2016 Alex Nguyen. All rights reserved.
//

import Foundation
import ProjectOxfordFace
class FaceService {
    static let instance = FaceService()
    
    let client = MPOFaceServiceClient(subscriptionKey: "9cf812e9d82d4d1388925d9fc43212b7")
}