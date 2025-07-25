#import "AppDelegate.h"
#import "MetalView.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create window
    NSRect frame = NSMakeRect(100, 100, 800, 600);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    [self.window setTitle:@"Metal Triangle"];
    [self.window makeKeyAndOrderFront:nil];
    
    // Create Metal view
    MetalView *metalView = [[MetalView alloc] initWithFrame:frame];
    [self.window setContentView:metalView];
    
    [self.window center];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end