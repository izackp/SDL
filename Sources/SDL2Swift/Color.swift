//
//  Color.swift
//  SDL
//
//  Created by Alsey Coleman Miller on 5/4/19.
//

import SDL2

/// SDL Color
public struct Color: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public extension Color {
    
    init(format: PixelFormat,
         red: UInt8,
         green: UInt8,
         blue: UInt8,
         alpha: UInt8 = .max) {
        
        self.rawValue = SDL_MapRGBA(format.internalPointer, red, green, blue, alpha)
    }
    
    func components(for format: PixelFormat) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        
        var components: (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) = (0, 0, 0, 0)
        SDL_GetRGBA(rawValue, format.internalPointer, &components.red, &components.green, &components.blue, &components.alpha)
        return components
    }
}
