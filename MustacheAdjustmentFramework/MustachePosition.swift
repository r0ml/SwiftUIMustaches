// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CoreGraphics
import Foundation
import SwiftUI

// This is silly, but iOS NSCoder has a `decodeCGRect` method,
// whereas macOS NSCoder does not, ahd has a `decodeRect` mthod which operates
// on NSRect
// So I need two different versions of this.

#if os(iOS)
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
#else

public class MustachePosition: NSObject, NSCoding {
    
    public let rect: NSRect
    public let angle: Angle
    
    public init(rect: CGRect, angle: Angle) {
        self.rect = rect
        self.angle = angle
    }
    
    public required init(coder aDecoder: NSCoder) {
      self.rect = aDecoder.decodeRect(forKey: "rect")
      self.angle = Angle(radians: aDecoder.decodeDouble(forKey: "angle") )
    }
    
    public func encode(with aCoder: NSCoder) {
      aCoder.encode(rect, forKey: "rect")
      aCoder.encode(angle.radians, forKey: "angle")
    }
    
}
#endif

