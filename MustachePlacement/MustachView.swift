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
  
  public var faces : [VNFaceObservation] = []
  let mustacheImage: XImage = XImage(named: "mustache")!

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
  
  func getYOffset(_ xmin : CGFloat, _ xmax: CGFloat ) -> CGFloat {
    let ar : CGFloat = CGFloat(mustacheImage.size.height) / CGFloat(mustacheImage.size.width)
    return ( ( (xmax - xmin) *  ar ) / 2)
  }

  public func defaced() -> CIImage {
    guard var zz = CIImage.init(xImage: image) else { return CIImage() }
    let mi = CIImage.init(xImage: mustacheImage)!
    
    let g = zz.extent.size
    print("faces \(faces.count)")
    for z in faces {
      if let kk = z.landmarks!.outerLips,
      
      let xmin : CGFloat = kk.pointsInImage(imageSize: g).min(by: {$0.x < $1.x})?.x,
      let xmax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.x < $1.x})?.x,
      let ymax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.y < $1.y})?.y,
         let roll = z.roll?.doubleValue {
        
        let s = (xmax-xmin) / mi.extent.size.width

        let origin = CGPoint(x: (xmin+xmax) /  2 - (s * mi.extent.width / 2) , // * (1 - CGFloat(cos(-roll))),
                             y: g.height - ymax - getYOffset(xmin, xmax) + (s * mi.extent.height / 2))
        
        let x1 = kk.normalizedPoints.min(by: {$0.x < $1.x})!
        let x2 = kk.normalizedPoints.max(by: {$0.x < $1.x})!
        
        let angle = atan( (x2.y - x1.y) / (x2.x-x1.x) )
        
        let mi2 = mi
          .transformed(by: CGAffineTransform(scaleX: s, y: s))
          .transformed(by: CGAffineTransform(rotationAngle: angle)) // Angle(radians: -roll).radians))
          .transformed(by: CGAffineTransform(translationX: origin.x, y: g.height - origin.y))
          
        zz = mi2.composited(over: zz)
        
      }
    }
    return zz
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
/*      Image(xImage: imf.image).resizable().scaledToFit()
        .overlay {
          GeometryReader { g in
            overlay(g.size)
          }
        }
 */
      let cij = imf.defaced()
      let cii = imf.defaced()
      Image(xImage: XImage(ciImage: cii) ).resizable().scaledToFit()
    }
  }
}
