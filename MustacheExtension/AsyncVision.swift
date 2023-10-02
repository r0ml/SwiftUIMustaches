// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

/// Converts the Vision Framework face detection into an async/await interface
import Foundation
import CoreImage
import Vision
import os

let log = Logger(subsystem: "Mustache", category: "application")

/// Converts the Vision Framework face detection into an async/await interface
public func allFaces(in cxiImage : CIImage, orientation ornt : CGImagePropertyOrientation = .up) async throws -> [ VNFaceObservation ] {
  
  return try await withCheckedThrowingContinuation(function: "allFaces") { continuation in
    allFaces(in: cxiImage, orientation: ornt) { ims in
      switch ims {
      case .success(let res): continuation.resume(returning: res)
      case .failure(let err): continuation.resume(throwing: err)
      }
    }
  }
}

internal func allFaces(in cxiImage : CIImage, orientation ornt: CGImagePropertyOrientation,
                       _ completion: @escaping (Result<[VNFaceObservation], Error>) -> Void) {
  let treq = VNDetectFaceLandmarksRequest { request, err in
    if let err {
      log.error("\(err.localizedDescription)")
      completion( .failure(err) )
    } else {
      completion( .success(request.results as? [VNFaceObservation] ?? []) )
    }
  }
  treq.revision = VNDetectFaceLandmarksRequestRevision3
  treq.preferBackgroundProcessing = true
  
  let handler = VNImageRequestHandler(ciImage: cxiImage, orientation: ornt, options: [:])
  let reqlist = [ treq ]
  do {
    // This error message happens here:
    //    [espresso] [Espresso::handle_ex_plan] exception=Inconsistent phase of espresso_plan: 0 status=-5
    try handler.perform(reqlist)
  } catch {
    log.error("Could not perform text recognition request: \(error.localizedDescription)")
  }
}
