// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import PhotosUI
import MustacheAdjustmentFramework
import Vision

/*
#if os(macOS)
public typealias XImage = NSImage
extension Image {
  init(xImage: XImage) {
    self.init(nsImage: xImage)
  }
}
#else
public typealias XImage = UIImage
extension Image {
  init(xImage: XImage) {
    self.init(uiImage: xImage)
  }
}
#endif
*/

struct ContentView : View {
  @State var originalImage : XImage = XImage()
  @State var thePhoto : PhotosPickerItem?
  
  let mustacheImage: XImage = XImage(named: "mustache")!

  @State var faces : [VNFaceObservation] = []
  
//  let pevc = PhotoEditorViewController()
  
  func zz(_ xmin : CGFloat, _ xmax: CGFloat ) -> CGFloat {
    let ar : CGFloat = CGFloat(mustacheImage.size.height) / CGFloat(mustacheImage.size.width)
    return ( ( (xmax - xmin) *  ar ) / 2)
  }
  
  func overlay(_ g : CGSize) -> some View {
    ForEach(faces, id: \.self) { z in
      if let kk = z.landmarks?.outerLips,
         let xmin : CGFloat = kk.pointsInImage(imageSize: g).min(by: {$0.x < $1.x})?.x,
         let xmax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.x < $1.x})?.x,

        let ymin : CGFloat = kk.pointsInImage(imageSize: g).min(by: {$0.y < $1.y})?.y,
        let ymax : CGFloat = kk.pointsInImage(imageSize: g).max(by: {$0.y < $1.y})?.y,
         let roll = z.roll?.doubleValue,
         let yaw = z.yaw?.doubleValue {
        //  let pitch = z.pitch?.doubleValue {

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
  
  var body : some View {
    VStack {
      Image(xImage: originalImage).resizable().scaledToFit()
        .overlay {
          GeometryReader { g in
            overlay(g.size)
          }
        }
      HStack {
        // Need the photoLibrary to get the itemIdentifier when picked to get the PHAsset for changes
        PhotosPicker("Select avatar", selection: $thePhoto, matching: .images,
                     photoLibrary: PHPhotoLibrary.shared() )
          // .photosPickerStyle(.inline)
          
/*
        
        Button.init(action: {
          print("do the open")
          pevc.openPhoto()
          
        }, label: {
          Text("Open")
        })
 */
        Spacer()
        
        Button.init(action: {
          print("mustachify")
          Task {
            faces = (try? await allFaces(in: CIImage(xImage: originalImage)! )) ?? []
          }
        }, label: {
          Text("Mustachify")
        })
        Button.init(action: {
          print("shave")
        }, label: {
          Text("Shave")
        })


      }.onChange(of: thePhoto) {
//        print(thePhoto?.itemIdentifier)
        Task {
          if let data = try! await thePhoto?.loadTransferable(type: Data.self) {
            if let xImage = XImage(data: data) {
              originalImage = xImage
              return
            } else {
              print("Why did I fail?")
            }
            
            print("Failed")
          }
        }
      }
    
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


extension CIImage {
#if os(macOS)
  /// Create a CIImage from an NSImage
public convenience init?(xImage x : XImage ) {
  if let tiffData = x.tiffRepresentation,
     let bitmap = NSBitmapImageRep(data:tiffData) {
    self.init(bitmapImageRep: bitmap)
  } else {
    return nil
  }
}
#endif

#if os(iOS)
  /// Create a ciImage from a UIImage
  public convenience init?(xImage x : XImage) {
    self.init(image: x)
  }
#endif


}
