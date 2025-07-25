#ifndef Renderer_hpp
#define Renderer_hpp

#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>

class Renderer {
public:
    Renderer(void* device);
    ~Renderer();
    
    void render(void* drawable);
    
private:
    MTL::Device* _device;
    MTL::CommandQueue* _commandQueue;
    MTL::RenderPipelineState* _pipelineState;
    MTL::Buffer* _vertexBuffer;
    
    void buildShaders();
    void buildBuffers();
};

#endif
