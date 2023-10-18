//
//  Surface.swift
//  SDL
//
//  Created by Alsey Coleman Miller on 6/6/17.
//

import SDL2

extension SDL_Rect {
    func allocMutablePointer() -> UnsafeMutablePointer<SDL_Rect> {
        let result = UnsafeMutablePointer<SDL_Rect>.allocate(capacity: 1)
        result.pointee = self
        return result
    }
}

/// SDL Surface
public final class Surface {
    
    // MARK: - Properties
    
    internal let internalPointer: UnsafeMutablePointer<SDL_Surface>
    internal let _skipFree:Bool
    
    // MARK: - Initialization
    
    deinit {
        if (!_skipFree) {
            SDL_FreeSurface(internalPointer)
        }
    }
    
    /// Create an RGB surface.
    public init(rgb mask: (red: UInt, green: UInt, blue: UInt, alpha: UInt),
                size: (width: Int, height: Int),
                depth: Int = 32) throws {
        
        let internalPointer = SDL_CreateRGBSurface(0, CInt(size.width), CInt(size.height), CInt(depth), CUnsignedInt(mask.red), CUnsignedInt(mask.green), CUnsignedInt(mask.blue), CUnsignedInt(mask.alpha))
        
        self.internalPointer = try internalPointer.sdlThrow(type: type(of: self))
        _skipFree = false
    }
    
    // Get the SDL surface associated with the window.
    ///
    /// A new surface will be created with the optimal format for the window,
    /// if necessary. This surface will be freed when the window is destroyed.
    /// - Returns: The window's framebuffer surface, or `nil` on error.
    /// - Note: You may not combine this with 3D or the rendering API on this window.
    public init(window: Window) throws {
        
        let internalPointer = SDL_GetWindowSurface(window.internalPointer)
        self.internalPointer = try internalPointer.sdlThrow(type: type(of: self))
        _skipFree = false
    }
    
    public init(ptr: UnsafeMutablePointer<SDL_Surface>, skipFree:Bool = false) {
        self.internalPointer = ptr
        _skipFree = skipFree
    }
    
    public init(bmpDataPtr:UnsafeMutableRawBufferPointer) throws {
        let rwops = SDL_RWFromMem(bmpDataPtr.baseAddress, Int32(bmpDataPtr.count))
        let internalPointer = SDL_LoadBMP_RW(rwops, 0)
        self.internalPointer = try internalPointer.sdlThrow(type: type(of: self))
        _skipFree = false
    }
    
    public init(_ data:[UInt8], _ format:SDL_PixelFormat, _ width:Int, _ height:Int, skipFree:Bool = false) throws {
        let widthC = Int32(width)
        let heightC = Int32(height)
        let bpp = Int32(format.BitsPerPixel)
        let pitch = widthC*Int32(format.BytesPerPixel)
        var datacopy = data //TODO: fix to avoid copy
        let surfacePtr = datacopy.withUnsafeMutableBytes { (ptr:UnsafeMutableRawBufferPointer) in
            SDL_CreateRGBSurfaceWithFormatFrom(ptr.baseAddress, widthC, heightC, bpp, pitch, format.format)
            
        }
        self.internalPointer = try surfacePtr.sdlThrow(type: type(of: self))
        _skipFree = skipFree
    }
    
    // MARK: - Accessors
    
    public var width: Int {
        
        return Int(internalPointer.pointee.w)
    }
    
    public var height: Int {
        
        return Int(internalPointer.pointee.h)
    }
    
    public var pitch: Int {
        
        return Int(internalPointer.pointee.pitch)
    }
    
    internal var mustLock: Bool {
        
        // #define SDL_MUSTLOCK(S) (((S)->flags & SDL_RLEACCEL) != 0)
        @inline(__always)
        get { return internalPointer.pointee.flags & UInt32(SDL_RLEACCEL) != 0 }
    }
    
    // MARK: - Methods
    
    /// Get a pointer to the data of the surface, for direct inspection or modification.
    public func withUnsafeMutableBytes<Result>(_ body: (UnsafeMutableRawPointer) throws -> Result) throws -> Result? {
        
        let mustLock = self.mustLock
        
        if mustLock {
            
            try lock()
        }
        
        let result = try body(internalPointer.pointee.pixels)
        
        if mustLock {
            
            unlock()
        }
        
        return result
    }
    
