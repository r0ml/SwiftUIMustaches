//
//  UIImage+RotatedImage.swift
//  SwiftMustaches
//
//  Created by Dariusz Rybicki on 18/09/14.
//  Copyright (c) 2014 EL Passion. All rights reserved.
//

// import UIKit

import SwiftUI

#if os(macOS)
import AppKit
public typealias XImage = NSImage
extension Image {
  public init(xImage: XImage) {
    self.init(nsImage: xImage)
  }
}
#else
import UIKit
public typealias XImage = UIImage
extension Image {
  public init(xImage: XImage) {
    self.init(uiImage: xImage)
  }
}
#endif

/*
public extension XImage {
    
  func rotatedImage(angle: CGFloat) -> XImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let rotatedViewBoxTransform = CGAffineTransformMakeRotation(angle)
        rotatedViewBox.transform = rotatedViewBoxTransform
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsPushContext(UIGraphicsGetCurrentContext()!)
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
    context!.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2);
    context!.rotate(by: angle)
    self.draw(in: CGRect(
            x: -self.size.width / 2,
            y: -self.size.height / 2,
            width: self.size.width,
            height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIGraphicsPopContext()
        
    return rotatedImage!
    }
    
}
*/
