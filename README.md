NativeText
=============

### Use native iOS/Android text fields in OpenFL

- Native text fields are displayed as overlays over the OpenGL surface. (Absolutely positioned for now, as they're not part of the OpenFL display list.)

- Full support for multilingual text display & entry with UTF8. Use the `haxe.Utf8` class to manipulate returned text strings in Haxe.

- Cross-platform support for different keyboard types (eg. text, numbers, phones, email, etc).

- Cross-platform support for different keyboard return buttons (eg. Next, Done, Search) dispatching an event when pressed. "Next" also moves to the next visible text field automatically. 


Todo
----
- Wrap in a custom HaxeUI component for use in auto layout.

- Ensure pixel-perfect position & size across all iOS/Android devices.

- Save a copy of currently active `NativeTextFieldConfig` in the `NativeTextField` haxe class so current configuration can be retrieved.

- Support for multi-line text fields. iOS requires a different text field class here in native code. 

- Ability to use fonts from OpenFL assets.

- For non-mobile targets, simulate behaviour with regular OpenFL textfields absolutely positioned on the stage. (Include a static placeholder textfield as well.)

- Allow setting a "fake" parent `DisplayObjectContainer` in the `NativeTextField` class which we can use to calculate relative `x` and `y` coordinates for the native textfield. (Also handle resize events automatically?  `scaleX` / `scaleY` from parent hierarchy?)

- iOS `AUTOSIZE` mode should resize as text is entered like Android.

- Easy way to auto-scroll the textfield into view on iOS when keyboard pops up.


Dependencies
------------

- This extension implicitly includes `extensionkit` which must be available in a folder
  beside this one.


Installation
------------

    git clone https://github.com/bazzisoft-openfl-extensions/extensionkit
    git clone https://github.com/bazzisoft-openfl-extensions/nativetext
    lime rebuild extensionkit [linux|windows|mac|android|ios]
    lime rebuild nativetext [linux|windows|mac|android|ios]


Usage
-----

### project.xml

    <include path="/path/to/nativetext" />


### Haxe

    class Main extends Sprite
    {
    	public function new()
        {
    		super();

            NativeText.Initialize();

			// Any of these fields may be left out for no change
			var config:NativeTextFieldConfig = {
				x: 30,
				y: 110,
				width: 580,
				height: NativeTextField.AUTOSIZE,
				visible: true,
				enabled: false,
				placeholder: "Email Address",
				fontAsset: "assets/font/OpenSans-Regular.ttf",		// TODO: No effect yet
				fontSize: 36,
				fontColor: 0xFF0000,
				textAlignment: NativeTextFieldAlignment.Center,
				keyboardType: NativeTextFieldKeyboardType.Email,
				returnKeyType: NativeTextFieldReturnKeyType.Go,
			};
	
            var textField = new NativeTextField(config);

            textField.addEventListener(Event.CHANGE, function(e) { trace(e); });
			textField.addEventListener(FocusEvent.FOCUS_IN, function(e) { trace(e); });
			textField.addEventListener(FocusEvent.FOCUS_OUT, function(e) { trace(e); });
			textField.addEventListener(NativeTextEvent.RETURN_KEY_PRESSED, function(e) { trace(e); });

			textField.SetText("Hello There");
			textField.Configure({ enabled: true });
			textField.SetFocus();

			...
			
			textField.ClearFocus();
			trace(textField.GetFocus());
			trace(textField.GetText());
			textField.Destroy();
        }
    }
