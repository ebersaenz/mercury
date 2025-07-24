#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPPMetalRenderer : NSObject <MTKViewDelegate>
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;
@end

NS_ASSUME_NONNULL_END
