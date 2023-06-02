SDL_CreateThread
SDL_RWFromFP

//Windows
SDL_RegisterApp
SDL_UnregisterApp
SDL_Direct3D9GetAdapterIndex
SDL_RenderGetD3D9Device

//iPhone
SDL_iPhoneSetAnimationCallback
SDL_iPhoneSetEventPump

//Android
SDL_AndroidGetJNIEnv
SDL_AndroidGetActivity
SDL_AndroidGetInternalStoragePath
SDL_AndroidGetExternalStorageState
SDL_AndroidGetExternalStoragePath

//Asserts
SDL_DYNAPI_PROC(SDL_assert_state,SDL_ReportAssertion,(SDL_assert_data *a, const char *b, const char *c, int d),(a,b,c,d),return)
SDL_DYNAPI_PROC(void,SDL_SetAssertionHandler,(SDL_AssertionHandler a, void *b),(a,b),)
SDL_DYNAPI_PROC(const SDL_assert_data*,SDL_GetAssertionReport,(void),(),return)
SDL_DYNAPI_PROC(void,SDL_ResetAssertionReport,(void),(),)

//Atomics
SDL_AtomicTryLock
SDL_AtomicLock
SDL_AtomicUnlock
SDL_AtomicCAS
SDL_AtomicSet
SDL_AtomicGet
SDL_AtomicAdd
SDL_AtomicCASPtr
SDL_AtomicSetPtr
SDL_AtomicGetPtr

more to add
