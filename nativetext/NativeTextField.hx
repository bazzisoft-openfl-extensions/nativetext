package nativetext;
import flash.display.Sprite;
import extensionkit.ExtensionKit;
import haxe.EnumTools;
import haxe.Json;
import openfl.events.EventDispatcher;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end


class NativeTextField extends EventDispatcher
{
    // Can use this for width/height in NativeTextFieldConfig
    public static inline var AUTOSIZE = -1.0;
    
    public var eventDispatcherId(default, null):Int = 0;
    
    public function new(?config:NativeTextFieldConfig)
    {
        super();
        this.eventDispatcherId = ExtensionKit.RegisterEventDispatcher(this);
        nativetext_create_text_field(this.eventDispatcherId, PrepareConfigForNativeCall(config));
    }
    
    private inline function EnsureNotDestroyed()
    {
        if (0 == this.eventDispatcherId)
        {
            throw "NativeTextField object has been destroyed.";
        }
    }
    
    public function Destroy()
    {
        EnsureNotDestroyed();
        
        #if (android || cpp)
        nativetext_destroy_text_field(this.eventDispatcherId);
        #end
        
        ExtensionKit.UnregisterEventDispatcher(this.eventDispatcherId);
        this.eventDispatcherId = 0;
    }
    
    public function Configure(config:NativeTextFieldConfig)
    {
        EnsureNotDestroyed();
        nativetext_configure_text_field(this.eventDispatcherId, PrepareConfigForNativeCall(config));
    }

    /**
     * Note: String will be UTF8 encoded. See haxe.Utf8 if using more than ASCII.
     */
    public function GetText() : String
    {
        EnsureNotDestroyed();
        
        #if (android || cpp)
        return nativetext_get_text(this.eventDispatcherId);
        #else
        return null;
        #end
    }
    
    /**
     * Note: String must be UTF8 encoded. See haxe.Utf8 if using more than ASCII.
     */
    public function SetText(text:String)
    {
        EnsureNotDestroyed();
        
        #if (android || cpp)
        nativetext_set_text(this.eventDispatcherId, text);
        #end
    }
    
    public function IsFocused() : Bool
    {
        #if (android || cpp)
        return nativetext_is_focused(this.eventDispatcherId);
        #else
        return false;
        #end
    }
    
    public function SetFocus()
    {
        ExtensionKit.stage.focus = null;
        
        #if (android || cpp)
        nativetext_set_focus(this.eventDispatcherId);
        #end
    }

    public function ClearFocus()
    {
        #if (android || cpp)
        nativetext_clear_focus(this.eventDispatcherId);
        #end
    }
    
    private function PrepareConfigForNativeCall(config:NativeTextFieldConfig) : Dynamic
    {
        #if android
        var jsonConfig = (null == config ? null : Json.stringify(config));	
        return jsonConfig;
        #elseif cpp
        var intConfig:Dynamic = Reflect.copy(config);
        intConfig.textAlignment = EnumToInt(config.textAlignment);
        intConfig.keyboardType = EnumToInt(config.keyboardType);
        intConfig.returnKeyType = EnumToInt(config.returnKeyType);        
        return intConfig;
        #end
		return {}
    }
    
    inline private function EnumToInt(e:EnumValue) : Null<Int>
    {
        return (null == e ? null : EnumValueTools.getIndex(e));
    }
    
    //---------------------------------
    // Native/JNI Functions
    //---------------------------------
    
    private static var nativetext_create_text_field = null;
    private static var nativetext_configure_text_field = null;
    private static var nativetext_destroy_text_field = null;
    private static var nativetext_get_text = null;
    private static var nativetext_set_text = null;
    private static var nativetext_is_focused = null;
    private static var nativetext_set_focus = null;
    private static var nativetext_clear_focus = null;

    @:allow(nativetext.NativeText)
    private static function Initialize() : Void
    {
        #if android
        nativetext_create_text_field = JNI.createStaticMethod("org.haxe.extension.nativetext.NativeText", "CreateTextField", "(ILjava/lang/String;)V");
        nativetext_configure_text_field = JNI.createStaticMethod("org.haxe.extension.nativetext.NativeText", "ConfigureTextField", "(ILjava/lang/String;)V");
        nativetext_destroy_text_field = JNI.createStaticMethod("org.haxe.extension.nativetext.NativeText", "DestroyTextField", "(I)V");
        nativetext_get_text = JNI.createStaticMethod("org.haxe.extension.nativetext.NativeText", "GetText", "(I)Ljava/lang/String;");
        nativetext_set_text = JNI.createStaticMethod("org.haxe.extension.nativetext.NativeText", "SetText", "(ILjava/lang/String;)V");
        nativetext_is_focused = JNI.createStaticMethod("org.haxe.extension.nativetext.NativeText", "IsFocused", "(I)Z");
        nativetext_set_focus = JNI.createStaticMethod("org.haxe.extension.nativetext.NativeText", "SetFocus", "(I)V");
        nativetext_clear_focus = JNI.createStaticMethod("org.haxe.extension.nativetext.NativeText", "ClearFocus", "(I)V");
        #elseif cpp
        nativetext_create_text_field = Lib.load("nativetext", "nativetext_create_text_field", 2);
        nativetext_configure_text_field = Lib.load("nativetext", "nativetext_configure_text_field", 2);
        nativetext_destroy_text_field = Lib.load("nativetext", "nativetext_destroy_text_field", 1);
        nativetext_get_text = Lib.load("nativetext", "nativetext_get_text", 1);
        nativetext_set_text = Lib.load("nativetext", "nativetext_set_text", 2);
        nativetext_is_focused = Lib.load("nativetext", "nativetext_is_focused", 1);
        nativetext_set_focus = Lib.load("nativetext", "nativetext_set_focus", 1);
        nativetext_clear_focus = Lib.load("nativetext", "nativetext_clear_focus", 1);
        #end
    }
}