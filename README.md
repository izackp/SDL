# SDL
Swift library for SDL2. 

C libraries use their respective names for their module names `import SDL2_TTF`. The swifty wrappers append 'Swift' onto the module name `import SDL2_TTFSwift`. Not sure what's the cleanest solution tbh. As a matter of fact, it's likely that I'll refactor the swifty wrappers frequently.

This repo also serves as a minimum example project for running on windows. _Note: I have yet to test SDL2_TTFSwift on windows_


### Running on Windows

1. Follow the instructions here to install swift: https://github.com/pwsacademy/swift-setup/tree/main/platforms/windows

2. Follow the instructions here to setup vscode: https://github.com/pwsacademy/swift-setup/tree/main/editors/vscode-windows

    * Optional: Create a test hello world project to make sure and hit a breakpoint to make sure everything is working

3. Run .downloadBinaries.ps1 **Or:** 
    * Download SDL2 manually.
    * Copy SDL2.dll, SDL2_ttf.dll, etc files into this folder
    * Copy the appropiate files into `windows_bin\include` and `windows_bin\lib\x64`

4. Open the project folder in vscode and hitting the Run and debug button should work fine.

If you wish to run manually without vscode then run:

```bash
swift build --product "SDLDemo" -c debug -Xswiftc -Iwindows_bin\\include -Xlinker -Lwindows_bin\\lib\\x64
.\.build\debug\SDLDemo.exe
```

We're using `swift build` because `swift run` can't find the directories for some reason.
