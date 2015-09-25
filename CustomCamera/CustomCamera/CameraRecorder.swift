//
//  CameraVideoFileWriter.swift
//  CustomCamera
//
//  Created by Adriano Braga on 30/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraRecorder: NSObject, ICameraRecorder {
    
    private static let Formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM_dd_yyyy_hh:mm:ss"
        return formatter
        }()
    public var session: AVCaptureSession!
    public var recording: Bool = false
    private let videoSettings = [
        AVVideoCodecKey : AVVideoCodecH264,
        AVVideoWidthKey : "1280",
        AVVideoHeightKey : "780",
        AVVideoCompressionPropertiesKey : [
            AVVideoAverageBitRateKey : "1680000",
            AVVideoProfileLevelKey : AVVideoProfileLevelH264HighAutoLevel
        ]
    ]
    private let sessionQueue = dispatch_queue_create("SessionQueue", DISPATCH_QUEUE_SERIAL)

    private var deviceInput: AVCaptureDeviceInput!
    private var videoDataOutput: AVCaptureMovieFileOutput!
    private var fileOutputPath: String!
    private var completeHandler: StopRecordHandler?
    
    public override init() {
        super.init()
        let tempDir: NSString = NSTemporaryDirectory()
        fileOutputPath = tempDir.stringByAppendingPathComponent(createFileName())
    }
    
    public func configure(orientation: AVCaptureVideoOrientation, completeHandler: ConfigureHandler) {
        session = AVCaptureSession()
        if session.canSetSessionPreset(AVCaptureSessionPresetHigh) {
            session.sessionPreset = AVCaptureSessionPresetHigh
        }
        let device = DeviceUtil.deviceWithMediaType(AVMediaTypeVideo, position: .Back)
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
            videoDataOutput = AVCaptureMovieFileOutput()
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
                let connection = videoDataOutput.connectionWithMediaType(AVMediaTypeVideo)
                if connection.supportsVideoOrientation {
                    connection.videoOrientation = orientation
                }
            }
        } catch {
        }
        completeHandler()
    }
    
    public func startPreview() {
        dispatch_async(sessionQueue, { () -> Void in
            self.session.startRunning()
        })
    }
    
    public func stopPreview() {
        dispatch_async(sessionQueue, { () -> Void in
            self.session.stopRunning()
        })
    }
    
    public func startRecord() {
        dispatch_async(sessionQueue, { () -> Void in
            let url = NSURL(fileURLWithPath: self.fileOutputPath)
            self.recording = true
            self.videoDataOutput.startRecordingToOutputFileURL(url, recordingDelegate: self)
        })
    }
    
    public func stopRecord(completeHandler: StopRecordHandler) {
        dispatch_async(sessionQueue, { () -> Void in
            self.recording = false
            self.completeHandler = completeHandler
            self.videoDataOutput.stopRecording()
        })
    }
    
    private func createFileName() -> String {
        let date = NSDate()
        let dateFormat = CameraRecorder.Formatter.stringFromDate(date)
        return "\(dateFormat).mov"
    }
}

// MARK: AVCaptureFileOutputRecordingDelegate Protocol

extension CameraRecorder : AVCaptureFileOutputRecordingDelegate {
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if let handler = completeHandler {
            handler(fileUrl: outputFileURL)
        }
    }
}

