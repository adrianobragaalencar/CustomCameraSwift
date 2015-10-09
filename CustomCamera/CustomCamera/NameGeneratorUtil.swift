//
//  NameGeneratorUtil.swift
//  CustomCamera
//
//  Created by Adriano Alencar on 09/10/15.
//  Copyright © 2015 YattaTech. All rights reserved.
//

import UIKit

public final class NameGeneratorUtil {
    
    private static let Formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM_dd_yyyy_hh:mm:ss"
        return formatter
        }()
    
    public class func generateFilenameAtPath(path: NSString, ext: String) -> String {
        let dateFormat = Formatter.stringFromDate(NSDate())
        return path.stringByAppendingPathComponent("\(dateFormat).\(ext)")
    }
    
    public class func generateFilenameAtTempDir(ext: String) -> String {
        let tempDir: NSString = NSTemporaryDirectory()
        let date = NSDate()
        let dateFormat = Formatter.stringFromDate(date)
        return tempDir.stringByAppendingPathComponent("\(dateFormat).\(ext)")
    }
}

