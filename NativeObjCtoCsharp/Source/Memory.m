//
//  Memory.m
//  NativeObjCtoCsharp
//
//  Created by Andreas Ohlstrom on 2023-05-05.
//

#import "../Headers/NativeObjCtoCsharp.h"

void free_memory(void* memoryPtr, MemoryType type, size_t windowsCount)
{
    if (type == WindowInfoArrayMemory && windowsCount > 0)
    {
        WindowInfo* windowsInfoArray = (WindowInfo*)memoryPtr;
        for (size_t i = 0; i < windowsCount; ++i)
        {
            free(windowsInfoArray[i].title);
            free(windowsInfoArray[i].bitmapData);
        }
    }

    free(memoryPtr);
}
