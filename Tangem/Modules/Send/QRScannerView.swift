//
//  QRScannerView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 21.12.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI
import PhotosUI

class QRScanViewCoordinator: CoordinatorObject {
    let dismissAction: Action<Void>
    let popToRootAction: Action<PopToRootOptions>

    @Published var imagePickerModel: ImagePickerModel?

    @Published private(set) var rootViewModel: QRScanViewModel?

    required init(
        dismissAction: @escaping Action<Void>,
        popToRootAction: @escaping Action<PopToRootOptions>
    ) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {
        rootViewModel = .init(code: options.code, text: options.text, coordinator: self)
    }

    func openImagePicker() {
        imagePickerModel = ImagePickerModel { [weak self] image in
            guard
                let image,
                let code = self?.readQRCode(from: image)
            else {
                return
            }

            self?.rootViewModel?.code.wrappedValue = code
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self?.dismissAction(())
            }
        }
    }

    private func readQRCode(from image: UIImage) -> String? {
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        guard
            let ciImage = CIImage(image: image),
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: options)
        else {
            return nil
        }

        return detector.features(in: ciImage)
            .lazy
            .compactMap { $0 as? CIQRCodeFeature }
            .first?
            .messageString
    }
}

// MARK: - Options

extension QRScanViewCoordinator {
    struct Options {
        let code: Binding<String>
        let text: String
    }
}

struct QRScanViewCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: QRScanViewCoordinator

    init(coordinator: QRScanViewCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            if let rootViewModel = coordinator.rootViewModel {
                QRScanView(viewModel: rootViewModel)
                    .navigationLinks(links)
            }

            sheets
        }
    }

    @ViewBuilder
    private var links: some View {
        EmptyView()
    }

    @ViewBuilder
    private var sheets: some View {
        NavHolder()
            .sheet(item: $coordinator.imagePickerModel) {
                ImagePicker(viewModel: $0)
            }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let viewModel: ImagePickerModel

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let viewModel: ImagePickerModel

        init(viewModel: ImagePickerModel) {
            self.viewModel = viewModel
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard
                let itemProvider = results.map(\.itemProvider).first,
                itemProvider.canLoadObject(ofClass: UIImage.self)
            else {
                return
            }

            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let error {
                    AppLog.shared.error(error)
                }

                let image = object as? UIImage
                self?.viewModel.didScanImage(image)
            }
        }
    }
}

class ImagePickerModel: Identifiable {
    let didScanImage: (UIImage?) -> Void

    init(didScanImage: @escaping (UIImage?) -> Void) {
        self.didScanImage = didScanImage
    }
}

class QRScanViewModel: Identifiable {
    let code: Binding<String>
    let text: String
    let coordinator: QRScanViewCoordinator

    init(code: Binding<String>, text: String, coordinator: QRScanViewCoordinator) {
        self.code = code
        self.text = text
        self.coordinator = coordinator
    }

    func scanFromGallery() {
        coordinator.openImagePicker()
    }
}

struct QRScanView: View {
    let viewModel: QRScanViewModel

    @Environment(\.presentationMode) var presentationMode

    @State private var isFlashActive = false

    private let viewfinderCornerRadius: CGFloat = 2
    private let viewfinderPadding: CGFloat = 55

    var body: some View {
        GeometryReader { geometry in
            QRScannerView(code: viewModel.code)
                .overlay(viewfinder(screenSize: geometry.size))
                .overlay(
                    Color.clear
                        .overlay(viewfinderCrosshair(screenSize: geometry.size))
                        .overlay(textView(screenSize: geometry.size), alignment: .top)
                )
                .overlay(topButtons(), alignment: .top)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func viewfinder(screenSize: CGSize) -> some View {
        Color.black.opacity(0.6)
            .reverseMask {
                RoundedRectangle(cornerRadius: viewfinderCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: max(100, screenSize.width - viewfinderPadding * 2))
            }
    }

    @ViewBuilder
    private func topButtons() -> some View {
        HStack(spacing: 14) {
            Button(Localization.commonClose) {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(7)
            .style(Fonts.Regular.body, color: .white)

            Spacer()

            Button(action: toggleFlash) {
                isFlashActive ? Assets.flashDisabled.image : Assets.flash.image
            }
            .padding(7)

            Button {
                viewModel.scanFromGallery()
            } label: {
                Assets.gallery.image
            }
            .padding(7)
        }
        .padding(.vertical, 21)
        .padding(.horizontal, 9)
    }

    private func viewfinderCrosshair(screenSize: CGSize) -> some View {
        RoundedRectangle(cornerRadius: viewfinderCornerRadius)
            .stroke(.white, lineWidth: 4)
            .aspectRatio(1, contentMode: .fit)
            .frame(width: max(100, screenSize.width - viewfinderPadding * 2))
            .clipShape(CrosshairShape())
    }

    private func textView(screenSize: CGSize) -> some View {
        Text(viewModel.text)
            .style(Fonts.Regular.footnote, color: .white)
            .multilineTextAlignment(.center)
            .padding(.top, 24)
            .padding(.horizontal, viewfinderPadding)
            .offset(y: screenSize.height / 2 + screenSize.width / 2 - viewfinderPadding)
    }

    private func toggleFlash() {
        guard
            let camera = AVCaptureDevice.default(for: .video),
            camera.hasTorch
        else {
            return
        }

        do {
            try camera.lockForConfiguration()

            // Do it before the actual changes because it's not immediate
            withAnimation(nil) {
                isFlashActive = !camera.isTorchActive
            }

            camera.torchMode = camera.isTorchActive ? .off : .on
            camera.unlockForConfiguration()
        } catch {
            AppLog.shared.debug("Failed to toggle the flash")
            AppLog.shared.error(error)
        }
    }
}

private struct CrosshairShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addPath(cornerPath(rotation: 0, in: rect))
        path.addPath(cornerPath(rotation: 90, in: rect))
        path.addPath(cornerPath(rotation: 180, in: rect))
        path.addPath(cornerPath(rotation: 270, in: rect))
        return path
    }

    private func cornerPath(rotation: Double, in rect: CGRect) -> Path {
        // Top-left corner part of a crosshair
        var path = Path()
        path.move(to: CGPoint(x: -10, y: -10))
        path.addLine(to: CGPoint(x: -10, y: 20))
        path.addLine(to: CGPoint(x: 20, y: 20))
        path.addLine(to: CGPoint(x: 20, y: -10))
        path.closeSubpath()
        return path.rotation(.degrees(rotation)).path(in: rect)
    }
}

private extension View {
    func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            Rectangle()
                .overlay(mask().blendMode(.destinationOut), alignment: alignment)
        )
    }
}

