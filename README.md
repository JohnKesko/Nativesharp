# Nativesharp
--------
### A tiny shared library for macOS
##### Latest update: 2023-04-25
###
- Written in Objective-C

(At the moment, this is a tiny shared library (.dylib) that exposes normal things we want to use - but more are to come.
The library uses macOS latest SDK and uses only the following headers:

##### Objective-C:
```
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
```
And the methods we can use:
```
const char* get_single_active_window_title(void);
const char* get_all_active_windows_titles(void);
size_t get_all_active_windows_info(WindowInfo** windowsInfoArray);
void free_memory(void* memoryPtr, size_t windowsCount);
```

#### The library is under construction, so use at your own risk :)
-------------
### Summary:
Nativesharp is a shared library (.dylib) containing methods to interact with any external window that is currently running on a macOS computer.
For example, the issue I had was to interact with an external window independently which framework I had created my GUI in. 
I'm using wxWidgets or C# and Avalonia, so I had to have an independent library that I could use for any lanugage basically.
The library is therefore intented to be tiny so you can choose whatever language you want.

-------------
### Description
A macOS window can be described as follows using the .dylib:

Native Objective-C:
```
typedef struct {
    char* title;
    int width;
    int height;
    uint8_t* bitmapData;
} WindowInfo;
```
#### To use it in various languages:

##### In C#:
```
[StructLayout(LayoutKind.Sequential)]
public struct WindowInfo
{
    public IntPtr Title;
    public int Width;
    public int Height;
    public IntPtr BitmapData;
}
```

##### In Python:
```
import ctypes

# Load the shared library
native_lib = ctypes.CDLL('path/to/your/library.dylib')

class WindowInfo(ctypes.Structure):
    _fields_ = [
        ("Title", ctypes.c_char_p),
        ("Width", ctypes.c_int),
        ("Height", ctypes.c_int),
        ("BitmapData", ctypes.POINTER(ctypes.c_uint8)),
    ]

native_lib.get_all_active_windows_info.restype = ctypes.c_size_t
native_lib.get_all_active_windows_info.argtypes = [ctypes.POINTER(ctypes.POINTER(WindowInfo))]
```

##### In Java:
```
import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Pointer;
import com.sun.jna.Structure;
import java.util.Arrays;
import java.util.List;

public class Main {
    public interface NativeLibrary extends Library {
        NativeLibrary INSTANCE = (NativeLibrary) Native.load("path/to/your/library.dylib", NativeLibrary.class);
        
        // Other function declarations...

        class WindowInfo extends Structure {
            public String Title;
            public int Width;
            public int Height;
            public Pointer BitmapData;
            
            @Override
            protected List<String> getFieldOrder() {
                return Arrays.asList("Title", "Width", "Height", "BitmapData");
            }
        }

        long get_all_active_windows_info(PointerByReference windowsInfoArrayPtr);
    }
}

```

##### In Javascript:
```
const ffi = require('ffi-napi');
const ref = require('ref-napi');
const Struct = require('ref-struct-di')(ref);

const WindowInfo = Struct({
  'Title': ref.types.CString,
  'Width': ref.types.int,
  'Height': ref.types.int,
  'BitmapData': ref.refType(ref.types.uint8),
});

const nativeLib = ffi.Library('path/to/your/library.dylib', {
  // Other function declarations...
  'get_all_active_windows_info': [ref.types.size_t, [ref.refType(ref.refType(WindowInfo))]],
});
```
-------------
#### Title: 
A string that contains the window title. This could be an active tab in your browser as well (example below in C#).
#### Width + Height
Width + Height: The width and height of each window.
#### BitmapData
BitmapData: Raw pixels for each window. In C#, we can describe this as an byte[] of raw pixels.

-------------
### C# Example:
1. Download the .dylib and place it anywhere.

2. Easiest way is to have a static class that contains all exposed methods.
```
public static class ExposedMethods
{
    private const string NativeLibrary = "/Path/To/Nativesharp.dylib";
    
    [DllImport(NativeLibrary)]
    public static extern IntPtr get_single_active_window_title();
    
    [DllImport(NativeLibrary)]
    public static extern IntPtr get_all_active_windows_titles();
    
    [DllImport(NativeLibrary)]
    public static extern ulong get_all_active_windows_info(out IntPtr arrayOfStructs);
    
    [DllImport(NativeLibrary)]
    public static extern void free_memory(IntPtr memoryPtr, ulong windowsCount);
}
```

3. Then in another class. We can do an implementation and check if a browser has an active tab that contains "YouTube":
```
public class MultiWindowInfo
{
    public MultiWindowInfo()
    {
        IntPtr windowInfoArrayPtr;
        ulong windowsCount = ExposedMethods.get_all_active_windows_info(out windowInfoArrayPtr);

        for (ulong i = 0; i < windowsCount; ++i)
        {
            IntPtr currentWindowInfoPtr = IntPtr.Add(windowInfoArrayPtr, (int)(i * (ulong)Marshal.SizeOf(typeof(WindowInfo))));
            
            WindowInfo window = Marshal.PtrToStructure<WindowInfo>(currentWindowInfoPtr);
            string windowTitle = Marshal.PtrToStringUTF8(window.Title);
            
            // Change to something else to test.
            if (windowTitle.Contains("YouTube"))
            {
                // Assuming RGBA format
                byte[] rawPixels = new byte[window.Width * window.Height * 4];
                Marshal.Copy(window.BitmapData, rawPixels, 0, rawPixels.Length);

                Console.WriteLine($"Window title: {windowTitle}");
                Console.WriteLine($"Window width: {window.Width}");
                Console.WriteLine($"Window height: {window.Height}");
                Console.WriteLine($"Window raw pixels: {rawPixels.Length}");
                return;
            }
        }
        
        ExposedMethods.free_memory(windowInfoArrayPtr, windowsCount);
    }
}
```
