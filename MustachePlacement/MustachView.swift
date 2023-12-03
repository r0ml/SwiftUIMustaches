// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import Vision

@Observable public class ImageWithFaces {
  public var image : XImage
  { didSet {
    getfaces()
  }
  }
  
  var faces : [VNFaceObservation] = []
  
  public init(image : XImage) {
    self.image = image
    self.getfaces()
  }
  
  func getfaces() {
    guard let jj = CIImage(xImage: image) else {
      faces = []
      log.info("got no faces")
      return
    }
    Task.detached {
      self.faces = (try? await allFaces(in: jj )) ?? []
    }
  }
}

public struct MustachView : View {
  var imf : ImageWithFaces
  
  let mustacheImage: XImage = XImage(named: "mustache")!
  
  public init(imf: ImageWithFaces) {
    self.imf = imf
  }
  
  func getYOffset(_ xmin : CGFloat, _ xmax: CGFloat ) -> CGFloat {
    let ar : CGFloat = CGFloat(mustacheImage.size.height) / CGFloat(mustacheImage.size.width)
    return ( ( (xmax - xmin) *  ar ) / 2)
  }
  
  func overlay(_ g : CGSize) -> some View {
    ForEach(imf.faces, id: \.self) { z in
      if let kk = z.landmarks?.outerLips,
         let xmin : CGFloat = kk.pointsInImage(imageSize: g).min(by: {$0.x < $1.x})?.x,
         let xmax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.x < $1.x})?.x,
         let ymax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.y < $1.y})?.y,
         let roll = z.roll?.doubleValue {
        
        Image(xImage: mustacheImage).resizable().scaledToFit()
          .frame(width: (xmax - xmin)   /* , height: ymax - ymin */ )
          .rotationEffect( Angle(radians: -roll), anchor: .center )
          .position(x: (xmin+xmax) /  2 , // * (1 - CGFloat(cos(-roll))),
                    y: g.height - ymax - getYOffset(xmin, xmax) ) // - (ymax - ymin) / 2)
      }
    }
  }
  
  public var body : some View {
    VStack {
      Image(xImage: imf.image).resizable().scaledToFit()
        .overlay {
          GeometryReader { g in
            overlay(g.size)
          }
        }
    }
  }
}
