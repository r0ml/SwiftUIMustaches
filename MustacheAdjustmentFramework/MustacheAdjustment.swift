// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import Photos
// import UIKit
import SwiftUI
import Vision


// Switch to using Vision framework for face detection

// Use the mustache placement info to draw mustaches on the image.  That gets down in ContentView?


let MustacheAdjustmentDataFormatIdentifier = "software.tinker.SwiftMustaches.MustacheAdjustment"
let MustacheAdjustmentDataFormatVersion = "1.0"


public class MustacheAdjustment {
    
    public static let mustacheImage: XImage = XImage(named: "mustache")!
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
    
    @MainActor public init?(image: XImage)  {
      var mustachePositions: [MustachePosition] = []
      var faces : [VNFaceObservation] = []
      
      var semaphore = DispatchSemaphore(value:0)
      Task {
        faces = try! await allFaces(in: CIImage(xImage: image)!)
        semaphore.signal()
      }
      
      semaphore.wait()
      
//        for faceFeature in FaceDetector.detectFaces(inImage: image) {
      for faceFeature in faces {
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
    

    @MainActor public func applyAdjustment(inputImage: XImage) -> XImage {
      
      let v = MView.create(image: inputImage)
      let z = ImageRenderer(content: v)
      z.scale = 2
      
/*
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
 */
      return z.nsImage!
    }
  
  
    // MARK: - Helper methods
    
    public class func canHandleAdjustmentData(adjustmentData: PHAdjustmentData?) -> Bool {
        if let adjustmentData = adjustmentData {
            return  adjustmentData.formatIdentifier == MustacheAdjustmentDataFormatIdentifier &&
                    adjustmentData.formatVersion == MustacheAdjustmentDataFormatVersion
        }
        return false
    }
    
  class func zz(_ xmin : CGFloat, _ xmax: CGFloat ) -> CGFloat {
    let ar : CGFloat = CGFloat(mustacheImage.size.height) / CGFloat(mustacheImage.size.width)
    return ( ( (xmax - xmin) *  ar ) / 2)
  }
  
  private class func mustachePosition(imageSize: CGSize, faceFeature z: VNFaceObservation) -> MustachePosition? {
    
    if let kk = z.landmarks?.outerLips,
       let xmin : CGFloat = kk.pointsInImage(imageSize: imageSize).min(by: {$0.x < $1.x})?.x,
       let xmax : CGFloat = kk.pointsInImage(imageSize: imageSize).max(by: {$0.x < $1.x})?.x,
       
        //          let ymin : CGFloat = kk.pointsInImage(imageSize: g).min(by: {$0.y < $1.y})?.y,
       let ymax : CGFloat = kk.pointsInImage(imageSize: imageSize).max(by: {$0.y < $1.y})?.y,
       let roll = z.roll?.doubleValue {
      //         let yaw = z.yaw?.doubleValue {
      //         let pitch = z.pitch?.doubleValue {
      
      // let mh = (xmax - xmin) * (mustacheImage.size.y / mustacheImage.size.x)
      //        Image(xImage: mustacheImage).resizable().scaledToFit()
      //          .frame(width: (xmax - xmin)   /* , height: ymax - ymin */ )
      //          .rotationEffect( Angle(radians: -roll), anchor: .center )
      // FIXME: if the position is modified after the rotation, the position offsets need to be adjusted for the
      // rotation
      // the adjustment is the cos of the
      //          .position(x: (xmin+xmax) /  2 , // * (1 - CGFloat(cos(-roll))),
      //                    y: g.height - ymax - zz(xmin, xmax) ) // - (ymax - ymin) / 2)
      
      
      
      let mustacheSize = CGSize(
        width: (xmax-xmin) / 1.5,
        height: (xmax - xmin) * imageSize.height / imageSize.width) //      faceFeature.bounds.height / 5)
      
      let mustacheRect = CGRect(
        x: (xmin + xmax) / 2, // faceFeature.mouthPosition.x - (mustacheSize.width / 2),
        y: imageSize.height - ymax - zz(xmin, xmax), //  faceFeature.mouthPosition.y - mustacheSize.height,
        width: mustacheSize.width,
        height: mustacheSize.height)
      
      let mustacheAngle = Angle(radians: -roll)
      
      return MustachePosition(rect: mustacheRect, angle: mustacheAngle)
    }
    return nil
  }
    
}
