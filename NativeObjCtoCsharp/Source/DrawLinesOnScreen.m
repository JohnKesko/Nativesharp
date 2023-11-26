//
//  CaptureAreaWithRectangle.m
//  NativeObjCtoCsharp
//
//  Created by Andreas Ohlstrom on 2023-07-07.
//

#import "../Headers/NativeObjCtoCsharp.h"


@interface CustomView : NSView
@property NSPoint startPoint;
@property NSPoint endPoint;
@end

@implementation CustomView

- (void)drawRect:(NSRect)rect
{
    [[NSColor redColor] set];
    [NSBezierPath strokeLineFromPoint:self.startPoint toPoint:self.endPoint];
}

-(void)windowWillClose:(NSNotification *)notification // Delegate when windows is to close
{
    [NSApp terminate:self];
}

@end


// Global variables to store the window and the custom view
NSWindow* customWindow = nil;
CustomView* customView = nil;


// Method to create the window. This is called once when the mouse button is first pressed.
void create_window(int x1, int y1, int width, int height)
{
//    NSScreen *mainScreen = [NSScreen mainScreen];
//    CGFloat screenHeight = mainScreen.frame.size.height;
    
    // Adjust the y-coordinate
//    y1 = screenHeight - y1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Create the transparent window to draw on
        NSRect customWindowRect = NSMakeRect(x1, y1, width, height);
        
        customWindow =
        [
            [NSWindow alloc]
            initWithContentRect:customWindowRect
            styleMask:NSWindowStyleMaskBorderless
            backing:NSBackingStoreBuffered
            defer:NO
        ];
        
        [customWindow setOpaque:NO];
//        [customWindow setBackgroundColor:[NSColor clearColor]];
        [customWindow setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
        [customWindow setLevel:NSScreenSaverWindowLevel];  // Set the window level
        
        // Create the CustomView for the customWindow
        customView = [[CustomView alloc] initWithFrame:customWindowRect];
        [customWindow setContentView:customView];
        [customWindow makeKeyAndOrderFront:nil];
    });
}


// Method to update the customView inside customWindow in realtime.
// This is called from C# when the mouse is moved while the button is pressed.
void update_mouse_coordinates(int x1, int y1, int x2, int y2)
{
    if (customView != nil)
    {
        NSScreen *mainScreen = [NSScreen mainScreen];
        CGFloat screenHeight = mainScreen.frame.size.height;
        
        // Adjust the y-coordinates
        y1 = screenHeight - y1;
        y2 = screenHeight - y2;
        
        customView.startPoint = NSMakePoint(x1, y1);
        customView.endPoint = NSMakePoint(x2, y2);
        [customView setNeedsDisplay:YES];  // Request the view to be redrawn
    }
}
