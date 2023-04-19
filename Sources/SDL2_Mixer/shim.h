#ifdef __APPLE__
    #ifdef __i386__
        #include "/usr/local/include/SDL2/SDL_mixer.h"
    #elif defined __x86_64__
        #include "/usr/local/include/SDL2/SDL_mixer.h"
    #elif defined __aarch64__
        #include "/opt/homebrew/include/SDL2/SDL_mixer.h"
    #else
        #error "Unsupported architecture; Comment this out and if below works for you then please make a pull request."
        #include "/usr/local/include/SDL2/SDL_mixer.h"
    #endif
#else
    #include <SDL2/SDL_mixer.h>
#endif
