//
//  IDCardPhotoView.swift
//  CameraView
//
//  Created by Agung Dwi Saputra on 21/01/24.
//

import AVFoundation
import UIKit

protocol IDCardPhotoDelegate: AnyObject {
    func didPhotoFailed()
    func didPhotoSuccess()
    func didPhotoCancel()
}

class IDCardPhotoView: UIView {
    
    weak var delegate: IDCardPhotoDelegate?
    
    var captureSession: AVCaptureSession?
    
    var imageDataOutput: AVCapturePhotoOutput?
    
    var preview: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialSetup()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension IDCardPhotoView {
    
    func initialSetup() {
        captureSession = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        do {
            
            guard let captureSession = captureSession else {
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            //input
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }else {
                capturePhotoFailed()
                return
            }
            //output
            
            let output = AVCapturePhotoOutput()
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }else {
                capturePhotoFailed()
                return
            }
            
            preview?.videoGravity = .resizeAspectFill
            preview?.session = captureSession
            preview?.connection?.videoOrientation = .portrait
            
            captureSession.startRunning()
            
            self.captureSession = captureSession
            
        }catch {
            capturePhotoFailed()
            return
        }
        
        
    }
    
    func capturePhotoFailed() {
        delegate?.didPhotoFailed()
        captureSession = nil
    }
    
    
}
