//
//  CameraModel.swift
//  Gaze
//  Created by My Tran on 10/13/23.
//
import AVFoundation
import SwiftUI

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    // Capture session variables
    @Published var isTaken = false
    @Published var captureSession = AVCaptureSession()
    @Published var alert = false
    
    // Output preview variables
    @Published var output = AVCapturePhotoOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    @Published var inputDevice : AVCaptureDeviceInput!
    
    // Saved picture data variables
    @Published var isSaved = false
    @Published var pictureData = Data(count: 0)
    @Published var capturedImage : UIImage? = nil
    
    // Indications for mode of operations
    var isFlipped = true
    var isFlash = false
    var isLive = false
    
    // Unset Saved data
    func UnsetCaptured() {
        DispatchQueue.main.async {
            self.isSaved = false
            self.isTaken = false
            self.isFlipped = true
            self.isFlash = false
            self.isLive = false
            self.captureSession = AVCaptureSession()
            self.capturedImage = UIImage()
            self.pictureData = Data(count: 0)
        }
    }// End UnsetCaptured
    
    // Check user authorizations for device component access
    func CheckAuthorization() {
        DispatchQueue.main.async {
            // Check for authorization from device
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:   // Permission is given
                // Setup camera if permission is already given
                self.SetUp()
                return
            case .notDetermined:    // Permission TBD
                // ask for permission if not determined already
                AVCaptureDevice.requestAccess(for: .video) { (status) in
                    // Setup camera if permission is given
                    if status {
                        self.SetUp()
                    }
                }
            case .denied:   // Permission denied
                self.alert.toggle()
                return
            default:
                return
            }
            
        }
    }// End CheckAuthorization function
    
    // Perform setup for on device camera
    func SetUp() {
        // Setup for camera does not need to be on main thread but needs to happen fast
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                // Config camera device to have access to built in camera on device
                self.captureSession.beginConfiguration()
                
                // Look matching devices with back cam
                let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
                    [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                    mediaType: .video, position: .back)
                
                // Get list of available capture devices for video
                let devices = discoverySession.devices
                
                // Set device if there is one
                let device = devices.first(where: {$0.position == .back})
                
                // Take input from the device if such a device exists
                let input = try AVCaptureDeviceInput(device: device!)
                
                // Use device created earlier for input if there is one
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                }
                
                // Output to output variable declared in class
                if self.captureSession.canAddOutput(self.output) {
                    self.captureSession.addOutput(self.output)
                }
                
                self.captureSession.commitConfiguration()
            }
            catch {
                // Print error if encountered in setup
                print(error.localizedDescription)
            }
        }
        
    }// End SetUp
    
    // Function to take picture capture. Terminates to void function upon completion
    func TakePicture(completion: @escaping () -> Void) {
        // Taking picture does not need to be on main thread
        DispatchQueue.global(qos: .background).async {
            // Configure capture settings in settings object
            let photoSettings = AVCapturePhotoSettings()
            
                
            // Set pixel format
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            
            // Set quality priority
            photoSettings.photoQualityPrioritization = .balanced
            
            // Toggle the taken variable indicating the photo has been captured
            DispatchQueue.main.async {
                self.isTaken.toggle()
            }
            
            // Toggle flash on for picture capture
            photoSettings.flashMode = self.isFlash ? .on : .off
            
            self.output.capturePhoto(with: photoSettings, delegate: self)
            
            // Making the stopping of the capture user require immediate action
            DispatchQueue.global(qos: .userInitiated).async {
                // Wait a little extra after capture if flash to account for extra capture time
                if self.isFlash {
                    sleep(2)
                }
                
                // Stop the capture session once capture is taken
                DispatchQueue.main.async {
                    self.captureSession.stopRunning()
                    completion()
                }
            }
            
        }
    }// End of TakePicture
    
    // Turn on/off flash option
    func toggleFlash() {
        // turn flash setting on/off. Used in TakePicture
        isFlash.toggle()
    }// End toggleFlash
    
    // Change camera input from user input
    func FlipCamera() {
        // Operation of camera flip does not need to be on main thread
        DispatchQueue.global(qos: .userInitiated).async {
            // If flipped is on, front camera mode is on
            if self.isFlipped {
                do {
                    //https://developer.apple.com/documentation/avfoundation/capture_setup/choosing_a_capture_device
                    // Find devices available
                    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
                                                                                [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                                            mediaType: .video, position: .front)
                    
                    // Get list of available capture devices for video
                    let devices = discoverySession.devices
                    
                    // Create front camera object if device is found
                    let device = devices.first(where: {$0.position == .front})
                    
                    // make input device front camera and set that as session input
                    let input = try AVCaptureDeviceInput(device: device!)
                    
                    // Remove input device if there is one to be replaced on front camera
                    if let currentInput = self.captureSession.inputs.first as? AVCaptureDeviceInput {
                        self.captureSession.removeInput(currentInput)
                    }
                    
                    // Add front camera input device if possible
                    if self.captureSession.canAddInput(input) {
                        self.captureSession.addInput(input)
                    }
                    
                    // toggle flip camera
                    self.isFlipped.toggle()
                }
                catch {
                        // Print error
                        print(error.localizedDescription)
                }
            }
            // Back camera is on otherwise
            else {
                do {
                    // Look matching devices with back cam
                    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
                        [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                        mediaType: .video, position: .back)
                    
                    // Get list of available capture devices for video
                    let devices = discoverySession.devices
                    
                    let device = devices.first(where: {$0.position == .back})
                    
                    // Take input from the device if such a device exists
                    let input = try AVCaptureDeviceInput(device: device!)
                    
                    // Remove input device if there is one to be replaced on front camera
                    if let currentInput = self.captureSession.inputs.first as? AVCaptureDeviceInput {
                        self.captureSession.removeInput(currentInput)
                    }
                    
                    // Add front camera input device if possible
                    if self.captureSession.canAddInput(input) {
                        self.captureSession.addInput(input)
                    }
                    
                    // toggle flip camera
                    self.isFlipped.toggle()
                }
                catch {
                    // Print error
                    print(error.localizedDescription)
                }
            }
        }
    } // End flip camera
    
    // Create photo output
    func photoOutput (_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Check for erroneous output
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // Output indication of successfully taken photo
        print("Photo taken")
        self.pictureData = photo.fileDataRepresentation()!
        
        // Assign member the captured image
        self.capturedImage = UIImage(data: self.pictureData)!
    }// End photo output
    
    // Save the image to Photo library on device
    func SavePicture() {
        //Saving image
        UIImageWriteToSavedPhotosAlbum(capturedImage!, nil, nil, nil)
        
        // Indicate that the image as been saved
        self.isSaved = true
        print("Save success")
    }// End SavePicture
    
    // User initiated Retake
    func RetakePicture() {
        // Restart the capture session to get the preview going again
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            
            // Undo is taken and the image was not saved
            DispatchQueue.main.async {
                self.isTaken = false
                self.isSaved = false
                
                // Unset previously captured image
                self.capturedImage = UIImage()
                self.pictureData = Data(count: 0)
            }
        }
    }
    
}// End class
