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
        let devices: [AVCaptureDevice!] = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as [AVCaptureDevice!]
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil;
    }
    
    public class func configureCameraForHighestFrameRate(device: AVCaptureDevice!) {
        var bestFormat: AVCaptureDeviceFormat?
        var bestFormatRange: AVFrameRateRange?
        for format in device.formats as [AVCaptureDeviceFormat!] {
            for range in format.videoSupportedFrameRateRanges as [AVFrameRateRange!] {
                if (range.maxFrameRate > bestFormatRange?.maxFrameRate) {
                    bestFormat      = format
                    bestFormatRange = range
                }
            }
        }
        if let format = bestFormat {
            if device.lockForConfiguration(nil) {
                device.activeFormat                = bestFormat
                device.activeVideoMinFrameDuration = bestFormatRange!.minFrameDuration
                device.activeVideoMaxFrameDuration = bestFormatRange!.maxFrameDuration
                device.unlockForConfiguration()
            }
        }
    }
    
    public class func getVideoOrientation (orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        // customize the method to set the device orientation properly
        switch (orientation) {
        default:
            return .LandscapeRight;
        }
    }
    
    public class func exportVideoToAlbum (url: NSURL, completion: DidExportComplete) {
        let library: ALAssetsLibrary = ALAssetsLibrary()
        library.writeVideoAtPathToSavedPhotosAlbum(url, completionBlock: { (assetUrl, error) -> Void in
            if error != nil {
                println("Error while exporting video \(error.description)")
            }
            println("Stop saving video")
            completion()
        });
    }
}










