//
//  CameraWriterProtocol.swift
//  CustomCamera
//
//  Created by Adriano Braga on 30/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import Foundation
import AVFoundation

public typealias ConfigureHandler  = () -> Void
public typealias StopRecordHandler = (fileUrl: NSURL) -> Void

public protocol ICameraRecorder : class {

    var session: AVCaptureSession! { get }
    var recording: Bool { get }
    
    func configure(orientation: AVCaptureVideoOrientation, completeHandler: ConfigureHandler)
    func startPreview()
    func stopPreview()
    func startRecord()
    func stopRecord(completeHandler: StopRecordHandler)
}