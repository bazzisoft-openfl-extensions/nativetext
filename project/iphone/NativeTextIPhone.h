#ifndef NATIVETEXTIPHONE_H
#define NATIVETEXTIPHONE_H

#include "NativeTextFieldConfig.h"


namespace nativetext
{
    namespace iphone
    {
        void InitializeIPhone();
        void CreateTextField(int eventDispatcherId);
        void DestroyTextField(int eventDispatcherId);
        void ConfigureTextField(int eventDispatcherId, const NativeTextFieldConfig& config);
        const char* GetText(int eventDispatcherId);
        void SetText(int eventDispatcherId, const char* text);
        bool IsFocused(int eventDispatcherId);
        void SetFocus(int eventDispatcherId);
        void ClearFocus(int eventDispatcherId);		
    }
}


#endif