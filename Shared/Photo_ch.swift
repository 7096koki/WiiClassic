//
// Photo_ch.swift
// Single-file Photo Channel with Play menu (Puzzle 24, Filters, Markup)
// Target: Xcode 12.5.1 / iOS 14.5
//

import SwiftUI
import PhotosUI
import UIKit
import PencilKit
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation

// =======================
// Identifiable wrapper for UIImage
// =======================
struct IdentifiableImage: Identifiable, Equatable {
    let id = UUID()
    var image: UIImage
}

// =======================
// Photo channel (grid + picker)
// =======================
struct Photo_ch: View {
    @State private var identifiableImages: [IdentifiableImage] = []
    @State private var showingPicker = false
    @State private var selectedImage: IdentifiableImage? = nil
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        VStack {
            Text("写真チャンネル")
                .font(.custom("Arial Rounded MT Bold", size: 34))
                .fontWeight(.heavy)
                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.6))
                .padding(.top, 36)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(identifiableImages) { item in
                        Image(uiImage: item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 110)
                            .clipped()
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            .onTapGesture {
                                selectedImage = item
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            Button(action: { showingPicker = true }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("写真を読み込む")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                   startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(14)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .sheet(isPresented: $showingPicker) {
            PhotoPicker { images in
                // append picked images
                for ui in images {
                    identifiableImages.append(IdentifiableImage(image: ui))
                }
            }
        }
        .fullScreenCover(item: $selectedImage) { wrapped in
            PhotoFullScreenView(image: wrapped.image) { edited in
                // replace image in the list
                if let idx = identifiableImages.firstIndex(where: { $0.id == wrapped.id }) {
                    identifiableImages[idx] = IdentifiableImage(image: edited)
                }
            }
        }
    }
}

// =======================
// Photo full screen: "あそぶ" menu (Puzzle / Filter / Markup)
// =======================
struct PhotoFullScreenView: View {
    let image: UIImage
    var onImageMarked: (UIImage) -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var showPlayMenu = false
    @State private var showPuzzle = false
    @State private var showFilter = false
    @State private var showMarkup = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            
            VStack {
                HStack {
                    Button(action: { showPlayMenu = true }) {
                        HStack { Image(systemName: "gamecontroller.fill"); Text("あそぶ") }
                            .padding(10)
                            .background(Color.white)
                            .foregroundColor(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        // ActionSheet for Play menu
        .actionSheet(isPresented: $showPlayMenu) {
            ActionSheet(title: Text("あそぶメニュー"),
                        message: Text("写真で遊べます"),
                        buttons: [
                            .default(Text("24ピースジグソーパズル")) { showPuzzle = true },
                            .default(Text("雰囲気チェンジ")) { showFilter = true },
                            .default(Text("マークアップ（編集）")) { showMarkup = true },
                            .cancel()
                        ])
        }
        .fullScreenCover(isPresented: $showPuzzle) {
            JigsawPuzzle24View(originalImage: image) {
                // when puzzle dismissed with (maybe) updated image? We'll just ignore result for now
            }
        }
        .fullScreenCover(isPresented: $showFilter) {
            FilterChangeView(originalImage: image) { edited in
                onImageMarked(edited)
            }
        }
        .fullScreenCover(isPresented: $showMarkup) {
            MarkupEditorWrapper(originalImage: image) { edited in
                onImageMarked(edited)
            }
        }
    }
}

// =======================
// Jigsaw puzzle 24 pieces (4 rows x 6 cols), tap-two-swap style
// =======================
struct JigsawPuzzle24View: View {
    let originalImage: UIImage
    var onComplete: (() -> Void)? = nil

    @Environment(\.presentationMode) var presentationMode
    @State private var pieces: [PuzzlePiece] = []
    @State private var cols = 6
    @State private var rows = 4
    @State private var firstSelectedIndex: Int? = nil
    @State private var showCompleteAlert = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 12) {
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                        Text("24ピースジグソーパズル")
                            .foregroundColor(.white)
                            .font(.headline)
                        Spacer()
                        Button(action: { shufflePieces() }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    
                    // grid
                    let gridWidth = min(geo.size.width - 30, geo.size.height * 0.72)
                    let pieceWidth = gridWidth / CGFloat(cols)
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(pieceWidth), spacing: 4), count: cols), spacing: 4) {
                        ForEach(pieces.indices, id: \.self) { idx in
                            let p = pieces[idx]
                            Image(uiImage: p.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: pieceWidth, height: pieceWidth * (CGFloat(rows)/CGFloat(cols))) // keep roughly rectangular
                                .clipped()
                                .border(firstSelectedIndex == idx ? Color.yellow : Color.clear, width: 4)
                                .animation(.default, value: firstSelectedIndex)
                                .onTapGesture {
                                    pieceTapped(at: idx)
                                }
                        }
                    }
                    .frame(width: gridWidth)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
            .onAppear {
                preparePieces()
                shufflePieces()
            }
            .alert(isPresented: $showCompleteAlert) {
                Alert(title: Text("🎉 完成しました！"), message: Text("おめでとう！"), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Pieces handling
    func preparePieces() {
        // split originalImage into rows x cols pieces; store originalIndex
        guard let cg = originalImage.cgImage else {
            pieces = []
            return
        }
        let imgW = cg.width
        let imgH = cg.height
        // We want cropping rectangles in pixel coordinates
        let pieceW = imgW / cols
        let pieceH = imgH / rows
        var arr: [PuzzlePiece] = []
        var index = 0
        for r in 0..<rows {
            for c in 0..<cols {
                let rect = CGRect(x: c * pieceW, y: r * pieceH, width: pieceW, height: pieceH)
                if let croppedCG = cg.cropping(to: rect) {
                    let ui = UIImage(cgImage: croppedCG, scale: originalImage.scale, orientation: originalImage.imageOrientation)
                    arr.append(PuzzlePiece(id: UUID(), originalIndex: index, currentIndex: index, image: ui))
                } else {
                    // fallback: create empty
                    let empty = UIImage()
                    arr.append(PuzzlePiece(id: UUID(), originalIndex: index, currentIndex: index, image: empty))
                }
                index += 1
            }
        }
        pieces = arr
    }

    func shufflePieces() {
        // simple Fisher-Yates shuffle for image positions while keeping originalIndex property intact
        var images = pieces.map { $0.image }
        images.shuffle()
        for i in pieces.indices {
            pieces[i].image = images[i]
            // we keep originalIndex unchanged; use currentIndex as position
            pieces[i].currentIndex = i
        }
        firstSelectedIndex = nil
    }

    func pieceTapped(at idx: Int) {
        if firstSelectedIndex == nil {
            firstSelectedIndex = idx
            return
        } else if firstSelectedIndex == idx {
            firstSelectedIndex = nil
            return
        } else {
            // swap images between firstSelectedIndex and idx (animate by swapping)
            let a = firstSelectedIndex!
            withAnimation(.easeInOut(duration: 0.23)) {
                let tmp = pieces[a].image
                pieces[a].image = pieces[idx].image
                pieces[idx].image = tmp
            }
            firstSelectedIndex = nil
            // check completion: Because we shuffled only images, we consider completion when
            // each piece's image matches the original image piece - but we only have images; to check, we can compare data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                if isSolved() {
                    showCompleteAlert = true
                    onComplete?()
                }
            }
        }
    }

    func isSolved() -> Bool {
        // Recreate reference original pieces order and compare each piece's image with original
        guard let cg = originalImage.cgImage else { return false }
        let imgW = cg.width
        let imgH = cg.height
        let pieceW = imgW / cols
        let pieceH = imgH / rows
        var idx = 0
        for r in 0..<rows {
            for c in 0..<cols {
                let rect = CGRect(x: c * pieceW, y: r * pieceH, width: pieceW, height: pieceH)
                if let croppedCG = cg.cropping(to: rect) {
                    let pieceImage = UIImage(cgImage: croppedCG, scale: originalImage.scale, orientation: originalImage.imageOrientation)
                    // Compare png/data equality (not super efficient but fine for 24 pieces)
                    if let dataA = pieceImage.pngData(), let dataB = pieces[idx].image.pngData() {
                        if dataA != dataB {
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    return false
                }
                idx += 1
            }
        }
        return true
    }
}

// PuzzlePiece model
struct PuzzlePiece: Identifiable {
    let id: UUID
    let originalIndex: Int
    var currentIndex: Int
    var image: UIImage
}

// =======================
// Filter view (CoreImage filters)
// =======================
struct FilterChangeView: View {
    let originalImage: UIImage
    var onApply: (UIImage) -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var currentUIImage: UIImage
    @State private var ciContext = CIContext()
    @State private var selectedFilter: FilterType = .none

    enum FilterType {
        case none, mono, sepia, vivid
    }

    init(originalImage: UIImage, onApply: @escaping (UIImage) -> Void) {
        self.originalImage = originalImage
        self.onApply = onApply
        _currentUIImage = State(initialValue: originalImage)
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .padding()
                }
                Spacer()
                Text("雰囲気チェンジ")
                    .font(.headline)
                    .padding(.trailing)
                Spacer()
                Button("適用") {
                    onApply(currentUIImage)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }

            Spacer()

            Image(uiImage: currentUIImage)
                .resizable()
                .scaledToFit()
                .padding()

            Spacer()

            HStack(spacing: 14) {
                Button(action: { apply(.none) }) {
                    Text("元に戻す")
                        .padding()
                        .background(selectedFilter == .none ? Color.gray.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                }
                Button(action: { apply(.mono) }) {
                    Text("モノクロ")
                        .padding()
                        .background(selectedFilter == .mono ? Color.gray.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                }
                Button(action: { apply(.sepia) }) {
                    Text("セピア")
                        .padding()
                        .background(selectedFilter == .sepia ? Color.gray.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                }
                Button(action: { apply(.vivid) }) {
                    Text("ビビッド")
                        .padding()
                        .background(selectedFilter == .vivid ? Color.gray.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 30)
        }
    }

    func apply(_ type: FilterType) {
        selectedFilter = type
        DispatchQueue.global(qos: .userInitiated).async {
            let output: UIImage
            switch type {
            case .none:
                output = originalImage
            case .mono:
                let ci = CIImage(image: originalImage)
                let filter = CIFilter.photoEffectNoir()
                filter.inputImage = ci
                let outCI = filter.outputImage
                output = uiImage(from: outCI) ?? originalImage
            case .sepia:
                let ci = CIImage(image: originalImage)
                let filter = CIFilter.sepiaTone()
                filter.inputImage = ci
                filter.intensity = 0.9
                let outCI = filter.outputImage
                output = uiImage(from: outCI) ?? originalImage
            case .vivid:
                let ci = CIImage(image: originalImage)
                let controls = CIFilter.colorControls()
                controls.inputImage = ci
                controls.saturation = 1.8
                controls.contrast = 1.1
                let outCI = controls.outputImage
                output = uiImage(from: outCI) ?? originalImage
            }
            DispatchQueue.main.async {
                currentUIImage = output
            }
        }
    }

    func uiImage(from ciImage: CIImage?) -> UIImage? {
        guard let ciImage = ciImage else { return nil }
        if let cg = ciContext.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cg, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        }
        return nil
    }
}

// =======================
// Markup editor (simple PencilKit-based editor) - UIViewControllerRepresentable
// =======================
struct MarkupEditorWrapper: UIViewControllerRepresentable {
    let originalImage: UIImage
    var onComplete: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = MarkupEditorViewController(image: originalImage) { edited in
            onComplete(edited)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

// Simple MarkupEditorViewController: image + PKCanvasView + tool picker + Done
class MarkupEditorViewController: UIViewController, PKCanvasViewDelegate {
    let originalImage: UIImage
    var onComplete: (UIImage) -> Void

    let imageView = UIImageView()
    let canvasView = PKCanvasView()
    let toolPicker = PKToolPicker()
    // we will use a simple toolbar: Done / Cancel / Clear
    init(image: UIImage, onComplete: @escaping (UIImage) -> Void) {
        self.originalImage = image
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNav()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if view.window != nil {
            toolPicker.addObserver(canvasView)
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
    }

    func setupNav() {
        title = "マークアップ"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(cancelTapped))
        let clear = UIBarButtonItem(title: "クリア", style: .plain, target: self, action: #selector(clearTapped))
        toolbarItems = [clear]
        navigationController?.isToolbarHidden = false
    }

    func setupViews() {
        imageView.image = originalImage
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.delegate = self

        view.addSubview(imageView)
        view.addSubview(canvasView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            canvasView.topAnchor.constraint(equalTo: imageView.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])

        // simple tool settings
        toolPicker.selectedTool = PKInkingTool(.pen, color: .systemRed)
        toolPicker.showsDrawingPolicyControls = true
    }

    @objc func clearTapped() {
        canvasView.drawing = PKDrawing()
    }

    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc func doneTapped() {
        // Merge drawing onto original image scaled appropriately
        // We'll render the canvas drawing as an image the size of the imageView visible area, then scale to original image size.
        let drawingImage = canvasView.drawing.image(from: canvasView.bounds, scale: originalImage.scale)
        // merge
        let merged = originalImage.merge(drawingImage)
        onComplete(merged)
        dismiss(animated: true, completion: nil)
    }
}

// =======================
// UIImage helper: merge top image onto base image
// =======================
extension UIImage {
    func merge(_ topImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        topImage.draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: 1.0)
        let out = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return out
    }
}

// =======================
// PHPicker wrapper (iOS14-friendly)
// =======================
struct PhotoPicker: UIViewControllerRepresentable {
    var onImagesPicked: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ vc: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            var picked: [UIImage] = []
            let group = DispatchGroup()
            for r in results {
                if r.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    r.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                        if let img = obj as? UIImage { picked.append(img) }
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) { self.parent.onImagesPicked(picked) }
        }
    }
}
