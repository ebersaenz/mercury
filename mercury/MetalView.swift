import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {
    class Coordinator {
        let renderer = CPPMetalRenderer()
    }
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = context.coordinator.renderer
        mtkView.clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
        return mtkView
    }
    func updateNSView(_ nsView: MTKView, context: Context) {}
}
