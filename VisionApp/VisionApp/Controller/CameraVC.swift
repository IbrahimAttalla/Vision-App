//
// CameraVC.swift
//  VisionApp
//
//  Created by it thinkers on 2/11/19.
//  Copyright © 2019 it-thinkers. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision



enum FlashState{
    case off
    case on
}

class CameraVC: UIViewController {

    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var photoData: Data?

    
    var flashControlState:FlashState = .off
    var speechSythasizer = AVSpeechSynthesizer()
    @IBOutlet weak var camView: UIView!
    @IBOutlet weak var itemsView: RoundedShadowView!
    @IBOutlet weak var captureIMG: RoundedShadowImage!
    @IBOutlet weak var flashBTN: RoundedShadowButton!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemConfidence: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = camView.bounds
        
        speechSythasizer.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                camView.layer.addSublayer(previewLayer!)
                camView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
        } catch {
            debugPrint(error)
        }
    }
    
    
    @IBAction func flashBtnWasPressed(_ sender: RoundedShadowButton) {
        
        switch flashControlState {
        case .off:
            self.flashBTN.setTitle("FLASH ON", for: .normal)
            self.flashControlState = .on
        case .on:
            self.flashBTN.setTitle("FLASH OFF", for: .normal)
            self.flashControlState = .off
        }
    }
    
    
    
    func speechSythasizer(fromText text:String){
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSythasizer.speak(speechUtterance)
    }
    
    
    
    @objc func didTapCameraView() {
        // to disable any action of view till the speak finish the text
        self.camView.isUserInteractionEnabled = false
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        
        settings.previewPhotoFormat = previewFormat
        if self.flashControlState == .off {
           settings.flashMode = .off
        }else{
            settings.flashMode = .on
        }
        
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    
    
    // the error must be " ? " so there my be no error
    func resultsMethod(request:VNRequest , error:Error?){
        // handel the text label and display the prediction name and confidence to it
        
        guard let result = request.results as? [VNClassificationObservation] else {return}
        for classification in result {
            if classification.confidence < 0.5{
                let unKnownObjectMessage = "I'm not sure what this is. Please try again."
                self.itemName.text = unKnownObjectMessage
                speechSythasizer(fromText: unKnownObjectMessage)
                self.itemConfidence.text = ""
                break
            }else{
                let itemID = classification.identifier
                let confidence = Int((classification.confidence)*100)
                self.itemName.text = itemID
                self.itemConfidence.text = "  CONFIDENCE: \(confidence)"
                let completSenence = " this looks like a \(itemID) and I'm \(confidence)percent sure . "
                speechSythasizer(fromText: completSenence)
                break
            }
        }
        
    }
       
   }





extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            // first step at core ML
            do{
                let model  = try VNCoreMLModel(for: SqueezeNet().model)
                // now we have a model it's like a human brain  and we need a request to access it's data
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler  = VNImageRequestHandler(data: photoData!)
                // but the original method is VNImageRequestHandler(data: <#T##Data#>, options: <#T##[VNImageOption : Any]#>) then we removed the second parameter
                try handler.perform([request])
                
                
            }catch{
                debugPrint(error)
            }
            let image = UIImage(data: photoData!)
            self.captureIMG.image = image
        }
    }
}
extension CameraVC:AVSpeechSynthesizerDelegate{
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // code to finish utterance hold every thing till the speak to finish the text
        
        self.camView.isUserInteractionEnabled = true
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
    }
}












