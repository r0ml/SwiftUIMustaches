// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

/// A Photos extension to put mustaches on faces.  Works on both iOS and macOS
import Photos
import PhotosUI
import SwiftUI

let formatIdentifier = "software.tinker.SwiftUIMustaches"

class PhotoEditingViewController: NSViewController, PHContentEditingController {
  
  var input: PHContentEditingInput?
  
  var imf = ImageWithFaces(image: NSImage() )
  
  override func loadView() {
    self.view = NSHostingView(rootView: MustacheView(imf: imf))
  }
    
  func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
    return false
  }
  
  func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage) {
    input = contentEditingInput
    let fullSizeImageUrl = self.input!.fullSizeImageURL!
    let fullSizeImage = XImage(contentsOfFile: fullSizeImageUrl.path)
    imf.image = fullSizeImage!
  }
  
  func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
    let output = PHContentEditingOutput(contentEditingInput: self.input!)
    
    let zz = imf.defacedImage
    let jpegData = zz.jpegData(compressionQuality: 1)!
    
    do {
      try jpegData.write(to: output.renderedContentURL, options: [.atomic ] )
    } catch(let e) {
      print("*** writing jpeg data: \(e.localizedDescription) ***")
    }
 
    // If the Data is empty (nil or zero bytes), the save will fail
    // Since the mustaches are automatically generated, no metadata needs to be saved
    // so I just put in a few random bytes
    output.adjustmentData = PHAdjustmentData.init(formatIdentifier: formatIdentifier, formatVersion: "1.0", data: Data(count: 10) )
    /*
    if let jad = try? JSONEncoder().encode(self.imf.metadata) {
      output.adjustmentData = PHAdjustmentData.init(formatIdentifier: formatIdentifier, formatVersion: "1.0", data: jad )
    }
     */

    completionHandler(output)
  }
  
  var shouldShowCancelConfirmation: Bool {
    return false
  }
  
  func cancelContentEditing() {
    
  }
  
  
}
