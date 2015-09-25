//
//  DeviceUtil.swift
//  CustomCamera
//
//  Created by Adriano Braga on 30/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

public typealias DidExportComplete = () -> Void

public class DeviceUtil: NSObject {
   
    public class func deviceWithMediaType(mediaType: String, position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType) as! [AVCaptureDevice]
        return devices.filter() { $0.position == position }.first
    }
    
    public class func exportVideoToAlbum (url: NSURL, completion: DidExportComplete) {
        let library: ALAssetsLibrary = ALAssetsLibrary()
        library.writeVideoAtPathToSavedPhotosAlbum(url, completionBlock: { (assetUrl, error) -> Void in
            completion()
        });
    }
}










