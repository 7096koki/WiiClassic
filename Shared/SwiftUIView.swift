import SwiftUI
import SceneKit

struct SphereView: View {
    var body: some View {
        // SceneViewを使ってSceneKitのシーンを表示
        SceneView(
            scene: makeScene(),
            options: [.allowsCameraControl, .autoenablesDefaultLighting]
        )
        .frame(width: 300, height: 300)
        .background(Color.black)
        .cornerRadius(150) // 丸く切り抜くとWiiのアイコンっぽくなる
    }
    
    // シーンを作成する関数
    func makeScene() -> SCNScene {
        let scene = SCNScene()
        
        // 1. ジオメトリ（形状）を作成: 半径1.0の球体
        let sphere = SCNSphere(radius: 1.0)
        
        // 2. マテリアル（見た目）を設定
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue // 基本の色
        material.specular.contents = UIColor.white    // 光の反射
        sphere.materials = [material]
        
        // 3. ノード（物体）を作成してシーンに追加
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(sphereNode)
        
        // 4. アニメーション（くるくる回す）
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat(Double.pi * 2), z: 0, duration: 5.0)
        let repeatRotate = SCNAction.repeatForever(rotate)
        sphereNode.runAction(repeatRotate)
        
        return scene
    }
}

struct SphereView_Previews: PreviewProvider {
    static var previews: some View {
        SphereView()
    }
}
