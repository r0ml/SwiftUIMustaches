// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import CoreImage
import Foundation
import SwiftUI

fileprivate let ctx : CIContext = CIContext.init(options: nil)

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

extension NSImage {
  /// Create an NSImage from a CIImage
  public convenience init(ciImage ci: CIImage ) {
    if let cg = ctx.createCGImage(ci, from: ci.extent) {
      self.init(cgImage: cg, size: CGSize(width: cg.width, height: cg.height))
      return
    }
    self.init(size: ci.extent.size)
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

extension UIImage {
  /// Create a UIImage from a CIImage
  public convenience init(ciImage ci: CIImage) {
    if let cg = ctx.createCGImage(ci, from: ci.extent) {
      self.init(cgImage: cg)
      return
    }
    fatalError("creating UIImage from CIImage")
  }
}

#endif

extension XImage : @unchecked Sendable {}
