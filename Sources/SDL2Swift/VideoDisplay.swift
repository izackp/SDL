//
//  VideoDisplay.swift
//  SDL
//
//  Created by Alsey Coleman Miller on 10/19/18.
//

import SDL2

/// SDL Video Display
public struct SDLVideoDisplay: IndexRepresentable {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        
        self.rawValue = rawValue
    }
}

public extension SDLVideoDisplay {
    
    static var all: CountableSet<SDLVideoDisplay> {
        
        let count = Int(SDL_GetNumVideoDisplays())
        
        return CountableSet<SDLVideoDisplay>(count: count)
    }
    
}

public extension SDLVideoDisplay {
    
    /// Get the closest match to the requested display mode.
    ///
    /// The available display modes are scanned, and closest is filled in with the closest mode
    /// matching the requested mode and returned.
    func closestDisplayMode(width: Int, height: Int) -> DisplayMode? {
        
        // The mode format and refresh_rate default to the desktop mode if they are 0. The modes are scanned with size being first priority, format being second priority, and finally checking the refresh_rate. If all the available modes are too small, then NULL is returned.
        
        var target = SDL_DisplayMode()
        target.w = Int32(width)
        target.h = Int32(height)
        var closest = SDL_DisplayMode()
        guard SDL_GetClosestDisplayMode(Int32(rawValue), &target, &closest) != nil
            else { return nil }
        
        return DisplayMode(closest)
    }
    
    /// Get the availible display modes.
    func modes() throws -> [DisplayMode] {
        
        let count = SDL_GetNumDisplayModes(Int32(rawValue))
        
        // make sure value is valid
        try count.sdlThrow(type: type(of: self))

        let set = CountableSet<DisplayMode.Index>(count: Int(count))
        
        return try set.map { try DisplayMode(display: self, index: $0) }
    }
    
    func currentDisplayMode() throws -> DisplayMode {

        var current = SDL_DisplayMode()
        try SDL_GetCurrentDisplayMode(Int32(rawValue), &current).sdlThrow(type: type(of: self))
        return DisplayMode(current)
    }
}
