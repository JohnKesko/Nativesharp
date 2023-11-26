//
//  SingleWindow.m
//
//  Created by Andreas Ohlstrom on 2023-04-25.
//
#import "../Headers/NativeObjCtoCsharp.h"

const char* get_single_active_window_title(void)
{
    NSWorkspace* workspace = [NSWorkspace sharedWorkspace];
    NSArray* runningApps = [workspace runningApplications];
    
    for (NSRunningApplication* app in runningApps)
    {
        if ([app isActive])
        {
            NSString *windowTitle = [app localizedName];
            const char* utf8WindowTitle = [windowTitle UTF8String];
            char* result = (malloc(strlen(utf8WindowTitle) + 1)); // static_cast<char*> if Objective-C++
            strcpy(result, utf8WindowTitle);
            
            return result;
        }
    }
    
    return NULL;
}
