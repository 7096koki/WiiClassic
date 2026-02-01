import SwiftUI
import SceneKit

struct Globe_wiiware: View {
    var body: some View {
        SceneView(
            scene: createGlobeScene(),
            pointOfView: nil,
            options: [
                .allowsCameraControl, // ユーザーが指で回転可能
                .autoenablesDefaultLighting // 基本的な照明を有効化
            ]
        )
        .ignoresSafeArea()
        .background(Color.black)
    }
    
    func createGlobeScene() -> SCNScene {
        let scene = SCNScene()
        
        // --- 1. GLOBE SETUP (地球の設定) ---
        let globe = SCNSphere(radius: 1.0)
        globe.segmentCount = 72 // 滑らかさの向上
        
        let material = SCNMaterial()
        // 指定されたテクスチャ画像（globe_image）を適用
        if let globeTexture = UIImage(named: "globe_image") {
            material.diffuse.contents = globeTexture
        } else {
            // 画像が見つからない場合のフォールバック（デバッグ用）
            material.diffuse.contents = UIColor.systemBlue
        }
        
        material.specular.contents = UIColor(white: 0.2, alpha: 1.0)
        material.shininess = 0.1
        globe.materials = [material]
        
        let globeNode = SCNNode(geometry: globe)
        globeNode.position = SCNVector3(0, 0, 0) // 中心に配置
        scene.rootNode.addChildNode(globeNode)
        
        // --- 2. FIXED STARS (増えない固定の星々) ---
        let starCount = 400
        let starRadius: Float = 40.0
        let starImage = createStarDotImage()
        
        for _ in 0..<starCount {
            let phi = Float.random(in: 0...(2 * .pi))
            let theta = acos(Float.random(in: -1...1))
            
            let x = starRadius * sin(theta) * cos(phi)
            let y = starRadius * sin(theta) * sin(phi)
            let z = starRadius * cos(theta)
            
            let starPlane = SCNPlane(width: 0.2, height: 0.2)
            starPlane.materials.first?.diffuse.contents = starImage
            starPlane.materials.first?.lightingModel = .constant
            
            let starNode = SCNNode(geometry: starPlane)
            starNode.position = SCNVector3(x, y, z)
            
            // ビルボード制約（常にカメラを向く）
            let billboard = SCNBillboardConstraint()
            billboard.freeAxes = .all
            starNode.constraints = [billboard]
            
            scene.rootNode.addChildNode(starNode)
        }
        
        // --- 3. CAMERA SETUP (地球中心の軸) ---
        let camera = SCNCamera()
        camera.zFar = 100
        camera.zNear = 0.1
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        // カメラの初期位置
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4.0)
        
        // カメラが常に地球の中心（0,0,0）を向くように制約を追加
        let lookAtConstraint = SCNLookAtConstraint(target: globeNode)
        lookAtConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAtConstraint]
        
        scene.rootNode.addChildNode(cameraNode)
        
        // --- 4. ENVIRONMENT LIGHTING (環境光) ---
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 150
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        scene.background.contents = UIColor.black
        
        return scene
    }
    
    // 星の点テクスチャ生成
    func createStarDotImage() -> UIImage {
        let size: CGFloat = 16
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: rect)
        }
    }
}
