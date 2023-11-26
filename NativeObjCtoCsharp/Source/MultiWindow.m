//
//  MultiWindow.m
//
//  Created by Andreas Ohlstrom on 2023-04-25.
//
#import "../Headers/NativeObjCtoCsharp.h"

const char* get_all_active_windows_titles(void)
{
    NSMutableArray* arrWindowTitles = [NSMutableArray new]; // This array contains all the found windows
    CFArrayRef arrWindowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    NSArray* arrWindows = CFBridgingRelease(arrWindowList);

    for (NSDictionary* window in arrWindows)
    {
        NSString* windowTitle = window[(id)kCGWindowName];
        
        if (windowTitle)
        {
            [arrWindowTitles addObject:windowTitle]; // Add each window title to the array
        }
    }

    NSString* joinedTitles = [arrWindowTitles componentsJoinedByString:@"\n"];
    const char* utf8JoinedTitles = [joinedTitles UTF8String];
    char* result = (malloc(strlen(utf8JoinedTitles) + 1)); // static_cast<char*> if Objective-C++
    strcpy(result, utf8JoinedTitles);

    return result;
}
