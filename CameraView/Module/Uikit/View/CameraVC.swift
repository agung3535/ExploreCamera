//
//  CameraVC.swift
//  CameraView
//
//  Created by Agung Dwi Saputra on 23/01/24.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    private var cameraService: CameraUIkitService!
    
    private var cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.backgroundColor = UIColor.black.cgColor
        return view
    }()
    
    private let btnCapture: UIView = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .none
        view.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        return view
    }()
    
    private let imageCapture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.circle.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var rectangleLayer: RectangleLayer!
    
    var didFinishPhoto: ((Result<UIImage, Error>) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        view.addSubview(btnCapture)
        btnCapture.addSubview(imageCapture)
        view.addSubview(cameraView)
        setupConstraint()
        
        rectangleLayer = RectangleLayer()
        rectangleLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        print("position x: \(view.bounds.midX) dan y: \(view.bounds.midY)")
        
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6880432533)
        backgroundLayer.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        backgroundLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)

        cameraService = CameraUIkitService()
        cameraService.checkPermission()
        cameraService.delegate = self

        cameraService.previewLayer.frame = self.view.bounds

        // Add the rectangleLayer to the previewLayer
        cameraService.previewLayer.addSublayer(rectangleLayer)

        // Set up a mask layer with CAShapeLayer
        let maskLayer = CAShapeLayer()
        maskLayer.bounds = backgroundLayer.bounds
        maskLayer.position = backgroundLayer.position

        // Create a path for the mask layer (cutting out the rectangle area)
        let path = UIBezierPath(rect: view.bounds)
        path.append(UIBezierPath(rect: rectangleLayer.frame))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd

        // Apply the mask to the backgroundLayer
        backgroundLayer.mask = maskLayer

        // Insert the backgroundLayer below the rectangleLayer in the previewLayer
        cameraService.previewLayer.insertSublayer(backgroundLayer, below: rectangleLayer)
        
        view.layer.insertSublayer(cameraService.previewLayer, at: 0)
    }
    
    private func setupConstraint() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            btnCapture.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            btnCapture.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            btnCapture.widthAnchor.constraint(equalToConstant: 80),
            btnCapture.heightAnchor.constraint(equalToConstant: 80),
            imageCapture.leadingAnchor.constraint(equalTo: btnCapture.leadingAnchor),
            imageCapture.topAnchor.constraint(equalTo: btnCapture.topAnchor),
            imageCapture.trailingAnchor.constraint(equalTo: btnCapture.trailingAnchor),
            imageCapture.bottomAnchor.constraint(equalTo: btnCapture.bottomAnchor)
        ])
    }
    
    @objc
    func capturePhoto(_ sender: UIButton) {
        cameraService.captureImage()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        let correctImage = UIImage(data: imageData)
        
        guard let correctImage = correctImage else {
            print("Error: correct image")
            return
        }
        
        let heightFactor = self.view.frame.height / correctImage.size.height
        
        let widhFactor = self.view.frame.width / correctImage.size.width

        let newSize = CGSize(width: correctImage.size.width * heightFactor, height: correctImage.size.height * heightFactor)

        let newImage = correctImage.resize(to: newSize)
        
        print("size screen = \(view.frame.size)")
        
        print("old size image = \(correctImage.size)")
        
        print("new size = \(newImage?.size)")
            
        print("rect pos x: \(rectangleLayer.position.x) dan y: \(rectangleLayer.position.y)")
        
        let screenCrop = CGRect(
            x: (newSize.width - self.view.bounds.width) * 0.5,
            y: 0,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )


      
        
        guard let imageToCrop = newImage else {
            return
        }
        
//        var correctScreenCroppedImage = cropImage(imageToCrop, to: screenCrop)
//        
//        
//        let correctCrop = CGRect(
//            x: 0,
//            y: (correctScreenCroppedImage.size.height * 0.5) - (correctScreenCroppedImage.size.width * 0.5),
//            width: correctScreenCroppedImage.size.width,
//            height: correctScreenCroppedImage.size.width)
//
//        var correctCroppedImage = cropImage(correctScreenCroppedImage, to: correctCrop)
//        
//        didFinishPhoto?(.success(correctCroppedImage))
        
        if let croppedImage = cropImageToRectangleArea(image: imageToCrop, rectangleLayer: rectangleLayer) {
                // Do something with the croppedImage, such as displaying it or saving it
                print("Cropped image size = \(croppedImage.size)")
            
            print("width image = \(croppedImage.size.width)")
            
                didFinishPhoto?(.success(croppedImage))
            }
        
//        if let croppedImage = cropImageFromRect(image: newImage, rect: CGRect(
//            x: rectangleLayer.position.x,
//            y: rectangleLayer.position.y,
//            width: 300, height: 200)) {
//                didFinishPhoto?(.success(croppedImage))
//        }
        
        
//        didFinishPhoto?(.success(newImage!))
        
        
        
    }

    // Function to crop an image to a specific CGRect
    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage {
        guard let cgImage = image.cgImage else {
            return image
        }

        let croppedCGImage = cgImage.cropping(to: rect)
        let croppedImage = UIImage(cgImage: croppedCGImage!, scale: image.scale, orientation: image.imageOrientation)

        return croppedImage
    }
    
    func cropImageFromRect(image: UIImage?, rect: CGRect) -> UIImage? {
        guard let image = image else {
            return nil
        }

        let scale = image.scale
        let croppedRect = CGRect(x: rect.origin.x * scale,
                                 y: rect.origin.y * scale,
                                 width: rect.size.width * scale,
                                 height: rect.size.height * scale)

        if let cgImage = image.cgImage?.cropping(to: croppedRect) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
        }

        return nil
    }
}



extension UIImage {
    func resize(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: newSize))

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        return newImage
    }
    
    func crop(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }

        return UIImage(cgImage: croppedCGImage)
    }
}

extension CameraVC {
//    func cropImageToRectangleArea(image: UIImage, rectangleLayer: RectangleLayer) -> UIImage? {
//        // Convert rectangleLayer frame to image coordinates
//        let rectInImage = cameraService.previewLayer.metadataOutputRectConverted(fromLayerRect: rectangleLayer.frame)
//
//        // Calculate the actual CGRect in the image
//        let imageRect = CGRect(x: rectInImage.origin.x * image.size.width,
//                               y: rectInImage.origin.y * image.size.height,
//                               width: rectInImage.size.width * image.size.width,
//                               height: rectInImage.size.height * image.size.height)
//
//        // Crop the image to the calculated CGRect
//        return image.crop(to: imageRect)
//    }
    
    func cropImageToRectangleArea(image: UIImage, rectangleLayer: RectangleLayer) -> UIImage? {
            guard let cgImage = image.cgImage else { return nil }
            
            let imageSize = image.size
            let layerFrame = rectangleLayer.frame
            
            // Convert the layer frame to image coordinates
            let scaleX = CGFloat(cgImage.width) / imageSize.width
            let scaleY = CGFloat(cgImage.height) / imageSize.height
        
            print("scale X = \(scaleX) position = \(layerFrame.origin.x * scaleX)")
        
            print("scale Y = \(scaleY) position = \(layerFrame.origin.y * scaleY)")
            
            let croppedRect = CGRect(x: layerFrame.origin.x * scaleX,
                                     y: layerFrame.origin.y * scaleY,
                                     width: layerFrame.size.width * scaleX,
                                     height: layerFrame.size.height * scaleY)
        
 

            guard let croppedCGImage = cgImage.cropping(to: croppedRect) else { return nil }

            return UIImage(cgImage: croppedCGImage)
        }
}
