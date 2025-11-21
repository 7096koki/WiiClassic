import SwiftUI
import PhotosUI

// Identifiableラッパー
struct IdentifiableImage: Identifiable {
    var id = UUID()
    var image: UIImage
}

// MARK: - 写真チャンネル（Wii風）
struct Photo_ch: View {
    @State private var images: [UIImage] = []                 // ← 追加！
    @State private var showingPicker = false                  // ← 追加！
    @State private var selectedImage: IdentifiableImage? = nil
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        VStack {
            // タイトル
            Text("写真チャンネル")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // グリッド表示
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    
                    ForEach(Array(images.enumerated()), id: \.offset) { index, img in
                        
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipped()
                            .onTapGesture {
                                selectedImage = IdentifiableImage(image: img)
                            }
                    }
                }
                .padding()
            }
            
            // 写真追加ボタン
            Button(action: { showingPicker = true }) {
                Text("写真を読み込む")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingPicker) {
            PhotoPicker(images: $images)
        }
        .fullScreenCover(item: $selectedImage) { wrapped in
            PhotoFullScreenView(image: wrapped.image)
        }
    }
}


// MARK: - フルスクリーン表示（Wii風ズーム）
struct PhotoFullScreenView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}


// MARK: - iOS14対応のPHPicker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ vc: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true)
            
            for item in results {
                if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    item.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                        if let img = obj as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(img)
                            }
                        }
                    }
                }
            }
        }
    }
}
