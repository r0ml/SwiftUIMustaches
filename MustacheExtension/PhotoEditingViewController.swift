// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Cocoa
import Photos
import PhotosUI
import SwiftUI
import MustacheAdjustmentFramework
import os

let log = Logger()

class PhotoEditingViewController: NSViewController, PHContentEditingController {

    var input: PHContentEditingInput?

  var imf = IMF(image: NSImage() )
  
  
  override func loadView() {
    print("loadView")
//    self.view = NSHostingView(rootView: Text("say what?"))
    //      hc.sizingOptions = .maxSize
    //    self.addChild(hc)
    self.view = NSHostingView(rootView: MMView(imf: imf))
    print("loadedView")
  }
  
  
    override func viewDidLoad() {
      print("viewDidLoad")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - PHContentEditingController

    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
      print("canHandle")
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
      print("startContentEditing")
        input = contentEditingInput
      print("eleven")
//      let rv = Text("Hello, World!").font(.system(size: 200))
//      let rvv = NSHostingView(rootView: rv.position(x: 1000, y: 10))
//      rvv.setFrameSize(CGSize(width: 2400, height: 200))
  
      let semaphore = DispatchSemaphore(value: 0)
      print("twelve")
      print("one")
      let fullSizeImageUrl = self.input!.fullSizeImageURL!
      print("two")
      let fullSizeImage = XImage(contentsOfFile: fullSizeImageUrl.path)

      imf.image = fullSizeImage!
      
      /*
//      Task.detached {
        DispatchQueue.global().async {
          Task.detached {
            print("thirteenn")
            
            print("three")
            let ii = Image(xImage: fullSizeImage!).resizable().scaledToFit()
            print("four")
            let jj = await MView.create(image: fullSizeImage!).frame(width: 800, height: 600)
            print("five")
            //        let hv = NSHostingController(rootView: jj)
            let hv = await NSHostingView(rootView: jj)
            print("six")
            //        hv.setFrameSize(CGSize(width: 800, height: 600))
            
            //        self.addChild(hv)
            await self.view.addSubview( hv )
            print("seven")
            //        self.viewDidLoad()
            //        self.view.addSubview( hv)
            
            //        self.view.addSubview( rvv )
            semaphore.signal()
            print("eight")
          }
      }
      semaphore.wait()
       */
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
      print("finishContentEditing")
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            // Provide new adjustments and render output to given location.
            // output.adjustmentData = <#new adjustment data#>
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }

    var shouldShowCancelConfirmation: Bool {
      print("shouldShowCancelConfirmation")
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }

    func cancelContentEditing() {
      print("cancelContentEditing")
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }

}
