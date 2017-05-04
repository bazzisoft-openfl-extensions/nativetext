#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include <string.h>
#include "NativeText.h"
#include "NativeTextFieldConfig.h"


using namespace nativetext;


static bool _idsInitialized = false;
static int _id_x;
static int _id_y;
static int _id_width;
static int _id_height;
static int _id_visible;
static int _id_enabled;
static int _id_placeholder;
static int _id_fontAsset;
static int _id_fontSize;
static int _id_fontColor;
static int _id_placeholderColor;
static int _id_backgroundColor;
static int _id_textAlignment;
static int _id_keyboardType;
static int _id_returnKeyType;



static void InitIds()
{
    if (_idsInitialized)
    {
        return;
    }
    
    _idsInitialized = true;
    _id_x = val_id("x");
    _id_y = val_id("y");
    _id_width = val_id("width");
    _id_height = val_id("height");
    _id_visible = val_id("visible");
    _id_enabled = val_id("enabled");
    _id_placeholder = val_id("placeholder");
    _id_fontAsset = val_id("fontAsset");
    _id_fontSize = val_id("fontSize");
    _id_fontColor = val_id("fontColor");
    _id_placeholderColor = val_id("placeholderColor");
    _id_backgroundColor = val_id("fontColor");
    _id_textAlignment = val_id("textAlignment");
    _id_keyboardType = val_id("keyboardType");
    _id_returnKeyType = val_id("returnKeyType");    
}


static void DoConfigureTextField(int eventDispatcherId, value config)
{
    if (val_is_null(config))
    {
        return;
    }

    InitIds();
    
    value field;
    NativeTextFieldConfig textFieldConfig;
    
    field = val_field(config, _id_x); 		        textFieldConfig.x.Set(val_float(field), val_is_number(field));
    field = val_field(config, _id_y);   	        textFieldConfig.y.Set(val_float(field), val_is_number(field));
    field = val_field(config, _id_width);	        textFieldConfig.width.Set(val_float(field), val_is_number(field));
    field = val_field(config, _id_height);	        textFieldConfig.height.Set(val_float(field), val_is_number(field));
    field = val_field(config, _id_visible);         textFieldConfig.visible.Set(val_bool(field), val_is_bool(field));
    field = val_field(config, _id_enabled);         textFieldConfig.enabled.Set(val_bool(field), val_is_bool(field));
    field = val_field(config, _id_placeholder);     textFieldConfig.placeholder.Set(val_string(field), val_is_string(field));
    field = val_field(config, _id_fontAsset);       textFieldConfig.fontAsset.Set(val_string(field), val_is_string(field));
    field = val_field(config, _id_fontSize);        textFieldConfig.fontSize.Set(val_int(field), val_is_int(field));
    field = val_field(config, _id_fontColor);       textFieldConfig.fontColor.Set(val_int(field), val_is_int(field));
    field = val_field(config, _id_placeholderColor);textFieldConfig.placeholderColor.Set(val_int(field), val_is_int(field));
    field = val_field(config, _id_backgroundColor); textFieldConfig.backgroundColor.Set(val_int(field), val_is_int(field));
    field = val_field(config, _id_textAlignment);   textFieldConfig.textAlignment.Set((NativeTextFieldConfig::TextAlignment)val_int(field), val_is_int(field));
    field = val_field(config, _id_keyboardType);    textFieldConfig.keyboardType.Set((NativeTextFieldConfig::KeyboardType)val_int(field), val_is_int(field));
    field = val_field(config, _id_returnKeyType);   textFieldConfig.returnKeyType.Set((NativeTextFieldConfig::ReturnKeyType)val_int(field), val_is_int(field));

    ConfigureTextField(eventDispatcherId, textFieldConfig);
}


static void nativetext_create_text_field(value eventDispatcherId, value config)
{
    int id = val_int(eventDispatcherId);
    CreateTextField(id);
    DoConfigureTextField(id, config);
}
DEFINE_PRIM(nativetext_create_text_field, 2);


static void nativetext_destroy_text_field(value eventDispatcherId)
{
    DestroyTextField(val_int(eventDispatcherId));
}
DEFINE_PRIM(nativetext_destroy_text_field, 1);


static void nativetext_configure_text_field(value eventDispatcherId, value config)
{
    DoConfigureTextField(val_int(eventDispatcherId), config);
}
DEFINE_PRIM(nativetext_configure_text_field, 2);


static value nativetext_get_text(value eventDispatcherId)
{
    const char* text = GetText(val_int(eventDispatcherId));
    
    if (text != NULL)
    {
        return alloc_string_len(text, strlen(text));
    }
    else
    {
        return alloc_null();
    }
}
DEFINE_PRIM(nativetext_get_text, 1);


static void nativetext_set_text(value eventDispatcherId, value text)
{
    SetText(val_int(eventDispatcherId), val_string(text));
}
DEFINE_PRIM(nativetext_set_text, 2);


static value nativetext_is_focused(value eventDispatcherId)
{
    return alloc_bool(IsFocused(val_int(eventDispatcherId)));
}
DEFINE_PRIM(nativetext_is_focused, 1);


static void nativetext_set_focus(value eventDispatcherId)
{
    SetFocus(val_int(eventDispatcherId));
}
DEFINE_PRIM(nativetext_set_focus, 1);


static void nativetext_clear_focus(value eventDispatcherId)
{
    ClearFocus(val_int(eventDispatcherId));
}
DEFINE_PRIM(nativetext_clear_focus, 1);


extern "C" void nativetext_main()
{
    val_int(0); // Fix Neko init
}
DEFINE_ENTRY_POINT(nativetext_main);



extern "C" int nativetext_register_prims()
{
    Initialize();
    return 0;
}
