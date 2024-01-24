//
//  CustomCameraViewSwiftUI.swift
//  CameraView
//
//  Created by Agung Dwi Saputra on 21/01/24.
//

import SwiftUI


struct CustomCameraViewSwiftUI: View {

    let cameraService = CameraService()
    
    @Binding var capturedImage: UIImage?
    
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            
            CameraViewSwiftUI(cameraService: cameraService) { result in
                switch result {
                case .success(let success):
                    if let data = success.fileDataRepresentation() {
                        capturedImage = UIImage(data: data)
                        presentationMode.wrappedValue.dismiss()
                    }else {
                        
                        print("Error: no image data found")
                    }
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    cameraService.capturePhoto()
                }, label: {
                    Image(systemName: "circle")
                        .font(.system(size: 72))
                        .foregroundColor(.white)
                })
                .padding(.bottom)
                
            }
            
            
        }
    }
}

