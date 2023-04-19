//
//  DisplayMode.swift
//  SDL
//
//  Created by Alsey Coleman Miller on 10/19/18.
//

import SDL2

/// SDL Display Mode
public struct DisplayMode {
    
    @usableFromInline
    internal let internalValue: SDL_DisplayMode
    
    internal init(_ internalValue: SDL_DisplayMode) {
        
        self.internalValue = internalValue
    }
    
    public var format: PixelFormat.Format {
        return PixelFormat.Format(rawValue: internalValue.format)
    }
    
    /// Width, in screen coordinates
    public var width: Int {
        return Int(internalValue.w)
    }
    
    /// Height, in screen coordinates
    public var height: Int {
        return Int(internalValue.h)
    }
    
    /// Refresh rate (in Hz), or 0 for unspecified
    public var refreshRate: Int {
        return Int(internalValue.refresh_rate)
    }
    
    /// Access the underlying driver data.
    @inline(__always)
    public func withDriverData <Result> (_ body: (UnsafeMutableRawPointer?) throws -> Result) rethrows -> Result {
        
        return try body(internalValue.driverdata)
    }
}

public extension DisplayMode {
    
    /// Fill in information about a specific display mode.
    init(display: SDLVideoDisplay, index: DisplayMode.Index) throws {
        
        var internalValue = SDL_DisplayMode()
        try SDL_GetDisplayMode(Int32(display.rawValue), Int32(index.rawValue), &internalValue).sdlThrow(type: type(of: self))
        self.init(internalValue)
    }
}

public extension DisplayMode {
    
    struct Index: IndexRepresentable {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            
            self.rawValue = rawValue
        }
    }
}
