//
//  Constants.swift
//  CustomCamera
//
//  Created by Adriano Alencar on 09/10/15.
//  Copyright © 2015 YattaTech. All rights reserved.
//

import AVFoundation

public let VideoExtension                     = "mov"
public let PhotoExtension                     = "jpg"
public let VideoSettings: [String: AnyObject] = [
    AVVideoCodecKey : AVVideoCodecH264,
    AVVideoWidthKey : "1280",
    AVVideoHeightKey : "720",
    AVVideoCompressionPropertiesKey : [
        AVVideoAverageBitRateKey : "1680000",
        AVVideoProfileLevelKey : AVVideoProfileLevelH264HighAutoLevel
    ]
]
public let PhotoSettings: [String: AnyObject] = [
    AVVideoCodecKey: AVVideoCodecJPEG
]