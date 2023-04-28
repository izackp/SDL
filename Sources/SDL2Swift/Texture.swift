//
//  Texture.swift
//  SDL
//
//  Created by Alsey Coleman Miller on 6/6/17.
//

import SDL2

/// SDL Texture
public final class Texture {
    
    public enum Access: Int32 {
        
        /// Changes rarely, not lockable.
        case `static`
        
        /// Changes frequently, lockable.
        case streaming
        
        /// Texture can be used as a render target
        case target
    }
    
    /// SDL Texture Attributes
    public struct Attributes {
        
        public let format: PixelFormat.Format
        
        public let access: Texture.Access
        
        public let width: Int
        
        public let height: Int
    }
    
    // MARK: - Properties
    
    internal let internalPointer: OpaquePointer
    
    // MARK: - Initialization
    
    deinit {
        SDL_DestroyTexture(internalPointer)
    }
    
    /// Create a texture for a rendering context.
    ///
    /// - Parameter renderer The renderer.
    /// - Parameter format: The format of the texture.
    /// - Parameter access: One of the enumerated values in `Texture.Access`.
    /// - Parameter width: The width of the texture in pixels.
    /// - Parameter height: The height of the texture in pixels.
    /// - Returns: The created texture is returned, or `nil` if no rendering context
    /// was active, the format was unsupported, or the width or height were out of range.
    public init(renderer: Renderer, format: PixelFormat.Format, access: Access, width: Int, height: Int) throws {
        
        let internalPointer = SDL_CreateTexture(renderer.internalPointer,
                                                      format.rawValue,
                                                      access.rawValue,
                                                      Int32(width),
                                                      Int32(height))
        
        self.internalPointer = try internalPointer.sdlThrow(type: type(of: self))
    }
    
    /// Create a texture from an existing surface.
    /// - Parameter renderer: The renderer.
    /// - Parameter surface: The surface containing pixel data used to fill the texture.
    /// - Returns: The created texture is returned, or `nil` on error.
    public init(renderer: Renderer, surface: Surface) throws {
        
        let internalPointer = SDL_CreateTextureFromSurface(renderer.internalPointer, surface.internalPointer)
        self.internalPointer = try internalPointer.sdlThrow(type: type(of: self))
    }
    
    // MARK: - Accessors
    
    public func attributes() throws -> Attributes {
        
        var format = UInt32()
        var access = Int32()
        var width = Int32()
        var height = Int32()
        
        try SDL_QueryTexture(internalPointer, &format, &access, &width, &height).sdlThrow(type: type(of: self))
        
        return Attributes(format: PixelFormat.Format(rawValue: format),
                          access: Texture.Access(rawValue: access)!,
                          width: Int(width),
                          height: Int(height))
    }
    
    /// The blend mode used for texture copy operations.
    public func blendMode() throws -> BitMaskOptionSet<BlendMode> {
        
        var value = SDL_BlendMode(0)
        try SDL_GetTextureBlendMode(internalPointer, &value).sdlThrow(type: type(of: self))
        return BitMaskOptionSet<BlendMode>(rawValue: UInt32(value.rawValue))
    }
    
    /// Set the blend mode used for texture copy operations.
    public func setBlendMode(_ newValue: BitMaskOptionSet<BlendMode>) throws {
        
        try SDL_SetTextureBlendMode(internalPointer, SDL_BlendMode(Int32(newValue.rawValue))).sdlThrow(type: type(of: self))
    }
    
    /**
     Get the additional alpha value used in render copy operations.
     
     - Note:
     When this texture is rendered, during the copy operation the source alpha value is modulated by this alpha value according to the following formula:
     
     `srcA = srcA * (alpha / 255)`
     
     Alpha modulation is not always supported by the renderer; it will return -1 if alpha modulation is not supported.
     */
    public func alphaModulation() throws -> UInt8 {
        
        var alpha: UInt8 = 0
        try SDL_GetTextureAlphaMod(internalPointer, &alpha).sdlThrow(type: type(of: self))
        return alpha
    }
    
