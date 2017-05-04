package nativetext;

import haxe.Timer;
import haxe.Utf8;
import nativetext.NativeTextField;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Point;

/**
 * ...
 * @author davel
 */
class NativeTextDisplayObject extends Sprite
{

	private var laPosition:Bool = true;
	private var laVisiblity:Bool = true;
	
	private var natTf:NativeTextField;
	
	private var config:NativeTextFieldConfig = {};
	
	private var timer:Timer;
	
	@:isVar public var text(get, set):String;
	
	public function new() 
	{
		super();
		//graphics.beginFill(0, 0.6);
		//graphics.drawRect(0, 0, 200, 100);
		//graphics.endFill();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}
	
	public function setConfig(pConfig:NativeTextFieldConfig)
	{
		config = pConfig;
		if (natTf != null)
		{
			natTf.Configure(pConfig);
		}
	}
	
	public function getConfig():NativeTextFieldConfig
	{
		return config;
	}
	
	private function onRemovedFromStage(e:Event):Void 
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		natTf.Destroy();
	}
	
	private function onAddedToStage(e:Event):Void 
	{
		NativeText.Initialize();
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		natTf = new NativeTextField(config);
		natTf.Configure( { visible : false } );
		Timer.delay(function() { natTf.Configure( { visible : true } ); }, 49);
		timer = new Timer(25);
		timer.run = verif;
		//addEventListener(Event.ENTER_FRAME, verif);
		updatePosition();
	}
	
	public function verif()
	{
		if (natTf == null) return;
		if (stage == null) natTf.Destroy();
		
		var nConf:NativeTextFieldConfig = {};

		if (laVisiblity) 
		{
			var destAlpha:Float = 1;
			var parentTarget:DisplayObjectContainer = this;
			while (parentTarget.parent != stage) {
				destAlpha *= parentTarget.alpha;
				parentTarget = parentTarget.parent;
				if(parentTarget == null){
					natTf.Destroy();
					return;
				}
			}
			nConf.alpha = config.alpha = destAlpha;
			if(destAlpha == 0){
				nConf.visible = config.visible = false;
			}else{
				nConf.visible = config.visible = true;
			}
			natTf.Configure(nConf);
		}
		if (laPosition) {
			updatePosition();
		}
	}
	
	public function updatePosition() {
		var nConf:NativeTextFieldConfig = {};
		var pt:Point = localToGlobal(new Point(0, 0));
		nConf.x = pt.x; 
		nConf.y = pt.y;
		natTf.Configure(nConf);
	}
	
	public function lookAtPosition(value:Bool)
	{
		
		laPosition = value;
		
	}
		
	public function lookAtVisibility(value:Bool)
	{
		
		laVisiblity = value;
		
	}
	
	function get_text():String 
	{
		if (natTf != null) {
			text = natTf.GetText();
		}
		return text;
	}
	
	function set_text(value:String):String 
	{
		if (natTf != null){
			natTf.SetText(value);
		}
		return text = value;
	}
	
	
}