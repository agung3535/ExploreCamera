//
//  CameraUIkitService.swift
//  CameraView
//
//  Created by Agung Dwi Saputra on 21/01/24.
//

import AVFoundation
import UIKit


class CameraUIkitService {
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer =  AVCaptureVideoPreviewLayer()
    var delegate: AVCapturePhotoCaptureDelegate?
    
    func checkPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                print("cammera access denied")
                return
            }
            print("access approve")
            self.setupCamera()
            
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        captureSession?.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let captureSession = captureSession else {
            return
        }
        
        do {
            let input =  try AVCaptureDeviceInput(device: captureDevice)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            stillImageOutput = AVCapturePhotoOutput()
            
            guard let output = stillImageOutput else {
                return
            }
            
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            
            previewLayer.session = captureSession
            
            previewLayer.connection?.videoOrientation = .portrait
            
            captureSession.startRunning()
            
        }catch {
            print("error \(error.localizedDescription)")
        }
    }
    
    func captureImage(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        guard let output  = stillImageOutput else {
            return
        }
        output.capturePhoto(with: settings, delegate: delegate!)
    }
    
}
