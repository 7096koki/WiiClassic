import SwiftUI
import SceneKit

/// アセット内の画像を使用して表示するリアルな地球儀ビュー
struct Globe_wiiware: View {
    var body: some View {
        ZStack {
            // 背景色（宇宙の暗闇）
            Color.black.ignoresSafeArea()
            
            // 3Dシーンを表示するメインコンポーネント
            SceneView(
                scene: createEarthScene(),
                options: [
                    .allowsCameraControl,    // ユーザーが指で操作可能にする
                    .autoenablesDefaultLighting // 自動的に適切な照明を配置する
                ]
            )
            .ignoresSafeArea()
            
            // デザイン用のオーバーレイ
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Earth Live View")
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("3D Satellite Data Mode")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                Spacer()
                
                // 操作ガイド
                Text("Swipe to Rotate / Pinch to Zoom")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 30)
            }
        }
    }
    
    /// 地球の3Dシーンを構築する関数
    private func createEarthScene() -> SCNScene {
        let scene = SCNScene()
        
        // 1. 地球の形状（球体）を作成
        // 半径5.0、セグメント数を多め（96）にして滑らかにする
        let globeGeometry = SCNSphere(radius: 5.0)
        globeGeometry.segmentCount = 96
        
        let globeNode = SCNNode(geometry: globeGeometry)
        
        // 2. マテリアル（質感と画像）の設定
        let material = SCNMaterial()
        
        // --- 【重要】アセットに入れた画像を指定 ---
        // 画像の名前が "earth_map" でない場合は、下の文字列を書き換えてください
        if let earthImage = UIImage(named: "globe") {
            material.diffuse.contents = earthImage
        } else {
            // 画像が見つからない場合のフォールバック（青い球体）
            material.diffuse.contents = UIColor.systemBlue
        }
        
        // 鏡面反射の設定（海などが光を反射するようにする）
        material.specular.contents = UIColor(white: 0.5, alpha: 1.0)
        material.shininess = 15.0
        
        globeGeometry.materials = [material]
        
        // 3. 地軸の傾きを設定（約23.4度）
        // SceneKitはラジアンを使うので変換して適用
        globeNode.eulerAngles.x = Float(-23.4 * .pi / 180)
        
        // シーンに地球を追加
        scene.rootNode.addChildNode(globeNode)
        
        // 5. 環境光の調整（少しだけ暗い部分も見えるように）
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor(white: 0.2, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // 背景を宇宙（黒）に設定
        scene.background.contents = UIColor.black
        
        return scene
    }
}

// Xcodeのプレビュー用
struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        Globe_wiiware()
    }
}
