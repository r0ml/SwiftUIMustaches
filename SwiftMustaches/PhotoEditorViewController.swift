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
    
    @MainActor private func updateUI() {
                let isLoading = loading
                let isSaving = saving
                let isInputSet = (input != nil)
                let isInputModified = (input?.adjustmentData != nil)
      Task {
        await MainActor.run {
          photoImageView.isHidden = !isInputSet
          openBarButtonItem.isEnabled = !isLoading && !isSaving
          saveBarButtonItem.isEnabled = !isLoading && !isSaving && isInputSet && !isInputModified
          revertBarButtonItem.isEnabled = !isLoading && !isSaving && isInputModified
          activityIndicatorContainerView.isHidden = !isLoading && !isSaving
          if isLoading || isSaving {
            activityIndicatorView.startAnimating()
          }
        }
      }
    }
    
  @MainActor private func presentErrorAlertView(message: String) -> Void {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//    self.present(alertController, animated: true)
    }
    
    // MARK: - UI Actions
    
    @IBAction public func openBarButtonItemAction(_ sender: UIBarButtonItem ) {
        openPhoto()
    }
    
    @IBAction func saveBarButtonItemAction(_ sender: UIBarButtonItem) {
        savePhoto()
    }
    
    @IBAction func revertBarButtonItemAction(_ sender: UIBarButtonItem) {
        revertModifications()
    }
    
    // MARK: - Opening photo
    
    public func openPhoto() {
        let imagePicker = UIImagePickerController()
      imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        imagePicker.delegate = self
      
        loading = true
//      present(imagePicker, animated: true)
    }

   @MainActor private func loadAsset(asset: PHAsset?, completion: (() -> Void)?) {
        if asset == nil {
            self.asset = nil
            self.input = nil
            self.adjustment = nil

            if let completion = completion {
                completion()
            }
            
            return
        }
        let asset = asset!
        
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { (adjustmentData) -> Bool in
              return MustacheAdjustment.canHandleAdjustmentData(adjustmentData: adjustmentData)
            }
            
        asset.requestContentEditingInput(with: options, completionHandler: { (input, info) -> Void in
          if let ia = input?.adjustmentData {
                  self.adjustment = MustacheAdjustment(adjustmentData: ia)
                }
                else {
                    self.adjustment = nil
                }
                
                if let _ = self.adjustment {
                    NSLog("Loaded asset WITH adjustment data")
                }
                else {
                    NSLog("Loaded asset WITHOUT adjustment data")
                }
                
                self.asset = asset
                self.input = input
                
                if let completion = completion {
                    completion()
                }
            })
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

    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
      let assetUrlOptional: URL? = info[UIImagePickerController.InfoKey.referenceURL] as? URL
        if assetUrlOptional == nil {
            NSLog("Error: no asset URL")
            loading = false
            return
        }
        let assetUrl = assetUrlOptional!
        
      let fetchResult = PHAsset.fetchAssets( withALAssetURLs: [assetUrl] , options: nil)
        if fetchResult.firstObject == nil {
            NSLog("Error: asset not fetched")
            loading = false
            return
        }
        let asset = fetchResult.firstObject!
        
      if !asset.canPerform(PHAssetEditOperation.content) {
            NSLog("Error: asset can't be edited")
            loading = false
            return
        }
        
//      dismiss(animated: true)
        
      loadAsset(asset: asset, completion: { [weak self] () -> Void in
            self?.loading = false
            return
        })
    }
    
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//      dismiss(animated: true)
        loading = false
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
  @MainActor public func photoLibraryDidChange(_ changeInstance: PHChange) {
            if self.asset == nil {
                return
            }
            
    let changeDetailsForAsset = changeInstance.changeDetails(for: self.asset!)
            if changeDetailsForAsset == nil {
                return
            }
            
            if changeDetailsForAsset!.objectWasDeleted {
                NSLog("PhotoLibrary: Asset deleted")
                self.loading = true
              self.loadAsset(asset: nil, completion: { () -> Void in
                    self.loading = false
                    return
                })
                return
            }
            
            if changeDetailsForAsset!.assetContentChanged {
                if let assetAfterChanges = changeDetailsForAsset!.objectAfterChanges {
                    NSLog("PhotoLibrary: Asset changed")
                    self.loading = true
                  self.loadAsset(asset: assetAfterChanges, completion: { () -> Void in
                    self.loading = false
                        return
                    })
                }
            }
    }
    
}
