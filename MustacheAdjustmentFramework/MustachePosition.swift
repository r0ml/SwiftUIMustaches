//
//  MustachePosition.swift
//  SwiftMustaches
//
//  Created by Dariusz Rybicki on 20/09/14.
//  Copyright (c) 2014 EL Passion. All rights reserved.
//

// import UIKit
import CoreGraphics
import Foundation

public class MustachePosition: NSObject, NSCoding {
    
    public let rect: CGRect
    public let angle: CGFloat
    
    public init(rect: CGRect, angle: CGFloat) {
        self.rect = rect
        self.angle = angle
    }
    
    public required init(coder aDecoder: NSCoder) {
      self.rect = aDecoder.decodeCGRect(forKey: "rect")
      self.angle = aDecoder.decodeObject(forKey: "angle") as! CGFloat
    }
    
    public func encode(with aCoder: NSCoder) {
      aCoder.encode(rect, forKey: "rect")
      aCoder.encode(angle, forKey: "angle")
    }
    
}
