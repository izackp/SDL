//
//  Audio.swift
//  
//
//  Created by Isaac Paul on 5/23/23.
//

//WIP

import SDL2

public struct AudioDriver {
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    public let id:Int
    public let name:String
}

public struct AudioSpec
{
    public init(freq: Int32, format: SDL_AudioFormat, channels: UInt8, samples: UInt16, callback: @escaping SDL_AudioCallback, userdata: Int) {
        self.freq = freq
        self.format = format
        self.channels = channels
        self.samples = samples
        self.callback = callback
        self.userdata = userdata
    }
    
    public let freq:Int32                 /**< DSP frequency -- samples per second */
    public let format:SDL_AudioFormat     /**< Audio data format */
    public let channels:UInt8             /**< Number of channels: 1 mono, 2 stereo */
    public let samples:UInt16             /**< Audio buffer size in sample FRAMES (total samples divided by channel count) */
    public let callback:SDL_AudioCallback /**< Callback that feeds the audio device (NULL to use SDL_QueueAudio()). */
    public let userdata:Int               /**< Userdata passed to callback (ignored for NULL callbacks). */
}

public struct ResultAudioSpec {
    internal init(spec: AudioSpec, silence: UInt8, size: UInt32) {
        self.spec = spec
        self.silence = silence
        self.size = size
    }
    
    public let spec:AudioSpec
    public let silence: UInt8 /**< Audio buffer silence value (calculated) */
    public let size: UInt32 /**< Audio buffer size in bytes (calculated) */
}

extension SDL_AudioSpec {
    static func from(_ spec:AudioSpec) -> SDL_AudioSpec {
        return SDL_AudioSpec(freq: spec.freq, format: spec.format, channels: spec.channels, silence: 0, samples: spec.samples, padding: 0, size: 0, callback: spec.callback, userdata: UnsafeMutableRawPointer(bitPattern: spec.userdata))
    }
    
    func getAudioSpec() -> AudioSpec {
        let resultUserData:Int
        if let userdata = userdata {
            resultUserData = Int(bitPattern: userdata)
        } else {
            resultUserData = 0
        }
        let audioSpec = AudioSpec(freq: freq, format: format, channels: channels, samples: samples, callback: callback, userdata: resultUserData)
        return audioSpec
    }
}

struct Audio {
    func getDrivers() -> [AudioDriver] {
        let count = getDriverCount()
        var list:[AudioDriver] = []
        for i in 0..<count {
            guard let name = getDriverName(i) else { continue }
            list.append(AudioDriver(id: i, name: name))
        }
        return list
    }
    
    func getDriverCount() -> Int {
        return Int(SDL_GetNumAudioDrivers())
    }
    
    func getDriverName(_ index:Int) -> String? {
        guard let name = SDL_GetAudioDriver(Int32(index)) else { return nil }
        let swiftStr = String(cString: name)
        return swiftStr
    }
    
    //Note: Will restart the particular driver if its already running
    func initialize(_ driverName:String? = nil) throws {
        let result:Int32
        if let driverName = driverName {
            result = driverName.withCString {
                return SDL_AudioInit($0)
            }
        } else {
            result = SDL_AudioInit(nil)
        }
        try result.sdlThrow(type: type(of: self))
    }
    
    func quit() {
        SDL_AudioQuit()
    }
    
    func getCurrentDriver() -> String? {
        guard let name = SDL_GetCurrentAudioDriver() else { return nil }
        let swiftStr = String(cString: name)
        return swiftStr
    }
    
    //Carried over from sdl 1.2 because its simplier
    func openAudio(_ desired:AudioSpec, forceSpec:Bool = false) throws -> ResultAudioSpec {
        var spec = SDL_AudioSpec.from(desired)
        let result:Int32
        let specToCheck:SDL_AudioSpec
        if (forceSpec) {
            result = SDL_OpenAudio(&spec, nil)
            specToCheck = spec
        } else {
            var obtained = SDL_AudioSpec()
            result = SDL_OpenAudio(&spec, &obtained)
            specToCheck = obtained
        }
        try result.sdlThrow(type: type(of: self))
        let swiftAudioSpec = specToCheck.getAudioSpec()
        
        return ResultAudioSpec(spec: swiftAudioSpec, silence: specToCheck.silence, size: specToCheck.size)
    }
    
    func getNumAudioDevices(_ iscapture:Int) throws -> Int {
        let num = SDL_GetNumAudioDevices(Int32(iscapture))
        //if num == -1 it means the audio driver is not initialized
        try num.sdlThrow(type: type(of: self), msg: "Audio driver is not initialized.")
        return Int(num)
    }
}
