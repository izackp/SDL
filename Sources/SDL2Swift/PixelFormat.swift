//
//  PixelFormat.swift
//  SDL
//
//  Created by Alsey Coleman Miller on 6/6/17.
//

import SDL2

/// SDL Pixel Format
public final class PixelFormat {
    
    // MARK: - Properties
    
    internal let internalPointer: UnsafeMutablePointer<SDL_PixelFormat>
    
    // MARK: - Initialization
    
    deinit {
        SDL_FreeFormat(internalPointer)
    }
    
    /// Creates a new Pixel Format.
    ///
    /// -Note: Returned structure may come from a shared global cache (i.e. not newly allocated), and hence should not be modified, especially the palette. Weird errors such as `Blit combination not supported` may occur.
    public init(format: PixelFormat.Format) throws {
        
        let internalFormat = SDL_AllocFormat(format.rawValue)
        self.internalPointer = try internalFormat.sdlThrow(type: type(of: self))
    }
    
    public init(format: UInt32) throws {
        
        let internalFormat = SDL_AllocFormat(format)
        self.internalPointer = try internalFormat.sdlThrow(type: type(of: self))
    }
    
    // MARK: - Accessors
    
    /// Pixel format
    public var format: PixelFormat.Format {
        
        return Format(rawValue: internalPointer.pointee.format)
    }
    
    // MARK: - Methods
    
    /// Set the palette for a pixel format structure
    public func setPalette(_ palette: Palette) throws {
        
        try SDL_SetPixelFormatPalette(internalPointer, palette.internalPointer).sdlThrow(type: type(of: self))
    }
}

// MARK: - Supporting Types

public extension PixelFormat {
    
    /// SDL Pixel Format Enum
    struct Format: RawRepresentable, Equatable, Hashable {
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            
            self.rawValue = rawValue
        }
        
        public func toPixelFormat() throws -> PixelFormat {
            return try PixelFormat(format: rawValue)
        }
    }
}

internal extension PixelFormat.Format {
    
    /// Get the human readable name of a pixel format
    var formatName: String {
        return String(cString: SDL_GetPixelFormatName(rawValue))
    }
}

public extension PixelFormat.Format {
    
    /// SDL_PIXELFORMAT_INDEX1LSB
    static let index1LSB = PixelFormat.Format(rawValue: UInt32(SDL_PIXELFORMAT_INDEX1LSB.rawValue))
    
    /// SDL_PIXELFORMAT_INDEX1MSB
    static let index1MSB = PixelFormat.Format(rawValue: UInt32(SDL_PIXELFORMAT_INDEX1MSB.rawValue))
    
    #if os(macOS)
    /// SDL_PIXELFORMAT_ARGB32
    static let argb32 = PixelFormat.Format(rawValue: UInt32(SDL_PIXELFORMAT_ARGB32.rawValue))
    #endif
    
    /// SDL_PIXELFORMAT_ARGB8888
    static let argb8888 = PixelFormat.Format(rawValue: UInt32(SDL_PIXELFORMAT_ARGB8888.rawValue))
}

// MARK: - ExpressibleByIntegerLiteral

extension PixelFormat.Format: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension PixelFormat.Format: CustomStringConvertible {
    
    /// Get the human readable name of a pixel format.
    public var description: String {
        
        let name = formatName
        return name.split(separator: "_").last.flatMap { String($0) } ?? name
    }
}

// MARK: - CustomStringDebugConvertible

extension PixelFormat.Format: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        return formatName
    }
}
