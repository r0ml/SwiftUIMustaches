// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import PhotosUI
import MustacheAdjustmentFramework

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
//  let pevc = PhotoEditorViewController()
  
  var body : some View {
    VStack {
      Image(xImage: originalImage).resizable().scaledToFit()
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
}
