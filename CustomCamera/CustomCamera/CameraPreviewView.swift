//
//  CameraPreviewView.swift
//  CustomCamera
//
//  Created by Adriano Braga on 31/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import UIKit
import AVFoundation

public final class CameraPreviewView: UIView {
    
    public var orientation: AVCaptureVideoOrientation?
    public var session: AVCaptureSession? {
        get {
            let previewLayer = layer as! AVCaptureVideoPreviewLayer
            return previewLayer.session
        }
        set {
            let previewLayer = layer as! AVCaptureVideoPreviewLayer
            previewLayer.session = newValue
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            if previewLayer.connection.supportsVideoOrientation {
                previewLayer.connection.videoOrientation = orientation ?? .LandscapeRight
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        orientation = .LandscapeRight
    }
    
    public class override func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
