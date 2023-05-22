import ARKit
import RealityKit
import SwiftUI

struct RealityKitView: UIViewRepresentable {
    @Binding var currentAnimal: String

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        loadARModel(view)
        addCoachingOverlay(session, view)
        return view
    }
    
    func loadARModel(_ view: ARView) {
        switch currentAnimal {
        case "shark":
            let anchor = try! Experience.loadShark()
            view.scene.addAnchor(anchor)
        case "octopus":
            let anchor = try! Experience.loadOctopus()
            view.scene.addAnchor(anchor)
        case "crab":
            let anchor = try! Experience.loadCrab()
            view.scene.addAnchor(anchor)
        case "whale":
            let anchor = try! Experience.loadWhale()
            view.scene.addAnchor(anchor)
        case "dolphin":
            let anchor = try! Experience.loadDolphin()
            view.scene.addAnchor(anchor)
        default:
            break;
        }
    }
    
    func addCoachingOverlay(_ session: ARSession, _ view: ARView) {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)
    }

    func updateUIView(_ view: ARView, context: Context) {}
}
