//
//  FaceDetector.swift
//  SwiftMustaches
//
//  Created by Dariusz Rybicki on 21/09/14.
//  Copyright (c) 2014 EL Passion. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

import CoreImage

public class FaceDetector {
    
    class func detectFaces(inImage image: XImage) -> [CIFaceFeature] {
        let detector = CIDetector(
            ofType: CIDetectorTypeFace,
            context: nil,
            options: [
                CIDetectorAccuracy: CIDetectorAccuracyHigh,
                CIDetectorTracking: false,
                CIDetectorMinFeatureSize: NSNumber(value: 0.1)
            ])
        
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        _ = UIGraphicsGetCurrentContext()
      image.draw(at: CGPointZero)
      let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage!
      let ciImage = CIImage(cgImage: cgImage!)
        UIGraphicsEndImageContext()
        
      let features = detector!.features(
        in: ciImage,
            options: [
              CIDetectorImageOrientation: UIImage.orientationPropertyValueFromImageOrientation(imageOrientation: .up),
                CIDetectorEyeBlink: false,
                CIDetectorSmile: false
            ])
        
        NSLog("Detected faces count: \(features.count)")
        
        return features as! [CIFaceFeature]
    }
    
}
