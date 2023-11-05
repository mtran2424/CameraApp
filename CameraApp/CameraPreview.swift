//
//  CameraPreview.swift
//  Gaze
//
//  Created by My Tran on 10/13/23.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    // Make camera object in preview
    @ObservedObject var camera: CameraModel
    
    // Implement req. UIViewRepresentable function. Make camera preview view
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                // Setup camera capture session
                camera.preview = AVCaptureVideoPreviewLayer(session: camera.captureSession)
                
                //Fill preview in aspect ratio of device
                camera.preview.videoGravity = .resizeAspectFill
                camera.preview.frame = view.frame
                
                // Place the capture preview to onto layer
                view.layer.addSublayer(camera.preview)
            }
            
            
            
            // Start the camera preview
            camera.captureSession.startRunning()
        }
        
        return view
    }
    
    // Other req. UIRepresentable Function
    func updateUIView(_ uiView: UIView, context: Context) {}
}
