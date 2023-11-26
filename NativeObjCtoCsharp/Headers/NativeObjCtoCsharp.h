//
//  NativeObjCtoCsharp.h
//
//  Created by Andreas Ohlstrom on 2023-04-25.
//

//#include <Foundation/Foundation.h>
//#include <AppKit/AppKit.h>
//#include <CoreGraphics/CoreGraphics.h>
#include <Cocoa/Cocoa.h>


// Struct containing information for each window.
typedef struct {
    char* title;
    int width;
    int height;
    uint8_t* bitmapData;
} WindowInfo;

typedef enum {
    GenericMemory,
    WindowInfoArrayMemory
} MemoryType;

#ifdef __cplusplus
extern "C" {
#endif

// Get running windows and capture raw pixels within the bounds of each window
const char* get_single_active_window_title(void);
const char* get_all_active_windows_titles(void);
size_t get_all_active_windows_info(WindowInfo** windowsInfoArray);

// Capture an area with the mouse [return raw pixels]
uint8_t* capture_area_with_mouse(int x, int y, int width, int height);

// Create a window to draw on
void create_window(int x, int y, int width, int height);

// Update mouse coordinates that are passed from C#
void update_mouse_coordinates(int x1, int y1, int x2, int y2);

// Memory management
void free_memory(void* memoryPtr, MemoryType type, size_t windowsCount);

#ifdef __cplusplus
}
#endif
