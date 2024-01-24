//
//  ViewController.swift
//  CameraView
//
//  Created by Agung Dwi Saputra on 20/01/24.
//

import UIKit
import AVFoundation
import SwiftUI

class DefaultCaptureSession: UIViewController {
    
    private lazy var imgView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "house.fill")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
//    private lazy var customCameraView: UIView = {
//
//    }
    
    private lazy var openCamera: UIButton = {
        let view = UIButton()
        view.setTitle("Open Camera", for: .normal)
        view.isUserInteractionEnabled = true
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pickGallery: UIButton = {
        let view = UIButton()
        view.setTitle("Pick from gallery", for: .normal)
        view.isUserInteractionEnabled = true
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cropBtn: UIButton = {
        let view = UIButton()
        view.setTitle("Crop", for: .normal)
        view.isUserInteractionEnabled = true
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var boxView: UIView = {
        let view = UIView(frame: CGRect(x: 195, y: 422, width: 300, height: 200))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        return view
    }()
    
    
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let vc = CameraVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        setupConstraint()
//        checkPermission()
        print("navigation = \(self.navigationController)")
        print("position x: \(view.bounds.midX) dan y: \(view.bounds.midY)")
        vc.didFinishPhoto = { result in
            switch result {
                
            case .success(let image):
                self.imgView.image = image
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func checkPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                print("camera access denied")
                return
            }
            self.setupCamera()
        }
    }

    
    private func setupView() {
        view.addSubview(imgView)
        view.addSubview(openCamera)
        view.addSubview(pickGallery)
        view.addSubview(cropBtn)
//        view.addSubview(boxView)
        
        
        openCamera.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        pickGallery.addTarget(self, action: #selector(openSwiftUI), for: .touchUpInside)
        cropBtn.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
        
    
    }
    
    private func setupConstraint() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imgView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            imgView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0),
            imgView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            imgView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0),
//            imgView.heightAnchor.constraint(equalToConstant: 400),
            
            openCamera.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            openCamera.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            openCamera.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            pickGallery.topAnchor.constraint(equalTo: openCamera.bottomAnchor, constant: 10),
            pickGallery.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            pickGallery.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            cropBtn.topAnchor.constraint(equalTo: pickGallery.bottomAnchor, constant: 10),
            cropBtn.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            cropBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            cropBtn.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -10),
            
            
        ])
    }
    

}

extension DefaultCaptureSession: AVCapturePhotoCaptureDelegate {
    
    func setupCamera() {
            // Create a capture session
            captureSession = AVCaptureSession()

            // Set the preferred quality for the camera
            captureSession?.sessionPreset = .photo

            // Get the default video capture device
            guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

            do {
                // Create an input for the capture session using the video capture device
                let input = try AVCaptureDeviceInput(device: captureDevice)

                // Add the input to the capture session
                if let captureSession = captureSession, captureSession.canAddInput(input) {
                    captureSession.addInput(input)

                    // Create an output for still images
                    stillImageOutput = AVCapturePhotoOutput()

                    // Add the output to the capture session
                    if let stillImageOutput = stillImageOutput, captureSession.canAddOutput(stillImageOutput) {
                        captureSession.addOutput(stillImageOutput)

                        // Create a preview layer for the camera feed
                        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                        previewLayer?.videoGravity = .resizeAspectFill
                        previewLayer?.connection?.videoOrientation = .portrait

                        // Set the frame for the preview layer
                        DispatchQueue.main.async {
                            self.previewLayer?.frame = self.view.layer.bounds
                        }

                        // Add the preview layer to the view
                        if let previewLayer = previewLayer {
                            DispatchQueue.main.async {
                                self.view.layer.insertSublayer(previewLayer, at: 0)
                            }
                        }

                        // Start the capture session
                        captureSession.startRunning()
                    }
                }
            } catch {
                // Handle errors
                print(error.localizedDescription)
            }
        }
    
    
    @objc func capturePhoto(_ sender: UIButton) {
//        let settings = AVCapturePhotoSettings()
//        stillImageOutput?.capturePhoto(with: settings, delegate: self)
     
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openSwiftUI(_ sender: UIButton) {
        let vc = UIHostingController(rootView: SwiftUIMain())
        
        self.navigationController?.present(vc, animated: true)
        
//        navigation
    }
    
    @objc func cropImage(_ sender: UIButton) {
        
        let sourceImage = imgView.image!
        
        let sideLength = min(
            sourceImage.size.width,
            sourceImage.size.height
        )

        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        print("y = \(yOffset) x: \(xOffset)")
        
        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral

        // Center crop the image
        let sourceCGImage = imgView.image?.cgImage!
        let croppedCGImage = sourceCGImage?.cropping(
            to: cropRect
        )!
        let croppedImage = UIImage(
            cgImage: croppedCGImage!,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )
        DispatchQueue.main.async {
            self.imgView.image = croppedImage
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData) {
                imgView.image = image
            }
        }
    }
    
}



