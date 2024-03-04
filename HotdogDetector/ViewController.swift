//
//  ViewController.swift
//  HotdogDetector
//
//  Created by Kerem Caan on 28.02.2024.
//

import UIKit
import CoreML
import Vision
import SnapKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let navController = UINavigationController()
    let buttonItem = UIBarButtonItem()
    let imageView = UIImageView()
    let imagePicker = UIImagePickerController()
    let navItem = UINavigationItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }

    func configureUI() {
        view.backgroundColor = .systemBackground
        

        imagePicker.delegate = self
        imagePicker.sourceType = .camera // if trying in simulator change it to .photolibrary
        imagePicker.allowsEditing = false
        
        lazy var navBar = UINavigationBar()
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44)
        }
        

        buttonItem.action = #selector(openCamera)
        buttonItem.image = UIImage(systemName: "camera.fill")
        navItem.rightBarButtonItem = buttonItem
        navBar.setItems([navItem], animated: true)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image = pickedImage
            
            guard let ciimage = CIImage(image: pickedImage) else {
                fatalError("We couldnt convert the image. Sorry!")
            }
            
            detection(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true)
        
    }
    
    func detection(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navItem.title = "Hotdog!"
                } else {
                    self.navItem.title = "Not a Hotdog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
        
    }
    
    @objc func openCamera() {
        present(imagePicker, animated: true)
    }

}

