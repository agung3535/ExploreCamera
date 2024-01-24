//
//  CameraViewSwiftUI.swift
//  CameraView
//
//  Created by Agung Dwi Saputra on 21/01/24.
//

import AVFoundation
import SwiftUI


struct CameraViewSwiftUI: UIViewControllerRepresentable {
   
    
    
    typealias UIViewControllerType = UIViewController
    
    let cameraService: CameraService
    
    let didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        cameraService.start(delegate: context.coordinator) { err in
            if let err = err {
                didFinishProcessingPhoto(.failure(err))
                return
            }
        }
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        viewController.view.layer.addSublayer(cameraService.preview)
        cameraService.preview.frame = viewController.view.bounds
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            parent: self,
            didFinishProcessingPhoto: didFinishProcessingPhoto)
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        let parent: CameraViewSwiftUI
        private var didFinishProcessingPhoto: (Result<AVCapturePhoto, Error>) -> Void
        
        init(parent: CameraViewSwiftUI,
             didFinishProcessingPhoto: @escaping (Result<AVCapturePhoto, Error>) -> Void) {
            self.parent = parent
            self.didFinishProcessingPhoto = didFinishProcessingPhoto
        }
        
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                didFinishProcessingPhoto(.failure(error))
                return
            }
            
            didFinishProcessingPhoto(.success(photo))
        }
    }
    
}
