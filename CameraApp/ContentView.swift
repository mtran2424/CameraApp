//
//  ContentView.swift
//  CameraApp
//
//  Created by My Tran on 11/2/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var camera = CameraModel()
    var body: some View {
        CameraView(camera: camera)
            .onAppear(perform: {
            // Upon appearance of camera, check permissions or request them
            camera.CheckAuthorization()
        })
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
