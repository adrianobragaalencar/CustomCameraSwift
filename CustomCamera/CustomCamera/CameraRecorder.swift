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
    
    public var session: AVCaptureSession!
    public var recording: Bool = false
    private let sessionQueue = dispatch_queue_create("SessionQueue", DISPATCH_QUEUE_SERIAL)
    private var deviceInput: AVCaptureDeviceInput!
    private var captureOutput: AVCaptureOutput!
    private var writer: AVAssetWriter!
    private var writerInput: AVAssetWriterInput!
    private var orientation: AVCaptureVideoOrientation!
    private var connection: AVCaptureConnection!
    private var mediaType: MediaType!
    private var position = AVCaptureDevicePosition.Back
    private var fileUrl: NSURL!
    
    public func configure(mediaType: MediaType, orientation: AVCaptureVideoOrientation, completeHandler: ConfigureHandler) {
        self.mediaType = mediaType
        self.orientation = orientation
        session = AVCaptureSession()
        setSessionPreset(mediaType == .Photo ?
            AVCaptureSessionPresetPhoto :
            AVCaptureSessionPresetHigh)
        configureCamera(mediaType, position: position)
        completeHandler()
    }
    
    public func reverse() {
        position = position == .Back ? .Front : .Back
        configureCamera(mediaType, position: position)
    }
    
    public func takePicture() {
        if let stillImageOutput = captureOutput as! AVCaptureStillImageOutput! {
            // predefined CameraShutter sound
            // http://iphonedevwiki.net/index.php/AudioServices
            AudioServicesPlaySystemSound(1108)
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection) { (sampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let data = UIImageJPEGRepresentation(UIImage(data: imageData)!, 1)
                data?.writeToFile(NameGeneratorUtil.generateFilenameAtTempDir(PhotoExtension), atomically: true)
            }
        }
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
        fileUrl = NSURL(fileURLWithPath: NameGeneratorUtil.generateFilenameAtTempDir(VideoExtension))
        dispatch_async(sessionQueue, { () -> Void in
            do {
                self.writer = try AVAssetWriter(URL: self.fileUrl, fileType: AVFileTypeQuickTimeMovie)
                self.writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: VideoSettings)
                if self.writer.canAddInput(self.writerInput) {
                    self.writer.addInput(self.writerInput)
                }
                self.recording = true
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
    }
    
    public func stopRecord(completeHandler: StopRecordHandler) {
        self.recording = false
        dispatch_async(sessionQueue, { () -> Void in
            self.writerInput.markAsFinished()
            self.writer.finishWritingWithCompletionHandler({ () -> Void in
                completeHandler(url: self.fileUrl)
            })
        })
    }
    
    private func configureCamera(mediaType: MediaType, position: AVCaptureDevicePosition) {
        let device = DeviceUtil.deviceWithMediaType(AVMediaTypeVideo, position: position)
        do {
            session.removeInput(deviceInput)
            session.removeOutput(captureOutput)
            deviceInput = try AVCaptureDeviceInput(device: device)
            captureOutput = createCaptureOutput(mediaType)
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            if session.canAddOutput(captureOutput) {
                session.addOutput(captureOutput)
                connection = captureOutput.connectionWithMediaType(AVMediaTypeVideo)
                if connection.supportsVideoOrientation {
                    connection.videoOrientation = orientation
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func createCaptureOutput(mediaType: MediaType) -> AVCaptureOutput! {
        if mediaType == .Photo {
            let stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput.outputSettings = PhotoSettings
            return stillImageOutput
        } else {
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            return videoDataOutput
        }
    }
    
    private func setSessionPreset(preset: String) {
        if session.canSetSessionPreset(preset) {
            session.sessionPreset = preset
        }
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate Protocol

extension CameraRecorder : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        dispatch_async(sessionQueue, { () -> Void in
            if let writer = self.writer {
                switch writer.status {
                case .Unknown:
                    if self.recording && writer.startWriting() {
                        writer.startSessionAtSourceTime(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                    }
                case .Writing:
                    if self.writerInput.readyForMoreMediaData {
                        self.writerInput.appendSampleBuffer(sampleBuffer)
                    }
                case .Cancelled:
                    print("Cancelled")
                case .Completed:
                    print("Completed")
                case .Failed:
                    print("Failed")
                }
            }
        })
    }
}

