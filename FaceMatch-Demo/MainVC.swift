//
//  ViewController.swift
//  FaceMatch-Demo
//
//  Created by Alex Nguyen on 2016-06-12.
//  Copyright © 2016 Alex Nguyen. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    @IBOutlet weak var cameraView: CameraView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cameraView.setSize(cameraView.bounds)
    }

}

