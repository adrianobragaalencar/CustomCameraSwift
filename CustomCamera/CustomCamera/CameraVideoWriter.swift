//
//  CameraVideoWriter.swift
//  CustomCamera
//
//  Created by Adriano Braga on 30/03/15.
//  Copyright (c) 2015 YattaTech. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraVideoWriter: AbstractCameraWriter, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var writer: AVAssetWriter!
    private var writerInput: AVAssetWriterInput!
    
    public override func configure(finish: DidConfigFinish) {
        super.configure(finish);
        dispatch_async(sessionQueue, { () -> Void in
            let videoDevice       = DeviceUtil.deviceWithMediaType(AVMediaTypeVideo, position: .Back)
            DeviceUtil.configureCameraForHighestFrameRate(videoDevice)
            self.videoDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: nil) as AVCaptureDeviceInput!
            self.videoDataOutput  = AVCaptureVideoDataOutput()
            self.videoDataOutput.alwaysDiscardsLateVideoFrames                      = true
            self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo)?.enabled = true
            if self.session.canAddInput(self.videoDeviceInput) {
                self.session.addInput(self.videoDeviceInput)
            }
            if self.session.canAddOutput(self.videoDataOutput) {
                self.session.addOutput(self.videoDataOutput)
                let connection = self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo)
                self.configureAVCaptureConnection(connection)
                self.videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            }
            finish(orientation: self.orientation)
        })
    }
    
    public func captureOutput(captureOutput: AVCaptureOutput!,
           didDropSampleBuffer sampleBuffer: CMSampleBuffer!,
                  fromConnection connection: AVCaptureConnection!) {
        dispatch_async(sessionQueue, { () -> Void in
            if self.recording {
                if self.writer.status == .Unknown {
                    if self.writer.startWriting() {
                        self.writer.startSessionAtSourceTime(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                    }
                }
                if self.writer.status == .Writing {
                    if self.writerInput.readyForMoreMediaData {
                        self.writerInput.appendSampleBuffer(sampleBuffer)
                    }
                }
            }
        });
    }
    
    public func saveVideo(completion: DidVideoSave) {
        println("stop recording video")
        println("start saving video")
        dispatch_async(sessionQueue, { () -> Void in
            self.recording = false
            self.writerInput.markAsFinished()
            self.writer.finishWritingWithCompletionHandler({ () -> Void in
                completion(url: NSURL(fileURLWithPath: self.fileOutputPath))
            });
        });
    }
    
    public func recordVideo() {
        println("start recording video")
        dispatch_async(sessionQueue, { () -> Void in
            let url          = NSURL(fileURLWithPath: self.fileOutputPath)
            self.writer      = AVAssetWriter(URL: url, fileType: AVFileTypeQuickTimeMovie, error: nil)
            self.writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo,
                                             outputSettings: self.videoSettings)
            self.recording   = true
            self.writerInput.expectsMediaDataInRealTime = true
            if self.writer.canAddInput(self.writerInput) {
                self.writer.addInput(self.writerInput)
            }
        });
    }
}
