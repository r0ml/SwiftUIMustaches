// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

/// This file contains extension to NSImage and UIImage to make them compatible across platforms as XImage
///
import CoreImage
import Foundation
import SwiftUI

fileprivate let ctx : CIContext = CIContext.init(options: nil)

#if os(macOS)
import AppKit

/// A platform neutral substitute for NSImage or UIImage
public typealias XImage = NSImage
extension Image {
  public init(xImage: XImage) {
    self.init(nsImage: xImage)
  } 
}

extension CIImage {
  
  /// Create a CIImage from an NSImage
  public convenience init?(xImage x : XImage ) {
    if x.size.width > 0 && x.size.height > 0,
      let tiffData = x.tiffRepresentation,
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
  
    /// matches the iOS function to get jpegData
  public func jpegData(compressionQuality: Float) -> Data? {
    let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [.compressionFactor: NSNumber(value: compressionQuality)])
    return jpegData
  }

}

#elseif os(iOS)
import UIKit

/// A platform neutral substitute for NSImage or UIImage
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
