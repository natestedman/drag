// drag
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

#import <Cocoa/Cocoa.h>

typedef struct
{
    NSUInteger width;
    NSUInteger height;
} DragViewSize;

FOUNDATION_EXTERN DragViewSize DragViewSizeForCount(NSUInteger count);

@interface DragView : NSView

@property (nonatomic, nullable, copy) NSArray<NSURL*> *fileURLs;

@property (nonatomic, nullable, copy) void(^startDrag)(NSEvent *__nonnull mouseDownEvent);

@end
