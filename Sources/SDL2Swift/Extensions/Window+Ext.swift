//
//  Window+Ext.swift
//  TestGame
//
//  Created by Isaac Paul on 4/13/22.
//

public extension Window {
    func fpsHz() throws -> Int {
        let framesPerSecond = try displayMode().refreshRate
        return framesPerSecond
    }
}
