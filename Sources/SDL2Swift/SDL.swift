import SDL2

/// [Simple DirectMedia Layer](https://wiki.libsdl.org/)
///
public struct SDL {
    
    /**
    Use this function to initialize the SDL library.
    You should specify the subsystems which you will be using in your application

    SDL_Init() simply forwards to calling SDL_InitSubSystem(). Therefore, the two may be used interchangeably. Though for readability of your code SDL_InitSubSystem() might be preferred.
    
    The file I/O (for example: SDL_RWFromFile) and threading (SDL_CreateThread) subsystems are initialized by default. Message boxes (SDL_ShowSimpleMessageBox) also attempt to work without initializing the video subsystem, in hopes of being useful in showing an error dialog when SDL_Init fails. You must specifically initialize other subsystems if you use them in your application.

    Logging (such as SDL_Log) works without initialization, too.
     
    Subsystem initialization is ref-counted, you must call SDL_QuitSubSystem() for each SDL_InitSubSystem() to correctly shutdown a subsystem manually (or call SDL_Quit() to force shutdown). If a subsystem is already loaded then this call will increase the ref-count and return.
    
    - Parameter subSystems: Which subsystems to lnitialize.

    - Note: This must be called before using most other SDL functions.
    - Version: 2.0.0
    - SeeAlso: [Wiki Entry](https://wiki.libsdl.org/SDL2/SDL_Init)
    
    */
    public static func initialize(_ subSystems: BitMaskOptionSet<SubSystem>) throws {
        
        try SDL_Init(subSystems.rawValue).sdlThrow(type: type(of: self))
    }
    
    /// Compatibility function to initialize the SDL library.
    /// - Version: 2.0.0
    /// - SeeAlso: [Wiki Entry](https://wiki.libsdl.org/SDL2/SDL_InitSubSystem)
    public static func initSubSystem(_ subSystems: BitMaskOptionSet<SubSystem>) throws {
        
        try SDL_InitSubSystem(subSystems.rawValue).sdlThrow(type: type(of: self))
    }
    
    /// Get a mask of the specified subsystems which are currently initialized.
    /// - Version: 2.0.0
    /// - SeeAlso: [Wiki Entry](https://wiki.libsdl.org/SDL2/SDL_WasInit)
    public static func wasInit(_ subSystems: BitMaskOptionSet<SubSystem>) -> BitMaskOptionSet<SubSystem> {
        var value = SDL_WasInit(subSystems.rawValue)
        return BitMaskOptionSet(rawValue: value)
    }
    
    /**
    Cleans up all initialized subsystems.
    
    You should call this function even if you have already shutdown each initialized subsystem with SDL_QuitSubSystem(). It is safe to call this function even in the case of errors in initialization.

    You can use this function with atexit() to ensure that it is run when your application is shutdown, but it is not wise to do this from a library or other dynamically loaded code.
     
    - Version: 2.0.0
    - SeeAlso: [Wiki Entry](https://wiki.libsdl.org/SDL2/SDL_Quit)
    */
    @inline(__always)
    public static func quit() {
        SDL_Quit()
    }
    
    /**
    Cleans up specific SDL subsystems
    
    You still need to call SDL_Quit() even if you close all open subsystems with SDL_QuitSubSystem().
     
    - Version: 2.0.0
    - SeeAlso: [Wiki Entry](https://wiki.libsdl.org/SDL2/SDL_Quit)
    */
    public static func quit(subSystems: BitMaskOptionSet<SubSystem>) {
        
        return SDL_QuitSubSystem(subSystems.rawValue)
    }
    
    /**
    Circumvent failure of SDL_Init() when not using SDL_main() as an entry point.
     
    This function is defined in SDL_main.h, along with the preprocessor rule to redefine main() as SDL_main(). Thus to ensure that your main() function will not be changed it is necessary to define SDL_MAIN_HANDLED before including SDL.h.
     
    - Version: 2.0.0
    - SeeAlso: [Wiki Entry](https://wiki.libsdl.org/SDL2/SDL_SetMainReady)
    */
    public static func setMainReady() {
        SDL_SetMainReady()
    }
}

public extension SDL {
    
    /// Specific SDL subsystems.
    enum SubSystem: UInt32, BitMaskOption {
        
        case timer = 0x00000001
        case audio = 0x00000010
        /// automatically initializes the events subsystem
        case video = 0x00000020
        /// automatically initializes the events subsystem
        case joystick = 0x00000200
        case haptic = 0x00001000
        /// automatically initializes the joystick subsystem
        case gameController = 0x00002000
        case events = 0x00004000
        case sensor = 0x00008000
        /// includes all of the above subsystems
        case everything = 0x00000F231
    }
}
