#include <stdio.h>
#include "NativeText.h"
#include "../iphone/NativeTextIPhone.h"


namespace nativetext
{
    void Initialize()
    {
        #ifdef IPHONE
        iphone::InitializeIPhone();
        #endif
    }

    void CreateTextField(int eventDispatcherId)
    {
        #ifdef IPHONE
        iphone::CreateTextField(eventDispatcherId);
        #endif
    }
    
    void DestroyTextField(int eventDispatcherId)
    {
        #ifdef IPHONE
        iphone::DestroyTextField(eventDispatcherId);
        #endif		
    }
    
    void ConfigureTextField(int eventDispatcherId, const NativeTextFieldConfig& config)
    {
        #ifdef IPHONE
        iphone::ConfigureTextField(eventDispatcherId, config);
        #endif
    }
    
    const char* GetText(int eventDispatcherId)
    {
        #ifdef IPHONE
        return iphone::GetText(eventDispatcherId);
        #else
        return NULL;
        #endif
    }
    
    void SetText(int eventDispatcherId, const char* text)
    {
        #ifdef IPHONE
        iphone::SetText(eventDispatcherId, text);
        #endif
    }
    
    bool IsFocused(int eventDispatcherId)
    {
        #ifdef IPHONE
        return iphone::IsFocused(eventDispatcherId);
        #else
        return false;
        #endif
    }
    
    void SetFocus(int eventDispatcherId)
    {
        #ifdef IPHONE
        iphone::SetFocus(eventDispatcherId);
        #endif
    }

    void ClearFocus(int eventDispatcherId)
    {
        #ifdef IPHONE
        iphone::ClearFocus(eventDispatcherId);
        #endif
    }	
}
