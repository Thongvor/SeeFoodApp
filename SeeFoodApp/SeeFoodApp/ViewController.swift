//
//  ViewController.swift
//  SeeFoodApp
//
//  Created by Dmytro Holovko on 15.04.2021.
//

import UIKit
import CoreML
import Vision

class ViewController:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var takenPhoto: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.imagePicker.allowsEditing = false
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        self.present(self.imagePicker, animated: true)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model ) else {
            fatalError("Loading CoreML model failed.")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to precess image.")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog 🌭🙂"
                } else {
                    self.navigationItem.title = "Not Hotdog 🌭🤢"
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.takenPhoto.image = image
            guard let ciImage = CIImage(image: image) else {
                fatalError("Could not convert image to ciimage.")
            }
            self.detect(image: ciImage)
        }
        self.imagePicker.dismiss(animated: true)
    }
}