    /// Sets up a surface for directly accessing the pixels.
    ///
    /// Between calls to `lock()` / `unlock()`, you can write to and read from `surface->pixels`,
    /// using the pixel format stored in `surface->format`.
    /// Once you are done accessing the surface, you should use `unlock()` to release it.
    /// Not all surfaces require locking.
    /// If `Surface.mustLock` is `false`, then you can read and write to the surface at any time,
    /// and the pixel format of the surface will not change.
    ///
    /// - Note: No operating system or library calls should be made between lock/unlock pairs,
    /// as critical system locks may be held during this time.
    internal func lock() throws {
        
        try SDL_LockSurface(internalPointer).sdlThrow(type: type(of: self))
    }
    
    internal func unlock() {
        
        SDL_UnlockSurface(internalPointer)
    }
    
    public func upperBlit(to surface: Surface, source: SDL_Rect? = nil, destination: SDL_Rect? = nil) throws {
        let dest = destination?.allocMutablePointer()
        defer {
            dest?.deallocate()
        }
        
        
        if let source = source {
            try withUnsafePointer(to: source) { (idk:UnsafePointer<SDL_Rect>) in
                let result = SDL_UpperBlit(internalPointer, idk, surface.internalPointer, dest)
                try result.sdlThrow(type: type(of: self))
            }
        } else {
            let result = SDL_UpperBlit(internalPointer, nil, surface.internalPointer, dest)
            try result.sdlThrow(type: type(of: self))
        }
        
    }
    
    public func fill(rect: SDL_Rect? = nil, color: Color) throws {
        if let rect = rect {
            try withUnsafePointer(to: rect) { (idk:UnsafePointer<SDL_Rect>) in
                try SDL_FillRect(internalPointer, idk, color.rawValue).sdlThrow(type: type(of: self))
            }
        } else {
            try SDL_FillRect(internalPointer, nil, color.rawValue).sdlThrow(type: type(of: self))
        }
    }
    
    public func drawPoint(_ x: Int, _ y:Int, _ color: UInt32) throws {
        let pitch = self.pitch
        let bpp = 4
        try withUnsafeMutableBytes { (ptr:UnsafeMutableRawPointer) in
            let targetPtr = ptr.advanced(by: y * pitch + x * bpp)
            targetPtr.storeBytes(of: color, as: UInt32.self)
        }
        
    }
    
    public func convertSurface(format: SDL_PixelFormatEnum) throws -> Surface {
        let newPtr = try SDL_ConvertSurfaceFormat(internalPointer, UInt32(format.rawValue), 0).sdlThrow(type: type(of: self))
        return Surface(ptr: newPtr)
    }
    /*
    public func blitChecked(_ src:Surface, _ srcRect:SDL_Rect? = nil, _ dstRect:SDL_Rect? = nil) throws {
        //TODO: Kinda ugly
        let result:Int32
        if let srcRect = srcRect, let dstRect = dstRect {
            var mutCopy = dstRect
            result = withUnsafePointer(to: srcRect) { (srcRectPtr:UnsafePointer<SDL_Rect>) in
                return withUnsafeMutablePointer(to: &mutCopy) { (dstRectPtr:UnsafeMutablePointer<SDL_Rect>) in
                    return SDL_UpperBlit(src.internalPointer, srcRectPtr, internalPointer, dstRectPtr)
                }
            }
        }
        else if let srcRect = srcRect {
            result = withUnsafePointer(to: srcRect) { (srcRectPtr:UnsafePointer<SDL_Rect>) in
                return SDL_UpperBlit(src.internalPointer, srcRectPtr, internalPointer, nil)
            }
        }
        else if let dstRect = dstRect {
            var mutCopy = dstRect
            result = withUnsafeMutablePointer(to: &mutCopy) { (dstRectPtr:UnsafeMutablePointer<SDL_Rect>) in
                return SDL_UpperBlit(src.internalPointer, nil, internalPointer, dstRectPtr)
            }
        } else {
            result = SDL_UpperBlit(src.internalPointer, nil, internalPointer, nil)
        }
        try result.sdlThrow(type: type(of: self))
    }*/
}
