//
//  CameraVideoFileWriter.swift
//  CustomCamera
//
//  Created by Adriano Braga on 30/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraVideoFileWriter: AbstractCameraWriter, AVCaptureFileOutputRecordingDelegate {
    
    private var videoDataOutput: AVCaptureMovieFileOutput!
    private var completeBlock: DidVideoSave!
    
    public override func configure(finish: DidConfigFinish) {
        super.configure(finish);
        dispatch_async(sessionQueue, { () -> Void in
            let videoDevice       = DeviceUtil.deviceWithMediaType(AVMediaTypeVideo, position: .Back)
            self.videoDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: nil) as AVCaptureDeviceInput!
            self.videoDataOutput  = AVCaptureMovieFileOutput()
            if self.session.canAddInput(self.videoDeviceInput) {
                self.session.addInput(self.videoDeviceInput)
            }
            if self.session.canAddOutput(self.videoDataOutput) {
                self.session.addOutput(self.videoDataOutput)
                let connection = self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo)
                self.configureAVCaptureConnection(connection)
            }
            finish(orientation: self.orientation)
        })
    }
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!,
        didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!,
        fromConnections connections: [AnyObject]!, error: NSError!) {
        dispatch_async(sessionQueue, { () -> Void in
            if self.completeBlock != nil {
                self.completeBlock(url: outputFileURL)
            }
        });
    }
    
    public func saveVideo(completion: DidVideoSave) {
        println("stop recording video")
        println("start saving video")
        dispatch_async(sessionQueue, { () -> Void in
            self.recording     = false
            self.completeBlock = completion
            self.videoDataOutput.stopRecording()
        });
    }
    
    public func recordVideo() {
        println("start recording video")
        dispatch_async(sessionQueue, { () -> Void in
            let url        = NSURL(fileURLWithPath: self.fileOutputPath)
            self.recording = true
            self.videoDataOutput.startRecordingToOutputFileURL(url, recordingDelegate: self)
        });
    }
}
