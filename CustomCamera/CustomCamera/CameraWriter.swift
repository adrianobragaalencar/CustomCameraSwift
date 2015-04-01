//
//  CameraWriterProtocol.swift
//  CustomCamera
//
//  Created by Adriano Braga on 30/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import Foundation
import AVFoundation

public typealias DidConfigFinish = (orientation: AVCaptureVideoOrientation) -> Void
public typealias DidVideoSave    = (url: NSURL!) -> Void

@objc public protocol CameraWriter : class {

    var session: AVCaptureSession!      { get }
    var sessionQueue: dispatch_queue_t! { get }
    var recording: Bool                 { get }
    
    func configure(finish: DidConfigFinish)
    optional func startRunning()
    optional func stopRunning()
    optional func saveVideo(completion: DidVideoSave)
    optional func recordVideo()
}