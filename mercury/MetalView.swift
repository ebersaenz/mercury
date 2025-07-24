import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {

    func makeCoordinator() -> Renderer {
        Renderer()
    }

    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = context.coordinator
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        return mtkView
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}
}
