// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import MustacheAdjustmentFramework


// FIXME: instead of using Vision framework, this file / function implements the face identification by
// using a core image filter.

// display an image with mustaches

#if os(macOS)
extension ImageRenderer {
  @MainActor var xImage : XImage? { get { return self.nsImage}}
}
#else
extension ImageRenderer {
  @MainActor var xImage : XImage? { get { return self.uiImage}}
}
#endif

let MustacheAdjustmentDataFormatIdentifier = "software.tinker.SwiftMustaches.MustacheAdjustment"
let MustacheAdjustmentDataFormatVersion = "1.0"


public func computeMustachePosition(_ faceFeature : CIFaceFeature, size imageSize: CGSize) -> MustachePosition? {
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


public func computeMustaches(_ image : XImage) -> [MustachePosition] {
  return FaceDetector.detectFaces(inImage: image).compactMap { computeMustachePosition( $0, size: image.size) }

}


// a function using Vision to find all the faces




struct MustacheView : View {
  var image : XImage
  
  var body: some View {
    Image(xImage: image).resizable().scaledToFit()
      .task {
        // calculate the mustaches here
      }
  }
}
