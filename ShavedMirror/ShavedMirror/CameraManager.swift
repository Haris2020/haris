import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    @Published var isZoomed = false

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080

        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No front camera available")
            session.commitConfiguration()
            return
        }

        self.device = frontCamera

        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("Failed to create camera input: \(error)")
        }

        session.commitConfiguration()
    }

    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stop() {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    func toggleZoom() {
        guard let device = device else { return }
        let targetZoom: CGFloat = isZoomed ? 1.0 : 2.0
        do {
            try device.lockForConfiguration()
            device.ramp(toVideoZoomFactor: targetZoom, withRate: 4.0)
            device.unlockForConfiguration()
            DispatchQueue.main.async {
                self.isZoomed.toggle()
            }
        } catch {
            print("Failed to zoom: \(error)")
        }
    }
}
