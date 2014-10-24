package nativetext.event;
import flash.events.Event;


class NativeTextEvent extends Event
{
    public static inline var CHANGE = "nativetext_change";
	public static inline var FOCUS_IN = "nativetext_focus_in";
	public static inline var FOCUS_OUT = "nativetext_focus_out";
    // Dispatched when the user pressed the keyboard's return key, eg. Done, Go, Search etc.
    public static inline var RETURN_KEY_PRESSED = "nativetext_return_key_pressed";

    public function new(type:String)
    {
        super(type, true, true);
    }

    public override function clone() : Event
    {
        return new NativeTextEvent(type);
    }

    public override function toString() : String
    {
        return "[NativeTextEvent type=" + type + "]";
    }
}