// drag
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

#import "AppDelegate.h"
#import "DragView.h"

static NSImage *MaskImage(NSScreen *screen, CGSize size, CGFloat cornerRadius)
{
    CGFloat scale = screen.backingScaleFactor;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:(NSInteger)(size.width * scale)
                             pixelsHigh:(NSInteger)(size.height * scale)
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSDeviceRGBColorSpace
                             bitmapFormat:NSAlphaFirstBitmapFormat
                             bytesPerRow:0
                             bitsPerPixel:0];
    
    NSGraphicsContext *current = [NSGraphicsContext currentContext];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    [NSGraphicsContext setCurrentContext:context];
    
    [[NSColor blackColor] set];
    [[NSBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width * scale, size.height * scale)
                                     xRadius:cornerRadius
                                     yRadius:cornerRadius] fill];
    
    [NSGraphicsContext setCurrentContext:current];
    
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image addRepresentation:rep];
    
    return image;
}

static NSScreen *ScreenForPoint(NSPoint point)
{
    for (NSScreen *screen in [NSScreen screens])
    {
        if (NSPointInRect(point, screen.frame))
        {
            return screen;
        }
    }
    
    return [NSScreen mainScreen];
}

static CGFloat const WindowHeight = 100;

@interface AppDelegate () <NSDraggingSource>

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) DragView *dragView;

@end

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // create a window
    CGPoint mouseLocation = [NSEvent mouseLocation];
    
    DragViewSize dragViewSize = DragViewSizeForCount(_fileURLs.count);
    CGFloat aspect = (CGFloat)dragViewSize.width / (CGFloat)dragViewSize.height;
    CGSize windowSize = CGSizeMake(WindowHeight * aspect, WindowHeight);
    
    CGRect windowFrame = {
        .origin.x = mouseLocation.x - windowSize.width / 2,
        .origin.y = mouseLocation.y - windowSize.height / 2,
        .size = windowSize
    };
    
    _window = [[NSWindow alloc] initWithContentRect:windowFrame
                                          styleMask:NSBorderlessWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:YES];
    _window.level = CGShieldingWindowLevel();
    _window.hasShadow = YES;
    _window.opaque = NO;
    _window.backgroundColor = [NSColor clearColor];
    
    // views
    CGRect viewFrame = { .origin = CGPointZero, .size = windowSize };
    
    // create visual effect view as the root container
    NSVisualEffectView *effectView = [[NSVisualEffectView alloc] initWithFrame:viewFrame];
    effectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    effectView.material = NSVisualEffectMaterialDark;
    effectView.maskImage = MaskImage(ScreenForPoint(mouseLocation), windowSize, 10);
    _window.contentView = effectView;
    
    // add drag view
    _dragView = [[DragView alloc] initWithFrame:viewFrame];
    _dragView.fileURLs = _fileURLs;
    [effectView addSubview:_dragView];
    
    [_window makeKeyAndOrderFront:nil];
    
    // drag view behavior
    __weak typeof(self) weakSelf = self;
    
    _dragView.startDrag = ^(NSEvent *event) {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:weakSelf.fileURLs.count];
        
        for (NSURL *URL in weakSelf.fileURLs)
        {
            NSPasteboardItem *pasteboardItem = [NSPasteboardItem new];
            NSData *data = [URL.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
            [pasteboardItem setData:data forType:(__bridge NSString*)kUTTypeFileURL];
            
            NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:pasteboardItem];
            
            item.imageComponentsProvider = ^{
                NSDraggingImageComponent *component = [NSDraggingImageComponent new];
                component.contents = [[NSWorkspace sharedWorkspace] iconForFile:URL.path];
                return @[component];
            };
            
            [items addObject:item];
        }
        
        NSDraggingSession *session = [weakSelf.dragView beginDraggingSessionWithItems:items event:event source:weakSelf];
        session.animatesToStartingPositionsOnCancelOrFail = YES;
        session.draggingFormation = NSDraggingFormationPile;
    };
}

#pragma mark - Dragging Source
-(void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    exit(EXIT_SUCCESS);
}

-(NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    switch (context)
    {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationNone;
    }
}

@end
