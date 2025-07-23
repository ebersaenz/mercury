#pragma once
#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>

// Forward declare Objective-C types as void* for C++
typedef void* MTKViewPtr;

class Renderer {
public:
    Renderer() = default;
    void drawInMTKView(MTKViewPtr view);
    void mtkViewDrawableSizeWillChange(MTKViewPtr view, CGSize size);
};
