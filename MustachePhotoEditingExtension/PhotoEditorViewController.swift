// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import PhotosUI
import MustacheAdjustmentFramework
import os

let log = Logger()

#if os(macOS)
import AppKit

final class MyHostingController<Content : View> : NSHostingController<Content>, PHContentEditingController {
  var input: PHContentEditingInput?
  var adjustment: MustacheAdjustment?
  var adjustmentAlreadySet: Bool = false
  
  // var backgroundImageView: UIImageView!
  // var photoImageView: Image

  var image: XImage? {
      didSet {
        self.rootView.image = image
      }
  }

  @MainActor override required dynamic init?(coder: NSCoder, rootView: Content) {
    super.init(coder: coder, rootView: rootView)
  }
  
  @MainActor required dynamic init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
      return MustacheAdjustment.canHandleAdjustmentData(adjustmentData: adjustmentData)
    }

  
  func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: XImage) {
        self.input = contentEditingInput
        
        if self.input == nil {
            return
        }
        let input = self.input!
        
      if input.mediaType != .image {
            presentErrorAlertView(message: "Mustaches can only be added to images")
            return
        }
        
        let fullSizeImageUrl = input.fullSizeImageURL!
      let fullSizeImage = XImage(contentsOfFile: fullSizeImageUrl.path)
        
    let ad = input.adjustmentData
    if ad == nil {
    } else {
      adjustment = MustacheAdjustment(adjustmentData: ad!)
    }
        adjustmentAlreadySet = (adjustment != nil)
        
        if adjustmentAlreadySet == false {
            NSLog("Loaded asset WITHOUT adjustment data")
            adjustment = MustacheAdjustment(image: fullSizeImage!)
        }
        else {
            NSLog("Loaded asset WITH adjustment data")
        }
        
        if let adjustment = adjustment {
          image = adjustment.applyAdjustment(inputImage: fullSizeImage!)
        }
        else {
            presentErrorAlertView(message: "Unable to add mustaches")
            image = fullSizeImage
        }
    }

//  func finishContentEditing(completionHandler: @escaping (PHContentEditingOutput?) -> Void) {
//    <#code#>
//  }
  
  func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
    Task.detached {
      let isInputSet = await (self.input != nil)
      let isAdjustmentSet = await (self.adjustment != nil)
      let isMustachePositionSet = await ((self.adjustment?.mustachePositions.count)! > 0)
      let wasAdjustmentAlreadySet = await self.adjustmentAlreadySet
            
      let output = await PHContentEditingOutput(contentEditingInput: self.input!)

            if !isInputSet || !isAdjustmentSet || !isMustachePositionSet || wasAdjustmentAlreadySet {
                NSLog("Nothing changed")
              completionHandler(output)
                return
            }
            
      output.adjustmentData = await self.adjustment!.adjustmentData()
            
      // There is a way to convert this to PNG -- but it goes through tiffRepresentation
      let fullSizeAnnotatedImageData = await self.image!.tiffRepresentation! // Data(compressionQuality: 0.9)!
            
            do {
              try fullSizeAnnotatedImageData.write(to: output.renderedContentURL, options: .atomicWrite)
                NSLog("Saved successfully")
                completionHandler(output)
            }
            catch let error as NSError {
                NSLog("Error when writing file: \(error)")
                completionHandler(nil)
            }
            catch {
                fatalError()
            }
        }
    }

  func cancelContentEditing() {
    <#code#>
  }
  
  var shouldShowCancelConfirmation: Bool
  
  @MainActor private func presentErrorAlertView(message: String) -> Void {
    log.error("\(message)")
    
    /*
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    self.present(alertController, animated: true, completion: nil)
*/
    }

}


#endif


#if os(iOS)
import UIKit
import Photos
import PhotosUI
import MustacheAdjustmentFramework

class PhotoEditorViewController: UIViewController, PHContentEditingController {
  
  

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var input: PHContentEditingInput?
    var adjustment: MustacheAdjustment?
    var adjustmentAlreadySet: Bool = false
    
    var image: UIImage? {
        didSet {
            photoImageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundEffect()
    }
    
    // MARK: - PHContentEditingController

  func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
      return MustacheAdjustment.canHandleAdjustmentData(adjustmentData: adjustmentData)
    }

  func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        self.input = contentEditingInput
        backgroundImageView.image = placeholderImage
        
        if self.input == nil {
            return
        }
        let input = self.input!
        
      if input.mediaType != .image {
            presentErrorAlertView(message: "Mustaches can only be added to images")
            return
        }
        
        let fullSizeImageUrl = input.fullSizeImageURL!
      let fullSizeImage = UIImage(contentsOfFile: fullSizeImageUrl.path)
        
    let ad = input.adjustmentData
    if ad == nil {
    } else {
      adjustment = MustacheAdjustment(adjustmentData: ad!)
    }
        adjustmentAlreadySet = (adjustment != nil)
        
        if adjustmentAlreadySet == false {
            NSLog("Loaded asset WITHOUT adjustment data")
            adjustment = MustacheAdjustment(image: fullSizeImage!)
        }
        else {
            NSLog("Loaded asset WITH adjustment data")
        }
        
        if let adjustment = adjustment {
          image = adjustment.applyAdjustment(inputImage: fullSizeImage!)
        }
        else {
            presentErrorAlertView(message: "Unable to add mustaches")
            image = fullSizeImage
        }
    }

  func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
    Task.detached {
      let isInputSet = await (self.input != nil)
      let isAdjustmentSet = await (self.adjustment != nil)
      let isMustachePositionSet = await ((self.adjustment?.mustachePositions.count)! > 0)
      let wasAdjustmentAlreadySet = await self.adjustmentAlreadySet
            
      let output = await PHContentEditingOutput(contentEditingInput: self.input!)

            if !isInputSet || !isAdjustmentSet || !isMustachePositionSet || wasAdjustmentAlreadySet {
                NSLog("Nothing changed")
              completionHandler(output)
                return
            }
            
      output.adjustmentData = await self.adjustment!.adjustmentData()
            
      let fullSizeAnnotatedImageData = await self.image!.jpegData(compressionQuality: 0.9)!
            
            do {
              try (fullSizeAnnotatedImageData as NSData).write(to: output.renderedContentURL, options: .atomicWrite)
                NSLog("Saved successfully")
                completionHandler(output)
            }
            catch let error as NSError {
                NSLog("Error when writing file: \(error)")
                completionHandler(nil)
            }
            catch {
                fatalError()
            }
        }
    }

    var shouldShowCancelConfirmation: Bool {
        return false
    }

    func cancelContentEditing() {}
    
    // MARK: -
    
    private func setupBackgroundEffect() {
      let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(effectView, aboveSubview: backgroundImageView)
        
      let verticalConstraints = NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[effectView]|",
        options: NSLayoutConstraint.FormatOptions(),
            metrics: nil,
            views: ["effectView": effectView])
      let horizontalConstraints = NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[effectView]|",
        options: NSLayoutConstraint.FormatOptions(),
            metrics: nil,
            views: ["effectView": effectView])
        view.addConstraints(verticalConstraints)
        view.addConstraints(horizontalConstraints)
    }
    
  @MainActor private func presentErrorAlertView(message: String) -> Void {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    self.present(alertController, animated: true, completion: nil)

    }

}
#endif

