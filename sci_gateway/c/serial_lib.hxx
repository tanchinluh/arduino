#ifndef __SERIAL_LIB_GW_HXX__
#define __SERIAL_LIB_GW_HXX__

#ifdef _MSC_VER
#ifdef SERIAL_LIB_GW_EXPORTS
#define SERIAL_LIB_GW_IMPEXP __declspec(dllexport)
#else
#define SERIAL_LIB_GW_IMPEXP __declspec(dllimport)
#endif
#else
#define SERIAL_LIB_GW_IMPEXP
#endif

extern "C" SERIAL_LIB_GW_IMPEXP int serial_lib(wchar_t* _pwstFuncName);



#endif /* __SERIAL_LIB_GW_HXX__ */
