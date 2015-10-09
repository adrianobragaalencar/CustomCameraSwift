//
//  ViewController.swift
//  CustomCamera
//
//  Created by Adriano Braga on 30/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraViewController: UIViewController {

    private var cameraRecorder: ICameraRecorder!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        checkDeviceAuthorizationStatus()
        cameraRecorder = CameraRecorder()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraRecorder.configure(.Video, orientation: .LandscapeRight, completeHandler: { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let cameraPreview = self.view as! CameraPreviewView
                cameraPreview.orientation = .LandscapeRight
                cameraPreview.session = self.cameraRecorder.session
                self.cameraRecorder.startPreview()
            })
        })
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        cameraRecorder.stopPreview()
    }
    
    private func checkDeviceAuthorizationStatus() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
            if !granted {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alert = UIAlertView(title: "Alert",
                                          message: "CustomCamera doesn't have permission to use Camera, please change privacy settings",
                                         delegate: self,
                                cancelButtonTitle: "Ok")
                    alert.show()
                });
            }
        });
    }
    
    @IBAction func buttonRecordTapped(sender: AnyObject) {
        if cameraRecorder.recording {
            cameraRecorder.stopRecord({ (filepath) -> Void in
                DeviceUtil.exportVideoToAlbum(filepath, completion: { () -> Void in
                    exit(0)
                });
            })
        } else {
            cameraRecorder.startRecord()
        }
    }
}

