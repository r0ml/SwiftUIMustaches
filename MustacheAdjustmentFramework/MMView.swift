// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import Vision

@Observable public class IMF {
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
    print("getfaces")
    let semaphore = DispatchSemaphore(value: 0)
    guard let jj = CIImage(xImage: image) else { faces = []; print("got no faces"); return }
    Task.detached {
      print("getting faces")
      self.faces = (try? await allFaces(in: jj )) ?? []
      print("gotting faces")
//      semaphore.signal()
    }
//    semaphore.wait()
    print("gotfaces")
  }
}

public struct MMView : View {
  var imf : IMF
  
  let mustacheImage: XImage = XImage(named: "mustache")!

  public init(imf: IMF) {
    self.imf = imf
  }
  
  func zz(_ xmin : CGFloat, _ xmax: CGFloat ) -> CGFloat {
    let ar : CGFloat = CGFloat(mustacheImage.size.height) / CGFloat(mustacheImage.size.width)
    return ( ( (xmax - xmin) *  ar ) / 2)
  }
  
  func overlay(_ g : CGSize) -> some View {
    ForEach(imf.faces, id: \.self) { z in
      if let kk = z.landmarks?.outerLips,
         let xmin : CGFloat = kk.pointsInImage(imageSize: g).min(by: {$0.x < $1.x})?.x,
         let xmax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.x < $1.x})?.x,

 //       let ymin : CGFloat = kk.pointsInImage(imageSize: g).min(by: {$0.y < $1.y})?.y,
        let ymax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.y < $1.y})?.y,
         let roll = z.roll?.doubleValue {
//         let yaw = z.yaw?.doubleValue {
//         let pitch = z.pitch?.doubleValue {

        // let mh = (xmax - xmin) * (mustacheImage.size.y / mustacheImage.size.x)
        Image(xImage: mustacheImage).resizable().scaledToFit()
          .frame(width: (xmax - xmin)   /* , height: ymax - ymin */ )
          .rotationEffect( Angle(radians: -roll), anchor: .center )
        // FIXME: if the position is modified after the rotation, the position offsets need to be adjusted for the
        // rotation
        // the adjustment is the cos of the
          .position(x: (xmin+xmax) /  2 , // * (1 - CGFloat(cos(-roll))),
                    y: g.height - ymax - zz(xmin, xmax) ) // - (ymax - ymin) / 2)
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
    
      /*
       .onChange(of: thePhoto) {
//        print(thePhoto?.itemIdentifier)
        Task {
          if let data = try! await thePhoto?.loadTransferable(type: Data.self) {
            if let xImage = XImage(data: data) {
              originalImage = xImage
              faces = (try? await allFaces(in: CIImage(xImage: originalImage)! )) ?? []
              return
            } else {
              print("Why did I fail?")
            }
            
            print("Failed")
          }
        }
      }
      */
    
    }
  }
  
  

}
