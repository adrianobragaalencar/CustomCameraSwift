//
//  AbstractCameraWriter.swift
//  CustomCamera
//
//  Created by Adriano Braga on 30/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import UIKit
import AVFoundation

public class AbstractCameraWriter: NSObject, CameraWriter {
 
    public   var session: AVCaptureSession!;
    public   var sessionQueue: dispatch_queue_t!;
    public   var recording: Bool = false;
    internal var videoDeviceInput: AVCaptureDeviceInput!
    internal var fileOutputPath: String!
    internal var videoSettings: NSDictionary!
    internal var orientation: AVCaptureVideoOrientation!
    
    public override init() {
        super.init()
        var fileName: String! = generateFileName().stringByAppendingPathExtension("mov")
        fileOutputPath        = NSTemporaryDirectory().stringByAppendingPathComponent(fileName)
        videoSettings         = [ AVVideoCodecKey  : AVVideoCodecH264,
                                  AVVideoWidthKey  : "1280",
                                  AVVideoHeightKey : "780",
                                  AVVideoCompressionPropertiesKey : [
                                    AVVideoAverageBitRateKey : "1680000",
                                    AVVideoProfileLevelKey   : AVVideoProfileLevelH264HighAutoLevel
                                ]]
    }
    
    public func configure(finish: DidConfigFinish) {
        session      = AVCaptureSession()
        sessionQueue = dispatch_queue_create("CameraRecorderQueue", DISPATCH_QUEUE_SERIAL)
        if session.canSetSessionPreset(AVCaptureSessionPresetHigh) {
            session.sessionPreset = AVCaptureSessionPresetHigh
        }
    }
    
    internal func configureAVCaptureConnection(connection: AVCaptureConnection!) {
        if connection.supportsVideoOrientation {
            orientation                 = DeviceUtil.getVideoOrientation(UIDevice.currentDevice().orientation)
            connection.videoOrientation = orientation
        }
    }
    
    private func generateFileName() -> String {
        let time: NSDate           = NSDate();
        let format:NSDateFormatter = NSDateFormatter();
        format.dateFormat          = "MM-dd-yyyy-hh-mm-ss";
        return "clip-" + format.stringFromDate(time);
    }
}
