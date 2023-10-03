//
//  UIImage+ImageOrientation.swift
//  SwiftMustaches
//
//  Created by Dariusz Rybicki on 18/09/14.
//  Copyright (c) 2014 EL Passion. All rights reserved.
//

// import UIKit

public extension XImage {
    
  class func orientationPropertyValueFromImageOrientation(imageOrientation: XImage.Orientation) -> Int {
        var orientation: Int = 0
        switch imageOrientation {
        case .up:
            orientation = 1
        case .down:
            orientation = 3
        case .left:
            orientation = 8
        case .right:
            orientation = 6
        case .upMirrored:
            orientation = 2
        case .downMirrored:
            orientation = 4
        case .leftMirrored:
            orientation = 5
        case .rightMirrored:
            orientation = 7
        @unknown default:
          fatalError()
        }
        return orientation
    }
    
  func orientationPropertyValueFromImageOrientation() -> Int {
    return UIImage.orientationPropertyValueFromImageOrientation(imageOrientation: self.imageOrientation)
    }
    
}