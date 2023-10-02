// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

#if os(macOS)
typealias XImage = NSImage
extension Image {
  init(xImage: XImage) {
    self.init(nsImage: xImage)
  }
}
#else
typealias XImage = UIImage
extension Image {
  init(xImage: XImage) {
    self.init(uiImage: xImage)
  }
}
#endif

struct ContentView : View {
  @State var originalImage : XImage = XImage()
  let pevc = PhotoEditorViewController()
  
  var body : some View {
    VStack {
      Image(xImage: originalImage).resizable().scaledToFit()
      HStack {
        Button.init(action: {
          print("do the open")
          pevc.openPhoto()
          
        }, label: {
          Text("Open")
        })
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


      }
    }
  }
}
