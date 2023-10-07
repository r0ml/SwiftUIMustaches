// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import PhotosUI
import Vision


public struct MView : View {
  var originalImage : XImage

  let mustacheImage: XImage = XImage(named: "mustache")!

  var faces : [VNFaceObservation]

  
  @MainActor static public func create(image : XImage) -> MView {
    var ff : [VNFaceObservation] = []
    let semaphore = DispatchSemaphore(value: 0)
    
    Task {
      ff = (try? await allFaces(in: CIImage(xImage: image)! )) ?? []
      semaphore.signal()
    }
    
    semaphore.wait()
    return Self.init(originalImage: image, faces: ff)
  }
  
//  let pevc = PhotoEditorViewController()
  
  public init(originalImage o: XImage, faces f : [VNFaceObservation]) {
    originalImage = o
    faces = f
  }
  
  func zz(_ xmin : CGFloat, _ xmax: CGFloat ) -> CGFloat {
    let ar : CGFloat = CGFloat(mustacheImage.size.height) / CGFloat(mustacheImage.size.width)
    return ( ( (xmax - xmin) *  ar ) / 2)
  }
  
  func overlay(_ g : CGSize) -> some View {
    ForEach(faces, id: \.self) { z in
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
      Image(xImage: originalImage).resizable().scaledToFit()
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
  
  
  /*
  var adjustment: MustacheAdjustment?

  func addMustaches() {
        

            let fullSizeImageUrl = input.fullSizeImageURL!
          let fullSizeImage = UIImage(contentsOfFile: fullSizeImageUrl.path)
            
            if adjustment == nil {
                adjustment = MustacheAdjustment(image: fullSizeImage!)
            }
            
            if adjustment == nil {
                self.presentErrorAlertView(message: "Unable to add mustaches")
                self.saving = false
                return
            }
            
            let output = PHContentEditingOutput(contentEditingInput: input)
      output.adjustmentData = adjustment!.adjustmentData()
            
      let fullSizeAnnotatedImage = adjustment!.applyAdjustment(inputImage: fullSizeImage!)
      let fullSizeAnnotatedImageData = fullSizeAnnotatedImage.jpegData(compressionQuality: 0.9)!
            
            var error: NSError?
            do {
              try fullSizeAnnotatedImageData.write(to: output.renderedContentURL, options: .atomicWrite)
            }
            catch let e as NSError {
                error = e
            }
            catch {
                fatalError()
            }
            
            if let error = error {
              self.presentErrorAlertView(message: "Error when writing file: \(error.localizedDescription)")
                self.saving = false
                return
            }
            
          PHPhotoLibrary.shared().performChanges({ () -> Void in
            let request = PHAssetChangeRequest(for: asset)
                    request.contentEditingOutput = output
                }, completionHandler: { (success, error) -> Void in
                    if !success {
                        self.presentErrorAlertView(message: "Error saving modifications: \(error?.localizedDescription)")
                        self.saving = false
                        return
                    }
                    
                    NSLog("Photo modifications performed successfully")
                    self.saving = false
                })
  }
   */
}

