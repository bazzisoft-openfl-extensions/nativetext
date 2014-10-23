package nativetext;
import flash.display.Sprite;
import extensionkit.ExtensionKit;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end


class NativeText
{
    private static var s_initialized:Bool = false;

    public static function Initialize() : Void
    {
        if (s_initialized)
        {
            return;
        }

        s_initialized = true;
        ExtensionKit.Initialize();
        NativeTextField.Initialize();
    }	
}