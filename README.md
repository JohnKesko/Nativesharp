# Nativesharp
--------
### C# bindings for macOS
##### Latest update: 2023-04-25
###
- Written in Objective-C

Tested with:
- macOS: Ventura 13.0 / M1 Pro
- C# 11
- .NET 7

(At the moment, this is a tiny library that exposes normal things but more are to come.)
The library uses macOS latest SDK and uses only the following headers:
##### Objective-C:
```
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
```
### The library is under construction, so use at your own risk :)
-------------
#### Summary:
Nativesharp is a shared library (.dynlib) containg C# bindings to interact with any external window that is currently running on a macOS computer.
For example, the issue I had was to interact with an external window independently which C# framework I had created my GUI in, plus I didn't want to use Xamarin or any NuGet package.
This library is therefore intented to be tiny and lightweight and let's your interact with any external window the on a mac computer.

-------------
#### Description
A macOS window can be described as follows using the .dylib:
```
[StructLayout(LayoutKind.Sequential)]
public struct WindowInfo
{
    public IntPtr Title;  // NSString* in native code
    public int Width;
    public int Height;
    public IntPtr BitmapData;  // uint8_t* in native code
}
```

##### Title: 
A string that contains the title. This could be an active tab in your browser as well (example below).
##### Width + Height
Width + Height: The width and height of each window.
##### BitmapData
BitmapData: In C#, we can describe this as an byte[] of raw pixels for each window.

-------------
### Example:
1. Download the .dylib and place it anywhere.

2. Easiest way is to have a static class that contains all exposed methods.
```
public static class ExposedMethods
{
    private const string NativeLibrary = "/Path/To/NativeObjCtoCsharp.dylib";
    
    [DllImport(NativeLibrary)]
    public static extern ulong get_all_active_windows_info(out IntPtr arrayOfWindows);
    
    [DllImport(NativeLibrary)]
    public static extern void free_memory(IntPtr memoryPtrToRelease, ulong windowsCount);
}
```

3. Then in Main for example. We can check if a browser has an active tab that contains "YouTube":
```
class Program 
{
    static void Main() 
    {
        IntPtr windowInfoArrayPtr;
        ulong windowsCount = ExposedMethods.get_all_active_windows_info(out windowInfoArrayPtr);

        for (ulong i = 0; i < windowsCount; ++i)
        {
            IntPtr currentWindowInfoPtr = IntPtr.Add(windowInfoArrayPtr, (int)(i * (ulong)Marshal.SizeOf(typeof(WindowInfo))));
            
            WindowInfo window = Marshal.PtrToStructure<WindowInfo>(currentWindowInfoPtr);
            string windowTitle = Marshal.PtrToStringUTF8(window.Title);

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

ExposedMethods.free_memory(windowInfoArrayPtr, windowsCount);
```
