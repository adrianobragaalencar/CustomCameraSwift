//
//  CameraPreviewView.swift
//  CustomCamera
//
//  Created by Adriano Braga on 31/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraPreviewView: UIView {

    private var session: AVCaptureSession!
    private var orientation: AVCaptureVideoOrientation!
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.orientation = .LandscapeRight
    }
    
    public class override func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    public func getSession() -> AVCaptureSession! {
        var previewLayer: AVCaptureVideoPreviewLayer = self.layer as AVCaptureVideoPreviewLayer;
        return previewLayer.session
    }
    
    public func setSession(session: AVCaptureSession!) {
        var previewLayer: AVCaptureVideoPreviewLayer  = self.layer as AVCaptureVideoPreviewLayer;
        previewLayer.session                          = session;
        previewLayer.videoGravity                     = AVLayerVideoGravityResizeAspectFill;
        if previewLayer.connection!.supportsVideoOrientation {
            previewLayer.connection!.videoOrientation = self.orientation
        }
    }
    
    public func setOrientation(orientation: AVCaptureVideoOrientation) {
        self.orientation = orientation
    }
}
