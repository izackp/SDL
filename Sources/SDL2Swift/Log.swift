//
//  Log.swift
//  
//
//  Created by Isaac Paul on 5/23/23.
//

import SDL2

public struct Log {
    /// Set the priority of all log categories.
    public static func setAllPriority(_ priority:SDL_LogPriority) {
        SDL_LogSetAllPriority(priority)
    }
    
    /// Set the priority of a particular log category.
    public static func setPriority(_ category:SDL_LogCategory, _ priority:SDL_LogPriority) {
        SDL_LogSetPriority(Int32(category.rawValue), priority)
    }
    
    /// Get the priority of a particular log category.
    public static func getPriority(_ category:SDL_LogCategory) -> SDL_LogPriority {
        return SDL_LogGetPriority(Int32(category.rawValue))
    }
    
    public static func resetPriorities() {
        SDL_LogResetPriorities()
    }
    
    public static func log(_ msg:String) {
        message(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_VERBOSE, msg)
    }
    
    public static func verbose(_ cat:SDL_LogCategory, _ msg:String) {
        message(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_VERBOSE, msg)
    }
    
    public static func debug(_ cat:SDL_LogCategory, _ msg:String) {
        message(cat, SDL_LOG_PRIORITY_DEBUG, msg)
    }
    
    public static func info(_ cat:SDL_LogCategory, _ msg:String) {
        message(cat, SDL_LOG_PRIORITY_INFO, msg)
    }
    
    public static func warn(_ cat:SDL_LogCategory, _ msg:String) {
        message(cat, SDL_LOG_PRIORITY_WARN, msg)
    }
    
    public static func error(_ cat:SDL_LogCategory, _ msg:String) {
        message(cat, SDL_LOG_PRIORITY_ERROR, msg)
    }
    
    public static func critical(_ cat:SDL_LogCategory, _ msg:String) {
        message(cat, SDL_LOG_PRIORITY_CRITICAL, msg)
    }
    
    public static func message(_ cat:SDL_LogCategory, _ priority:SDL_LogPriority, _ fmt:String, _ args: CVarArg...) {
        fmt.withCString { (fmt:UnsafePointer<Int8>) in
            withVaList(args) {
                SDL_LogMessageV(Int32(cat.rawValue), priority, fmt, $0)
            }
        }
    }
    
    /// Get the current log output function.
    public static func getOutputFunction() -> (SDL_LogOutputFunction, UnsafeMutableRawPointer?)? {
        var outputPointer = UnsafeMutablePointer<SDL_LogOutputFunction?>(bitPattern: 0)
        var userDataPointer = UnsafeMutablePointer<UnsafeMutableRawPointer?>(bitPattern: 0)
        SDL_LogGetOutputFunction(outputPointer, userDataPointer)
        
        guard let outputPointer = outputPointer else { return nil }
        if (Int(bitPattern: outputPointer) == 0) {
            return nil
        }
        guard let outputFunc = outputPointer.pointee else { return nil }
        
        let userData:UnsafeMutableRawPointer?
        if (Int(bitPattern: userDataPointer) == 0) {
            userData = nil
        } else {
            userData = userDataPointer?.pointee
        }
        return (outputFunc, userData)
    }
    
    /// Replace the default log output function with one of your own.
    public static func setOutputFunction(_ callback: SDL_LogOutputFunction, userData: UnsafeMutableRawPointer?) {
        SDL_LogSetOutputFunction(callback, userData)
    }
}


/* cant use var args without valist
 func setError() {
     
 }

func sscanf() {
    
}

func snprintf() {
    
}
*/
