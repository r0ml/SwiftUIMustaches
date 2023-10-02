// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import Vision


public struct MustacheView : View {
  var imageWithFaces : ImageWithFaces
  
  public init(imf: ImageWithFaces) {
    self.imageWithFaces = imf
  }
  
  public var body : some View {
    VStack {
      Image(xImage: imageWithFaces.defacedImage ).resizable().scaledToFit()
    }
  }
}
