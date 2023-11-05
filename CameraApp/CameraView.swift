//
//  CameraView.swift
//  Gaze
//
//  Created by My Tran on 9/29/23.
//
//  Contributors:
//  Thomas Lloyd-Jones
//  Myles Jeune
//  Gregory Vincent
//

import SwiftUI

// Remember to go into project info and add 'privacy - camera usage description' for camera to work

struct CameraView: View {
    // Option state variables that determine mode of operation of camera
    @State var isTaken = false
    @State var isConfirmed = false
    @State var isFlashOn = false
    @State var isLiveOn = false
    @State var isSaved = false
    
    @ObservedObject var camera : CameraModel
    var body: some View {
        ZStack {
            // Set the camera preview as the background of the camera view
            if !isTaken {
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
            }
            // Once the picture is taken, display that instead of the frozen preview
            else {
                if let image = camera.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .ignoresSafeArea(.all)
                }
            }
            
            // Camera screen stack
            VStack {
                if !isTaken {
                    // Top Cluster includes flash and live photo toggles
                    VStack {
                        HStack {
                            // Flash toggle for turning on/off flash
                            FlashButton(isFlashOn: $isFlashOn, camera: camera)
                                .padding(.leading)
                            
                            Spacer()
                            
                            // Live photo toggle to pick between instant photo or live photo
                            LiveButton(isLiveOn: $isLiveOn)
                                .padding(.trailing)
                        }
                    }.frame(width: UIScreen.main.bounds.width, height: 0.04*UIScreen.main.bounds.height)
                        .background(Color.black.opacity(0.65))
                    // End camera top cluster
                }
                else {
                    // Top cluster for preview
                    VStack {
                        HStack {
                            // UI Back Button
//                            BackButton(isModeSelection: $isModeSelection,
//                                       isCamera: $isCamera,
//                                       camera: camera)
//                            .padding(.leading)
                            
                            Spacer()
                        }
                    }.frame(width: UIScreen.main.bounds.width, height: 0.04*UIScreen.main.bounds.height)
                        .background(Color.black.opacity(0.65))
                    // End camera bottom cluster
                }
                
                Spacer()
                
                // Bottom Button Cluster
                VStack {
                    // If the photo has not been taken, we need a shutter button, and a toggle front/back camera
                    if !isTaken {
                        HStack {
                            // Left side buttons
                            VStack {
                                // UI Back Button
                                Spacer()
//                                BackButton(isModeSelection: $isModeSelection,
//                                           isCamera: $isCamera,
//                                           camera: camera)
                                
                            }.frame(width: 0.33*UIScreen.main.bounds.width, height: 0.12*UIScreen.main.bounds.height)
                            
                            Spacer()
                            
                            // Center buttons
                            VStack {
                                Spacer()
                                // Select media capture type. Only photos for now.
//                                Button(action: {}, label: {
//                                    Text("Photo")
//                                        .font(.system(
//                                            size: 20,
//                                            weight:.medium,
//                                            design: .default))
//                                        .padding()
//                                        .foregroundColor(.yellow)
//                                }).padding(.top)
                                
                                Spacer()
                                
                                // Shutter button toggles taken to switch to confirmation/retake button cluster
                                Button(action: {
                                    isTaken = true
                                    camera.TakePicture{}
                                },label:{
                                    ShutterButton()
                                }).padding(.bottom)
                                Spacer()
                                
                            }.frame(width: 0.33*UIScreen.main.bounds.width, height: 0.12*UIScreen.main.bounds.height)
                            
                            Spacer()
                            
                            // Right side buttons
                            VStack {
                                Spacer()
                                
                                // Toggle front/back camera
                                Button(action: {
                                    camera.FlipCamera()
                                }, label: {
                                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color.white)
                                }).padding()
                                
                            }.frame(width: 0.33*UIScreen.main.bounds.width, height: 0.12*UIScreen.main.bounds.height)
                            
                            Spacer()
                        }
                    }
                    // View once photo has been taken
                    else {
                        HStack {
                            // Retake button toggles taken to get other button cluster back
                            Button(action: {
                                isTaken = false
                                isSaved = false
                                camera.RetakePicture()
                                
                            }, label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                            })
                            .padding()
                            
                            Spacer()
                            
//                            Confirm photo button returns to selection menu for now
                            ConfirmImageButton(camera: camera, isSaved: $isSaved)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .clipShape(Capsule())
                            .padding(.trailing)
                        }
                    }
                }.frame(width: UIScreen.main.bounds.width, height: 0.12*UIScreen.main.bounds.height)
                    .background(Color.black.opacity(0.65))
                    .lineSpacing(50)
                // end of buttom button cluster
            } // end of camera view stack
        }
    }
}

//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        //CameraView()
//        Text("Hi")
//    }
//}

// Custom shutter button on camera
struct ShutterButton : View {
    var body : some View {
        ZStack {
            // Outside circle
            Circle()
                .strokeBorder(.white, lineWidth: 4)
                .frame(width: 65, height: 65)
            //Inside circle
            Circle()
                .fill(.white)
                .frame(width: 50, height: 50)
            
        }
    }
}// End shutter button

// Flash toggle
struct FlashButton : View {
    @Binding var isFlashOn : Bool
    @ObservedObject var camera : CameraModel
    
    var body : some View {
        Button(action: {
            isFlashOn.toggle()
            camera.toggleFlash()
        }, label: {
            Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .resizable()
                .frame(width: 20, height: 30)
                .foregroundColor(Color.white)
        })
        .padding(.bottom)
    }// End body
}// End FlashButton

// Live Photo Toggle
struct LiveButton : View {
    @Binding var isLiveOn : Bool
    
    var body: some View {
        Button(action: {
            isLiveOn.toggle()
        }, label: {
            Image(systemName: isLiveOn ? "livephoto" : "livephoto.slash")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Color.white)
        }).padding(.bottom)
    }// End body
}// End LiveButton

// Flash toggle
struct BackButton : View {
    @Binding var isModeSelection : Bool
    @Binding var isCamera : Bool
    @ObservedObject var camera : CameraModel
    
    var body : some View {
        // UI Back Button
        Button(action: {
            isModeSelection.toggle()
            isCamera.toggle()
            camera.UnsetCaptured()
        }, label: {
            Text("Back")
                .font(.system(
                    size: 20,
                    weight:.light,
                    design: .default))
                .padding()
                .foregroundColor(.yellow)
        }).padding(.bottom)
    }// End body
}// End BackButton

// Confirming image redirects to GazeAnalysis
struct ConfirmImageButton : View {
    // Toggling view variables
    @ObservedObject var camera : CameraModel
    
    @Binding var isSaved : Bool
    
    var body: some View {
        Button(action: {
            if !isSaved {
                camera.SavePicture()
                isSaved = true
            }
        }, label: {
            Text("Use Photo")
                .font(.system(
                    size: 20,
                    weight:.semibold,
                    design: .default))
        })
    }// End body
}// End ConfirmImageButton
