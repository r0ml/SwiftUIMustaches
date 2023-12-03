// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Cocoa
import Photos
import PhotosUI
import SwiftUI
import os

class PhotoEditingViewController: NSViewController, PHContentEditingController {
  
  var input: PHContentEditingInput?
  
  var imf = ImageWithFaces(image: NSImage() )
  
  
  override func loadView() {
    self.view = NSHostingView(rootView: MustachView(imf: imf))
  }
  
  // MARK: - PHContentEditingController
  
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
    output.adjustmentData = PHAdjustmentData()
    
    let zz = imf.defaced()
    
    completionHandler(output)
  }
  
  var shouldShowCancelConfirmation: Bool {
    return false
  }
  
  func cancelContentEditing() {
  }
}
