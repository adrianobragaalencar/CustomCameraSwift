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
public typealias StopRecordHandler = (url: NSURL) -> Void

public enum MediaType : Int {
    case Photo
    case Video
}

public protocol ICameraRecorder : class {

    var session: AVCaptureSession! { get }
    var recording: Bool { get }
    
    func configure(mediaType: MediaType, orientation: AVCaptureVideoOrientation, completeHandler: ConfigureHandler)
    func reverse()
    func startPreview()
    func stopPreview()
    func takePicture()
    func startRecord()
    func stopRecord(completeHandler: StopRecordHandler)
}