//
//  MustacheAdjustment.swift
//  SwiftMustaches
//
//  Created by Dariusz Rybicki on 19/09/14.
//  Copyright (c) 2014 EL Passion. All rights reserved.
//

import Foundation
import Photos
// import UIKit
import SwiftUI



// Switch to using Vision framework for face detection

// Use the mustache placement info to draw mustaches on the image.  That gets down in ContentView?


let MustacheAdjustmentDataFormatIdentifier = "software.tinker.SwiftMustaches.MustacheAdjustment"
let MustacheAdjustmentDataFormatVersion = "1.0"


public class MustacheAdjustment {
    
    public let mustacheImage: XImage = XImage(named: "mustache")!
    public let mustachePositions: [MustachePosition]
    
    // MARK: - Initialization
    
    public init?(adjustmentData: PHAdjustmentData) {
      if let mustachePositions = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: adjustmentData.data)
//      if let mustachePositions = NSKeyedUnarchiver.unarchiveObject(with: adjustmentData.data) as? [MustachePosition]
      {
        let mm = mustachePositions as! Array<MustachePosition>
            self.mustachePositions = mm
        }
        else {
            mustachePositions = []
            return nil
        }
    }
    
    public init?(image: XImage) {
        var mustachePositions: [MustachePosition] = []
        
        for faceFeature in FaceDetector.detectFaces(inImage: image) {
            if let mustachePosition = MustacheAdjustment.mustachePosition(imageSize: image.size, faceFeature: faceFeature) {
                mustachePositions.append(mustachePosition)
                NSLog("Mustache position found")
            }
            else {
                NSLog("Mustache position not found")
            }
        }
        
        self.mustachePositions = mustachePositions
        
        if self.mustachePositions.count == 0 {
            return nil
        }
    }
    
    // MARK: -
    
    public func adjustmentData() -> PHAdjustmentData {
      let data : Data = try! NSKeyedArchiver.archivedData(withRootObject: self.mustachePositions, requiringSecureCoding: false)
//      let data: NSData = NSKeyedArchiver.archivedData(withRootObject: self.mustachePositions) as NSData
        return PHAdjustmentData(
            formatIdentifier: MustacheAdjustmentDataFormatIdentifier,
            formatVersion: MustacheAdjustmentDataFormatVersion,
            data: data)
    }
    
  /*
    @MainActor public func applyAdjustment(inputImage: XImage) -> XImage {
      
      let z = ImageRenderer(content: Image(xImage: inputImage))
      z.scale = 2
      let k = z.xImage
      
      
        UIGraphicsBeginImageContextWithOptions(inputImage.size, true, inputImage.scale)
        _ = UIGraphicsGetCurrentContext()
      inputImage.draw(at: CGPointZero)
        
        for mustachePosition in mustachePositions {
          let mustacheImage = self.mustacheImage.rotatedImage(angle: mustachePosition.angle)
          mustacheImage.draw(in: mustachePosition.rect)
            NSLog("Mustache drawed")
        }
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
      return outputImage!
    }
    */
  
    // MARK: - Helper methods
    
    public class func canHandleAdjustmentData(adjustmentData: PHAdjustmentData?) -> Bool {
        if let adjustmentData = adjustmentData {
            return  adjustmentData.formatIdentifier == MustacheAdjustmentDataFormatIdentifier &&
                    adjustmentData.formatVersion == MustacheAdjustmentDataFormatVersion
        }
        return false
    }
    
  private class func mustachePosition(imageSize: CGSize, faceFeature: CIFaceFeature) -> MustachePosition? {
        if !faceFeature.hasMouthPosition { return nil }
        
        let mustacheSize = CGSize(
            width: faceFeature.bounds.width / 1.5,
            height: faceFeature.bounds.height / 5)
        
        let mustacheRect = CGRect(
            x: faceFeature.mouthPosition.x - (mustacheSize.width / 2),
            y: imageSize.height - faceFeature.mouthPosition.y - mustacheSize.height,
            width: mustacheSize.width,
            height: mustacheSize.height)
        
        var mustacheAngle: CGFloat
        if faceFeature.hasFaceAngle {
            mustacheAngle = CGFloat(faceFeature.faceAngle) * CGFloat(3.14) / CGFloat(180.0)
        }
        else {
            mustacheAngle = CGFloat(0)
            NSLog("Mustache angle not found, using \(mustacheAngle)")
        }
        
        return MustachePosition(rect: mustacheRect, angle: mustacheAngle)
    }
    
}
