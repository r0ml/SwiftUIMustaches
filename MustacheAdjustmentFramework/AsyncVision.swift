// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import CoreImage
import Vision
import os

let log = Logger(subsystem: "Mustache", category: "application")

public func allFaces(in cxiImage : CIImage, orientation ornt : CGImagePropertyOrientation = .up) async throws -> [ VNFaceObservation ] {
  /// This will be the resulting array
  /// For additional metadata, use a structure which contains the resulting image, as well as the rectangle, so I can evaluate the amount of skew
  
    
  return try await withCheckedThrowingContinuation(function: "allFaces") { continuation in
    allFaces(in: cxiImage, orientation: ornt) { ims in
        switch ims {
        case .success(let res): continuation.resume(returning: res)
        case.failure(let err): continuation.resume(throwing: err)
        }
      }
    }
  
}

internal func allFaces(in cxiImage : CIImage, orientation ornt: CGImagePropertyOrientation,
                      _ completion: @escaping (Result<[VNFaceObservation], Error>) -> Void) {
    let treq = VNDetectFaceLandmarksRequest { request, err in
//      print("handler performing")
    if let err {
      log.error("\(err.localizedDescription)")
      completion( .failure(err) )
    } else {
      completion( .success(request.results as? [VNFaceObservation] ?? []) )
//      print("allText completion")
    }
  }
  treq.revision = VNDetectFaceLandmarksRequestRevision3
  treq.preferBackgroundProcessing = true
  
  // FIXME: I could do the three orientations here.
  let handler = VNImageRequestHandler(ciImage: cxiImage, orientation: ornt, options: [:])
  let reqlist = [ treq ]
  do {
//    print("handler perform")

    // This error message happens here:
    //    [espresso] [Espresso::handle_ex_plan] exception=Inconsistent phase of espresso_plan: 0 status=-5
    try handler.perform(reqlist)
  } catch {
    log.error("Could not perform text recognition request: \(error.localizedDescription)")
  }
}