struct QRScanView_Previews_Sheet: PreviewProvider {
    @State static var code: String = ""

    static var previews: some View {
        Text("A")
            .sheet(isPresented: .constant(true)) {
                QRScanView(viewModel: .init(code: $code, text: "Please align your QR code with the square to scan it. Ensure you scan ERC-20 network address.", coordinator: QRScanViewCoordinator(dismissAction: { _ in }, popToRootAction: { _ in })))
                    .background(
                        Image("qr_code_example")
                    )
            }
            .previewDisplayName("Sheet")
    }
}

struct QRScanView_Previews_Inline: PreviewProvider {
    @State static var code: String = ""

    static var previews: some View {
        QRScanView(viewModel: .init(code: $code, text: "Please align your QR code with the square to scan it. Ensure you scan ERC-20 network address.", coordinator: QRScanViewCoordinator(dismissAction: { _ in }, popToRootAction: { _ in })))
            .background(
                Image("qr_code_example")
            )
            .previewDisplayName("Inline")
    }
}

struct QRScannerView: UIViewRepresentable {
    @Binding var code: String
    @Environment(\.presentationMode) var presentationMode

    func makeUIView(context: Context) -> UIQRScannerView {
        let view = UIQRScannerView()
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: UIQRScannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(code: $code, presentationMode: presentationMode)
    }

    class Coordinator: NSObject, QRScannerViewDelegate {
        @Binding var code: String
        @Binding var presentationMode: PresentationMode

        init(code: Binding<String>, presentationMode: Binding<PresentationMode>) {
            _code = code
            _presentationMode = presentationMode
        }

        func qrScanningDidFail() {
            DispatchQueue.main.async {
                self.presentationMode.dismiss()
            }
        }

        func qrScanningSucceededWithCode(_ str: String?) {
            if let str = str {
                code = str
            }

            DispatchQueue.main.async {
                self.presentationMode.dismiss()
            }
        }

        func qrScanningDidStop() {}
    }
}

/// Delegate callback for the QRScannerView.
protocol QRScannerViewDelegate: AnyObject {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ str: String?)
    func qrScanningDidStop()
}

class UIQRScannerView: UIView {
    weak var delegate: QRScannerViewDelegate?

    /// capture settion which allows us to start and stop scanning.
    var captureSession: AVCaptureSession?
    private var feedbackGenerator: UINotificationFeedbackGenerator?
    // Init methods..
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitialSetup()
    }

    // MARK: overriding the layerClass to return `AVCaptureVideoPreviewLayer`.

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
}

extension UIQRScannerView {
    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }

    func stopScanning() {
        captureSession?.stopRunning()
        delegate?.qrScanningDidStop()
    }

    /// Does the initial setup for captureSession
    private func doInitialSetup() {
        clipsToBounds = true
        captureSession = AVCaptureSession()
        feedbackGenerator = UINotificationFeedbackGenerator()

        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            initVideo()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (granted: Bool) in
                DispatchQueue.main.async {
                    if granted {
                        self?.initVideo()
                    } else {
                        self?.scanningDidFail()
                    }
                }
            })
        }
    }

    private func initVideo() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            AppLog.shared.error(error)
            return
        }

        if captureSession?.canAddInput(videoInput) ?? false {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession?.canAddOutput(metadataOutput) ?? false {
            captureSession?.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            scanningDidFail()
            return
        }

        layer.session = captureSession
        layer.videoGravity = .resizeAspectFill

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }

    func scanningDidFail() {
        feedbackGenerator?.notificationOccurred(.error)
        delegate?.qrScanningDidFail()
        captureSession = nil
        feedbackGenerator = nil
    }

    func found(code: String) {
        feedbackGenerator?.notificationOccurred(.success)
        delegate?.qrScanningSucceededWithCode(code)
        feedbackGenerator = nil
    }
}

extension UIQRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        stopScanning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            // AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
}
