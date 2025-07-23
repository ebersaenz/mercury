#import "CPPMetalRenderer.h"
#include "Renderer.hpp"

@interface CPPMetalRenderer () {
    Renderer* cppRenderer;
}
@end

@implementation CPPMetalRenderer

- (instancetype)init {
    self = [super init];
    if (self) {
        cppRenderer = new Renderer();
    }
    return self;
}

- (void)dealloc {
    delete cppRenderer;
}

- (void)drawInMTKView:(MTKView *)view {
    cppRenderer->drawInMTKView((__bridge void*)view);
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    cppRenderer->mtkViewDrawableSizeWillChange((__bridge void*)view, size);
}

@end
