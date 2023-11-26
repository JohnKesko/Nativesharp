//
//  MultiWindowExtra.m
//
//  Created by Andreas Ohlstrom on 2023-04-25.
//
#import "../Headers/NativeObjCtoCsharp.h"

size_t get_all_active_windows_info(WindowInfo** ptrWindowsInfoarray)
{
    NSMutableArray* arrWindowsInfo = [NSMutableArray new];
    CFArrayRef arrWindowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    NSArray* arrWindows = CFBridgingRelease(arrWindowList);

    for (NSDictionary* window in arrWindows)
    {
        NSString* windowTitle = window[(id)kCGWindowName];
        if (!windowTitle) continue;

        NSNumber* windowNumber = window[(id)kCGWindowNumber];
        CGWindowID windowID = [windowNumber unsignedIntValue];

        CGRect windowBounds;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)window[(id)kCGWindowBounds], &windowBounds);
        int width = (int)windowBounds.size.width;
        int height = (int)windowBounds.size.height;

        // Capture window image and get raw pixel data
        CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, windowID, kCGWindowImageBoundsIgnoreFraming);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSUInteger bytesPerPixel = 4; // Assuming RGBA format
        NSUInteger bitsPerComponent = 8;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        uint8_t* bitmapData = (uint8_t*) calloc(height * width * bytesPerPixel, sizeof(uint8_t));
        CGContextRef context = CGBitmapContextCreate(bitmapData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | (CGImageAlphaInfo)kCGBitmapByteOrder32Big);

        NSGraphicsContext* graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:graphicsContext];
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), windowImage);
        [NSGraphicsContext restoreGraphicsState];

        // Create and populate WindowInfo struct
        WindowInfo windowInfo;
        windowInfo.title = strdup([windowTitle UTF8String]);
        windowInfo.width = width;
        windowInfo.height = height;
        windowInfo.bitmapData = bitmapData;

        [arrWindowsInfo addObject:[NSValue valueWithBytes:&windowInfo objCType:@encode(WindowInfo)]];
    }

    // Convert the NSMutableArray to a C array and return it
    WindowInfo* windowsInfoArray = (malloc(sizeof(WindowInfo) * arrWindowsInfo.count)); // static_cast<WindowInfo*> if Objective-C++
    for (NSUInteger i = 0; i < arrWindowsInfo.count; ++i)
    {
        [arrWindowsInfo[i] getValue:&windowsInfoArray[i]];
    }
    
    *ptrWindowsInfoarray = windowsInfoArray;
    return arrWindowsInfo.count;
}
