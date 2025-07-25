#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION

#include "Renderer.hpp"
#include <iostream>
#include <simd/simd.h>

struct Vertex {
    simd::float2 position;
    simd::float3 color;
};

Renderer::Renderer(void* device) : _device((MTL::Device*)device) {
    _device->retain();
    _commandQueue = _device->newCommandQueue();
    buildShaders();
    buildBuffers();
}

Renderer::~Renderer() {
    _vertexBuffer->release();
    _pipelineState->release();
    _commandQueue->release();
    _device->release();
}

void Renderer::buildShaders() {
    const char* shaderSrc = R"(
#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
    float3 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 color;
};

vertex VertexOut vertex_main(Vertex in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    out.color = in.color;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(in.color, 1.0);
}
)";

    NS::Error* error = nullptr;
    MTL::Library* library = _device->newLibrary(NS::String::string(shaderSrc, NS::ASCIIStringEncoding), nullptr, &error);
    
    if (!library) {
        std::cerr << "Failed to create library: " << error->localizedDescription()->utf8String() << std::endl;
        return;
    }
    
    MTL::Function* vertexFunction = library->newFunction(NS::String::string("vertex_main", NS::ASCIIStringEncoding));
    MTL::Function* fragmentFunction = library->newFunction(NS::String::string("fragment_main", NS::ASCIIStringEncoding));
    
    MTL::RenderPipelineDescriptor* pipelineDescriptor = MTL::RenderPipelineDescriptor::alloc()->init();
    pipelineDescriptor->setVertexFunction(vertexFunction);
    pipelineDescriptor->setFragmentFunction(fragmentFunction);
    pipelineDescriptor->colorAttachments()->object(0)->setPixelFormat(MTL::PixelFormatBGRA8Unorm);
    
    // Vertex descriptor
    MTL::VertexDescriptor* vertexDescriptor = MTL::VertexDescriptor::alloc()->init();
    vertexDescriptor->attributes()->object(0)->setFormat(MTL::VertexFormatFloat2);
    vertexDescriptor->attributes()->object(0)->setOffset(0);
    vertexDescriptor->attributes()->object(0)->setBufferIndex(0);
    
    vertexDescriptor->attributes()->object(1)->setFormat(MTL::VertexFormatFloat3);
    vertexDescriptor->attributes()->object(1)->setOffset(sizeof(simd::float2));
    vertexDescriptor->attributes()->object(1)->setBufferIndex(0);
    
    vertexDescriptor->layouts()->object(0)->setStride(sizeof(Vertex));
    vertexDescriptor->layouts()->object(0)->setStepFunction(MTL::VertexStepFunctionPerVertex);
    
    pipelineDescriptor->setVertexDescriptor(vertexDescriptor);
    
    _pipelineState = _device->newRenderPipelineState(pipelineDescriptor, &error);
    
    if (!_pipelineState) {
        std::cerr << "Failed to create pipeline state: " << error->localizedDescription()->utf8String() << std::endl;
    }
    
    vertexDescriptor->release();
    pipelineDescriptor->release();
    vertexFunction->release();
    fragmentFunction->release();
    library->release();
}

void Renderer::buildBuffers() {
    Vertex vertices[] = {
        { {  0.0f,  0.8f }, { 1.0f, 0.0f, 0.0f } },  // Top vertex - Red
        { { -0.8f, -0.8f }, { 0.0f, 1.0f, 0.0f } },  // Bottom left - Green
        { {  0.8f, -0.8f }, { 0.0f, 0.0f, 1.0f } }   // Bottom right - Blue
    };
    
    _vertexBuffer = _device->newBuffer(vertices, sizeof(vertices), MTL::ResourceStorageModeManaged);
}

void Renderer::render(void* drawable) {
    CA::MetalDrawable* metalDrawable = (CA::MetalDrawable*)drawable;
    
    MTL::CommandBuffer* commandBuffer = _commandQueue->commandBuffer();
    MTL::RenderPassDescriptor* renderPassDescriptor = MTL::RenderPassDescriptor::alloc()->init();
    
    renderPassDescriptor->colorAttachments()->object(0)->setTexture(metalDrawable->texture());
    renderPassDescriptor->colorAttachments()->object(0)->setLoadAction(MTL::LoadActionClear);
    renderPassDescriptor->colorAttachments()->object(0)->setClearColor(MTL::ClearColor::Make(0.2, 0.2, 0.2, 1.0));
    renderPassDescriptor->colorAttachments()->object(0)->setStoreAction(MTL::StoreActionStore);
    
    MTL::RenderCommandEncoder* renderEncoder = commandBuffer->renderCommandEncoder(renderPassDescriptor);
    renderEncoder->setRenderPipelineState(_pipelineState);
    renderEncoder->setVertexBuffer(_vertexBuffer, 0, 0);
    renderEncoder->drawPrimitives(MTL::PrimitiveTypeTriangle, NS::UInteger(0), NS::UInteger(3));
    renderEncoder->endEncoding();
    
    commandBuffer->presentDrawable(metalDrawable);
    commandBuffer->commit();
    
    renderPassDescriptor->release();
}
