// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import Vision

@Observable public class ImageWithFaces {
  public var image : XImage
  { didSet {
    self.getFaces()
  }
  }
  
  public var defacedImage : XImage
  
  public var faces : [VNFaceObservation] = []
  let mustacheImage: XImage = XImage(named: "mustache")!

  public init(image : XImage) {
    self.image = image
    self.defacedImage = image
    self.getFaces()
  }
  
  private func getFaces() {
    guard let jj = CIImage(xImage: image) else {
      faces = []
      log.info("got no faces")
      return
    }
    Task.detached {
      self.faces = (try? await allFaces(in: jj )) ?? []
      self.defacedImage = XImage(ciImage: self.defaced() )
    }
  }
  
  private func getYOffset(_ xmin : CGFloat, _ xmax: CGFloat ) -> CGFloat {
    let ar : CGFloat = CGFloat(mustacheImage.size.height) / CGFloat(mustacheImage.size.width)
    return ( ( (xmax - xmin) *  ar * 0.5 ) / 2)
  }

  private func defaced() -> CIImage {
    guard var zz = CIImage.init(xImage: image) else { return CIImage() }
    let mi = CIImage.init(xImage: mustacheImage)!
    
    let g = zz.extent.size
    print("faces \(faces.count)")
    for z in faces {
      if let kk = z.landmarks!.outerLips,
      
      let xmin : CGFloat = kk.pointsInImage(imageSize: g).min(by: {$0.x < $1.x})?.x,
      let xmax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.x < $1.x})?.x,
      let ymax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.y < $1.y})?.y {
        
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
