//
//  CaptureArea.m
//  NativeObjCtoCsharp
//
//  Created by Andreas Ohlstrom on 2023-05-05.
//

#import "../Headers/NativeObjCtoCsharp.h"

uint8_t* capture_area_with_mouse(int x, int y, int width, int height)
{
    // Incoming data from mouse in 2D
    CGRect current_area;
    current_area.origin.x = x;
    current_area.origin.y = y;
    current_area.size.width = width;
    current_area.size.height = height;

    // Define the bitmap
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4; // Assuming RGBA format
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    // Allocate memory for raw pixels
    uint8_t* bitmapData = (uint8_t*) calloc(height * width * bytesPerPixel, sizeof(uint8_t));
    
    // Draw the image where the bitmapData can be found.
    CGContextRef context = CGBitmapContextCreate(bitmapData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | (CGImageAlphaInfo)kCGBitmapByteOrder32Big);

    // Capture a portion of the screen and draw it into the context
    CGImageRef screenshotImage = CGWindowListCreateImage(current_area, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    
    if (!screenshotImage)
    {
        // Handle the error, e.g., return null or log an error message
        free(bitmapData);
        return NULL;
    }

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), screenshotImage);
    NSLog(@"Capturing area: x=%d, y=%d, width=%d, height=%d", x, y, width, height);
    
    // Release resources
    CGImageRelease(screenshotImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Return the raw pixels
    return bitmapData;
}
