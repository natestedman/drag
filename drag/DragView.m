// drag
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

#import "DragView.h"

DragViewSize DragViewSizeForCount(NSUInteger count)
{
    // determine the width
    DragViewSize size = { 1, 0 };
    for (; size.width * size.width < count; size.width++);
    
    // determine height based on width
    size.height = count / size.width + ((count % size.width) == 0 ? 0 : 1);
    
    return size;
}

static inline CGSize FitSizeToSize(CGSize size, CGSize fitToSize)
{
    CGFloat ratio = MIN(1.0, MIN(fitToSize.width / size.width, fitToSize.height / size.height));
    size.width = roundf(size.width * ratio);
    size.height = roundf(size.height * ratio);
    
    return size;
}

@implementation DragView

-(void)mouseDown:(NSEvent *)event
{
    if (_startDrag)
    {
        _startDrag(event);
    }
    else
    {
        [super mouseDown:event];
    }
}

-(BOOL)isFlipped
{
    return YES;
}

-(void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSInteger count = _fileURLs.count;
    DragViewSize dragViewSize = DragViewSizeForCount(count);
    
    CGRect rect = CGRectInset(self.bounds, 5, 5);
    CGRect scaled = CGRectMake(rect.origin.x,
                               rect.origin.y,
                               rect.size.width / dragViewSize.width,
                               rect.size.height / dragViewSize.height);
    
    for (NSInteger i = 0; i < count; i++)
    {
        // inset rects for separators
        CGRect inset = CGRectInset(scaled, 2, 2);
        
        // base origins before centering image
        CGFloat originX = inset.origin.x + scaled.size.width * (i % dragViewSize.width);
        CGFloat originY = inset.origin.y + scaled.size.height * (i / dragViewSize.width);
        
        // load image for file
        NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:_fileURLs[i].path];
        CGSize size = FitSizeToSize(image.size, inset.size);
        
        [image drawInRect:CGRectMake(originX + (inset.size.width - size.width) / 2.0,
                                     originY + (inset.size.height - size.height) / 2.0,
                                     size.width,
                                     size.height)];
    }
}

@end
