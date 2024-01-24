//
//  SwiftUIMain.swift
//  CameraView
//
//  Created by Agung Dwi Saputra on 21/01/24.
//

import SwiftUI

struct SwiftUIMain: View {
    
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    
    var body: some View {
        ZStack {
            
            if capturedImage != nil {
                Image(uiImage: capturedImage!)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }else {
                Color(UIColor.systemBackground)
            }
            
            
            VStack {
                Spacer()
                Button(action: {
                    isCustomCameraViewPresented.toggle()
                }, label: {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .padding()
                        .background(.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                })
                .padding(.bottom)
                .sheet(isPresented: $isCustomCameraViewPresented, content: {
                    CustomCameraViewSwiftUI(capturedImage: $capturedImage)
                })
            }
            
        }
    }
}

#Preview {
    SwiftUIMain()
}
