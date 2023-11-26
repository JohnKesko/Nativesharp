# Nativesharp

### Tiny shared library for macOS to interact with external windows at runtime
##### Latest update: 2023-11-26

#### The library is under construction, so use at your own risk!

#### Roadmap 2024
- USB
- Keyboard

-------------
### Summary:
Nativesharp is a shared library (.dylib) that exposes methods you can interact with.
The main purpose was to interact with any external window that is currently running on a macOS computer.

For example, the issue I had was to interact with an external window, no matter how many monitors I used and no matter which framework I had created my UI in.

I'm using Avalonia for the most part, so I had to have an independent library that I could use for any lanugage basically.
The library is intented to be tiny for small things so you can choose whatever language you want.

### A window in Nativesharp can be defined:

#### Title: 
A string that contains the window title. This could be an active tab in your browser as well (see example below).
#### Width + Height
Width + Height: The width and height of each window.
#### BitmapData
BitmapData: Raw pixels byte[] for each window.
#
### Objective-C:
```
typedef struct {
    char* title;
    int width;
    int height;
    uint8_t* bitmapData;
} WindowInfo;
```
Exposed methods:
```
const char* get_single_active_window_title(void);
const char* get_all_active_windows_titles(void);
size_t get_all_active_windows_info(WindowInfo** windowsInfoArray);
void free_memory(void* memoryPtr, size_t windowsCount);
```

##### Use it in C#:
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
-------------
### C# Example:
1. Download the .dylib and place it anywhere or just clone and compile it.

2. Easiest way to get started is to have a static class that contains all exposed methods.
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

    [StructLayout(LayoutKind.Sequential)]
    public struct WindowInfo
    {
        public IntPtr Title;
        public int Width;
        public int Height;
        public IntPtr BitmapData;
    }
}
```

3. Then in your other class, we can do an implementation and check if a browser has an active tab that contains "YouTube":
```
using System.Runtime.InteropServices;
using TestingFindMacOSWindow.Bindings;

namespace TestingFindMacOSWindow.Examples;

public class MultiWindowInfo
{
    public MultiWindowInfo()
    {
        IntPtr windowInfoArrayPtr;
        ulong windowsCount = ExposedMethods.get_all_active_windows_info(out windowInfoArrayPtr);

        for (ulong i = 0; i < windowsCount; ++i)
        {
            IntPtr currentWindowInfoPtr = IntPtr.Add(windowInfoArrayPtr, (int)(i * (ulong)Marshal.SizeOf(typeof(ExposedMethods.WindowInfo))));
            
            ExposedMethods.WindowInfo window = Marshal.PtrToStructure<ExposedMethods.WindowInfo>(currentWindowInfoPtr);
            string windowTitle = Marshal.PtrToStringUTF8(window.Title);
            
            // Change to something else to test.
            if (windowTitle.Contains("YouTube"))
            {
                // Assuming RGBA format and initialize the array to the size of the window width and height and we add 4 bytes for RGBA channels.
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
