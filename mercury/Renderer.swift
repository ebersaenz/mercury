//
//  Renderer.swift
//  mercury
//
//  Created by Eber Saenz on 7/24/25.
//
import MetalKit
import simd

class Renderer : NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var cubeVertexBuffer: MTLBuffer!
    var cubeColorBuffer: MTLBuffer!
    var cubeIndexBuffer: MTLBuffer!
    var rotation: Float = 0
    
    let cubeVertices: [Float] = [
        // Front
        -1, -1,  1,
         1, -1,  1,
         1,  1,  1,
        -1,  1,  1,
        // Back
        -1, -1, -1,
         1, -1, -1,
         1,  1, -1,
        -1,  1, -1
    ]
    
    let cubeColors: [Float] = [
        1,0,0,   1,0.5,0,   1,1,0,   0,1,0, // front
        0,1,1,   0,0,1,   0.5,0,1,   1,0,1 // back
    ]
    
    let cubeIndices: [UInt16] = [
        2,1,0, 0,3,2, // front
        6,5,1, 1,2,6, // right
        7,4,5, 5,6,7, // back
        3,0,4, 4,7,3, // left
        6,2,3, 3,7,6, // top
        1,5,4, 4,0,1  // bottom
    ]
    
    
    override init() {
        super.init()
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        let library = device.makeDefaultLibrary()
        let vertexFunc = library?.makeFunction(name: "vertex_main")
        let fragmentFunc = library?.makeFunction(name: "fragment_main")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 3
        vertexDescriptor.layouts[1].stride = MemoryLayout<Float>.size * 3
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        cubeVertexBuffer = device.makeBuffer(bytes: cubeVertices, length: MemoryLayout<Float>.size * cubeVertices.count, options: [])
        cubeColorBuffer = device.makeBuffer(bytes: cubeColors, length: MemoryLayout<Float>.size * cubeColors.count, options: [])
        cubeIndexBuffer = device.makeBuffer(bytes: cubeIndices, length: MemoryLayout<UInt16>.size * cubeIndices.count, options: [])
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
              else { return }

        rotation += 0.01
        let modelMatrix = matrix_float4x4(rotationY: rotation) * matrix_float4x4(rotationX: rotation * 0.7)
        let aspect = Float(view.drawableSize.width / view.drawableSize.height)
        let projMatrix = matrix_float4x4(perspectiveFov: .pi/4, aspect: aspect, nearZ: 0.1, farZ: 100)
        var mvp = projMatrix * matrix_float4x4(translation: [0,0,-5]) * modelMatrix

        encoder.setCullMode(.back)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(cubeVertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(cubeColorBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&mvp, length: MemoryLayout<matrix_float4x4>.size, index: 2)
        encoder.drawIndexedPrimitives(type: .triangle, indexCount: cubeIndices.count, indexType: .uint16, indexBuffer: cubeIndexBuffer, indexBufferOffset: 0)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

extension matrix_float4x4 {
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3 = SIMD4<Float>(translation, 1)
    }
    init(rotationX angle: Float) {
        self = matrix_identity_float4x4
        columns.1.y = cos(angle)
        columns.1.z = sin(angle)
        columns.2.y = -sin(angle)
        columns.2.z = cos(angle)
    }
    init(rotationY angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.z = -sin(angle)
        columns.2.x = sin(angle)
        columns.2.z = cos(angle)
    }
    init(perspectiveFov fovY: Float, aspect: Float, nearZ: Float, farZ: Float) {
        let y = 1 / tan(fovY * 0.5)
        let x = y / aspect
        let z = farZ / (nearZ - farZ)
        self.init()
        columns = (
            SIMD4<Float>(x, 0, 0, 0),
            SIMD4<Float>(0, y, 0, 0),
            SIMD4<Float>(0, 0, z, -1),
            SIMD4<Float>(0, 0, z * nearZ, 0)
        )
    }
}
