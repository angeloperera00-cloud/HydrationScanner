import SwiftUI
import AVFoundation
import UIKit

// MARK: - Camera Service (runs camera work off-main safely)
final class CameraService: NSObject, ObservableObject, @unchecked Sendable {
    let session = AVCaptureSession()
    let output = AVCapturePhotoOutput()
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue", qos: .userInitiated)
    
    @MainActor @Published var isRunning: Bool = false
    private var isConfigured = false
    
    func requestAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureIfNeededAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { self.configureIfNeededAndStart() }
                else { Task { @MainActor in self.isRunning = false } }
            }
        default:
            Task { @MainActor in self.isRunning = false }
        }
    }
    
    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning { self.session.stopRunning() }
            Task { @MainActor in self.isRunning = false }
        }
    }
    
    private func configureIfNeededAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            if !self.isConfigured {
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                
                guard
                    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                    let input = try? AVCaptureDeviceInput(device: device),
                    self.session.canAddInput(input),
                    self.session.canAddOutput(self.output)
                else {
                    self.session.commitConfiguration()
                    Task { @MainActor in self.isRunning = false }
                    return
                }
                
                self.session.addInput(input)
                self.session.addOutput(self.output)
                self.session.commitConfiguration()
                self.isConfigured = true
            }
            
            if !self.session.isRunning {
                self.session.startRunning()
            }
            
            Task { @MainActor in
                self.isRunning = self.session.isRunning
            }
        }
    }
}

// MARK: - View
struct CameraCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    let onCapture: (UIImage?) -> Void
    
    @StateObject private var camera = CameraService()
    @State private var photoDelegate: PhotoCaptureDelegate? = nil
    
    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button("Cancel") {
                        camera.stop()
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                
                Spacer()
                
                Button(action: capturePhoto) {
                    Circle()
                        .fill(camera.isRunning ? Color.white : Color.gray.opacity(0.6))
                        .frame(width: 70, height: 70)
                }
                .padding(.bottom, 30)
                .disabled(!camera.isRunning)
            }
        }
        .onAppear { camera.requestAndStart() }
        .onDisappear { camera.stop() }
    }
    
    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        
        let delegate = PhotoCaptureDelegate { img in
            self.camera.stop()
            self.onCapture(img)
            self.dismiss()
            self.photoDelegate = nil
        }
        
        photoDelegate = delegate
        camera.output.capturePhoto(with: settings, delegate: delegate)
    }
}

// MARK: - Photo Delegate
final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let onCapture: (UIImage?) -> Void
    init(onCapture: @escaping (UIImage?) -> Void) { self.onCapture = onCapture }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let img = UIImage(data: data) else {
            onCapture(nil)
            return
        }
        onCapture(img)
    }
}

// MARK: - Preview Layer
struct CameraPreview: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> PreviewVC {
        PreviewVC(session: session)
    }
    
    func updateUIViewController(_ uiViewController: PreviewVC, context: Context) {}
    
    final class PreviewVC: UIViewController {
        let session: AVCaptureSession
        private var preview: AVCaptureVideoPreviewLayer!
        
        init(session: AVCaptureSession) {
            self.session = session
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) { fatalError() }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            view.layer.addSublayer(preview)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            preview.frame = view.bounds
            if let c = preview.connection, c.isVideoOrientationSupported {
                c.videoOrientation = .portrait
            }
        }
    }
}
