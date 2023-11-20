// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import PhotosUI
import Vision

struct ContentView : View {
  @Environment(\.openURL) var open
  
  var body : some View {
    VStack {
      Text("This app is merely a holder for the Photos Extension")
      Text("Launch Photos to access the extension")
    }
  }
}