    /**
     Set an additional alpha value used in render copy operations.
     
     - Parameter alpha: the source alpha value multiplied into copy operations.
     
     - Note:
     When this texture is rendered, during the copy operation the source alpha value is modulated by this alpha value according to the following formula:
     
     `srcA = srcA * (alpha / 255)`
     
     Alpha modulation is not always supported by the renderer; it will return -1 if alpha modulation is not supported.
     */
    public func setAlphaModulation(_ alpha: UInt8) throws {
        
        try SDL_SetTextureAlphaMod(internalPointer, alpha).sdlThrow(type: type(of: self))
    }
    
    public func setColorModulation(_ color: Color) throws {
        let format = try PixelFormat.init(format: .argb8888)
        let (r, g, b, _) = color.components(for: format)
        try SDL_SetTextureColorMod(internalPointer, r, g, b).sdlThrow(type: type(of: self))
    }
    
    public func setColorModulation(_ r: UInt8, _ g: UInt8, _ b: UInt8) throws {
        try SDL_SetTextureColorMod(internalPointer, r, g, b).sdlThrow(type: type(of: self))
    }

    
    // MARK: - Methods
     
    /// Update the given texture rectangle with new pixel data.
    /// - Parameters:
    ///     - rect: A pointer to the rectangle to lock for access.
    ///             If the rect is `nil`, the entire texture will be updated.
    ///     - body: The closure is called with the pixel pointer and pitch.
    ///     - pointer: The pixel pointer.
    ///     - pitch: The pitch.
    public func update(for rect: SDL_Rect? = nil, pixels: UnsafeRawBufferPointer, pitch: Int) throws {
        if let rect = rect {
            try withUnsafePointer(to: rect) { (idk:UnsafePointer<SDL_Rect>) in
                try SDL_UpdateTexture(internalPointer, idk, pixels.baseAddress, Int32(pitch)).sdlThrow(type: type(of: self))
            }
        } else {
            try SDL_UpdateTexture(internalPointer, nil, pixels.baseAddress, Int32(pitch)).sdlThrow(type: type(of: self))
        }
    }
    
    /// Lock a portion of the texture for write-only pixel access (only valid for streaming textures).
    /// - Parameters:
    ///     - rect: A pointer to the rectangle to lock for access.
    ///             If the rect is `nil`, the entire texture will be locked.
    ///             appropriately offset by the locked area.
    ///     - body: The closure is called with the pixel pointer and pitch.
    ///     - pointer: The pixel pointer.
    ///     - pitch: The pitch.
    public func withUnsafeMutableBytes<Result>(for rect: SDL_Rect? = nil, _ body: (_ pointer: UnsafeMutableRawPointer, _ pitch: Int) throws -> Result) throws -> Result? {
        
        let rectPointer: UnsafeMutablePointer<SDL_Rect>?
        if let rect = rect {
            rectPointer = UnsafeMutablePointer.allocate(capacity: 1)
            rectPointer?.pointee = rect
        } else {
            rectPointer = nil
        }
        
        defer { rectPointer?.deallocate() }
        
        var pitch: Int32 = 0
        var pixels: UnsafeMutableRawPointer? = nil
        
        /// must be SDL_TEXTUREACCESS_STREAMING or throws
        try SDL_LockTexture(internalPointer, rectPointer, &pixels, &pitch).sdlThrow(type: type(of: self))
        
        defer { SDL_UnlockTexture(internalPointer) }
        
        guard let pointer = pixels
            else { return nil }
        
        let result = try body(pointer, Int(pitch))
        
        return result
    }
    
    //NOTE: Must write into entire rect or risk uninitialized memory
    func lockAndEditSurface(rect: SDL_Rect? = nil, _ body: (Surface) throws ->()) throws {
        let rectPointer: UnsafeMutablePointer<SDL_Rect>?
        if let rect = rect {
            rectPointer = UnsafeMutablePointer.allocate(capacity: 1)
            rectPointer?.pointee = rect
        } else {
            rectPointer = nil
        }
        
        let surface = UnsafeMutablePointer<UnsafeMutablePointer<SDL_Surface>?>.allocate(capacity: 1)
        
        defer {
            rectPointer?.deallocate()
            surface.deallocate()
        }
        try SDL_LockTextureToSurface(internalPointer, rectPointer, surface).sdlThrow(type: type(of: self))
        if let finalSurfacePtr = surface.pointee {
            let wrapped = Surface(ptr: finalSurfacePtr, skipFree: true)
            try body(wrapped)
        }
        SDL_UnlockTexture(internalPointer)
    }
}
