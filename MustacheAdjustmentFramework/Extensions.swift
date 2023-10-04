// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CoreImage
import Foundation
import SwiftUI

#if os(macOS)
import AppKit

public typealias XImage = NSImage
extension Image {
  public init(xImage: XImage) {
    self.init(nsImage: xImage)
  }
}

extension CIImage {
  
  /// Create a CIImage from an NSImage
  public convenience init?(xImage x : XImage ) {
    if let tiffData = x.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data:tiffData) {
      self.init(bitmapImageRep: bitmap)
    } else {
      return nil
    }
  }
}

#elseif os(iOS)
import UIKit
public typealias XImage = UIImage
extension Image {
  public init(xImage: XImage) {
    self.init(uiImage: xImage)
  }
}

extension CIImage {
  /// Create a ciImage from a UIImage
  public convenience init?(xImage x : XImage) {
    self.init(image: x)
  }
}
#endif
