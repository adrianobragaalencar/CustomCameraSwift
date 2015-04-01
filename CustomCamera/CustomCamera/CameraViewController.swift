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

    private var cameraWriter: CameraWriter!
    
    public override func viewDidLoad() {
        checkDeviceAuthorizationStatus()
        cameraWriter = CameraVideoFileWriter()
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(animated: Bool) {
        cameraWriter.configure { (orientation) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let cameraView: CameraPreviewView = self.view! as CameraPreviewView
                cameraView.setOrientation(orientation)
                cameraView.setSession(self.cameraWriter.session)
                self.cameraWriter.startRunning!()
            })
        }
        super.viewWillAppear(animated)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        cameraWriter.stopRunning!()
        super.viewDidDisappear(animated)
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
        if cameraWriter.recording {
            cameraWriter.saveVideo!({ (url) -> Void in
                DeviceUtil.exportVideoToAlbum(url, completion: { () -> Void in
                    exit(0)
                });
            })
        } else {
            cameraWriter.recordVideo!()
        }
    }
}

