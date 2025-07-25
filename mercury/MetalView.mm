#import "MetalView.h"
#import "Renderer.hpp"

@implementation MetalView {
    CAMetalLayer *_metalLayer;
    Renderer *_renderer;
    CVDisplayLinkRef _displayLink;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setupMetal];
        [self setupDisplayLink];
    }
    return self;
}

- (void)setupMetal {
    _metalLayer = [CAMetalLayer layer];
    _metalLayer.device = MTLCreateSystemDefaultDevice();
    _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    _metalLayer.framebufferOnly = YES;
    
    [self setLayer:_metalLayer];
    [self setWantsLayer:YES];
    
    _renderer = new Renderer((__bridge void*)_metalLayer.device);
}

- (void)setupDisplayLink {
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(_displayLink, &displayLinkCallback, (__bridge void*)self);
    CVDisplayLinkStart(_displayLink);
}

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) {
    MetalView *view = (__bridge MetalView*)displayLinkContext;
    [view render];
    return kCVReturnSuccess;
}

- (void)render {
    @autoreleasepool {
        id<CAMetalDrawable> drawable = [_metalLayer nextDrawable];
        if (!drawable) return;
        
        _renderer->render((__bridge void*)drawable);
    }
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    _metalLayer.frame = self.bounds;
    _metalLayer.drawableSize = CGSizeMake(newSize.width, newSize.height);
}

- (void)dealloc {
    if (_displayLink) {
        CVDisplayLinkStop(_displayLink);
        CVDisplayLinkRelease(_displayLink);
    }
    delete _renderer;
}

@end