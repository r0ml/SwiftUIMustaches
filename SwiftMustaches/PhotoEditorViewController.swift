//
//  PhotoEditorViewController.swift
//  SwiftMustaches
//
//  Created by Dariusz Rybicki on 18/09/14.
//  Copyright (c) 2014 EL Passion. All rights reserved.
//

import UIKit
import Photos
import MustacheAdjustmentFramework

public class PhotoEditorViewController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver {

    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var openBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var revertBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var activityIndicatorContainerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @MainActor var input: PHContentEditingInput? {
        didSet {
          if let fsiu = input?.fullSizeImageURL,
             let fsi = UIImage(contentsOfFile: fsiu.path) {
            self.photoImageView.image = fsi
          } else {
            self.photoImageView.image = nil
          }
          if let input, let pii = self.photoImageView.image, let ia = input.adjustmentData {
                      adjustment = MustacheAdjustment(adjustmentData: ia)
                        if let _ = adjustment {
                          photoImageView.image = adjustment!.applyAdjustment(inputImage: pii)
                    }
                
            }
            else {
              self.adjustment = nil
            }
            updateUI()
        }
    }
    
    var asset: PHAsset?
    
    private var loading: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    private var saving: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    var adjustment: MustacheAdjustment?
    
    // MARK: - UI
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
      return UIStatusBarStyle.lightContent
    }
    
    public func viewDidLoad() {

        activityIndicatorContainerView.layer.cornerRadius = 10
        updateUI()
      PHPhotoLibrary.shared().register(self)
    }
      
    
    @IBAction func saveBarButtonItemAction(_ sender: UIBarButtonItem) {
        savePhoto()
    }
    
    @IBAction func revertBarButtonItemAction(_ sender: UIBarButtonItem) {
        revertModifications()
    }
    
    // MARK: - Saving photo
    
    @MainActor private func savePhoto() {
        if self.input == nil {
            presentErrorAlertView(message: "Can't save, no input")
            return
        }
        let input = self.input!
        
        if self.asset == nil {
            presentErrorAlertView(message: "Can't save, no asset")
            return
        }
        let asset = self.asset!
        
        var adjustment = self.adjustment
        
        saving = true
        

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
    
    // MARK: - Reverting modifications
    
    private func revertModifications() {
        if self.input == nil {
            presentErrorAlertView(message: "Can't revert, no input")
            return
        }
        
        if self.asset == nil {
            presentErrorAlertView(message: "Can't revert, no asset")
            return
        }
        let asset = self.asset!
        
        saving = true
        
      PHPhotoLibrary.shared().performChanges({ () -> Void in
        let request = PHAssetChangeRequest(for: asset)
            request.revertAssetContentToOriginal()
        }, completionHandler: { [weak self] (success, error) -> Void in
            if !success {
                self?.presentErrorAlertView(message: "Error reverting modifications: \(error?.localizedDescription)")
                self?.saving = false
                return
            }
            
            NSLog("Photo modifications reverted successfully")
            self?.saving = false
        })
    }

}
