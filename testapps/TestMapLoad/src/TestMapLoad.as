package {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.setInterval;

	public class TestMapLoad extends Sprite
	{
		private const BIN_ROOT:String = "C:/source/zomgc/mmo/Battle/bin/maps/";
//		private const BIN_ROOT:String = "C:/source/zomgc/mmo/Battle/bin/ui/";
		private var _maps:Array = [];
		private var _tmd:TotalMemoryDisplay;

		public function TestMapLoad()
		{
			this.stage.frameRate = 17;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// Maps			
//            _maps.push("ad");             // slow to unload
//            _maps.push("barton");         // slow to unload
//            _maps.push("bassken");
//            _maps.push("beach");          // slow to unload
//            _maps.push("bf1");
//            _maps.push("bi");
//            _maps.push("bls");
//            _maps.push("boardwalk");
//            _maps.push("bst");
//            _maps.push("gbi");
//            _maps.push("hive");
//            _maps.push("ledge");         // slow
            _maps.push("m1");
//            _maps.push("nullchamber1");
//            _maps.push("otcliffs");
//            _maps.push("otruins");
//            _maps.push("sealab");         // slow
//            _maps.push("sewers");         // slow
//            _maps.push("shallow");
//            _maps.push("throne");
//            _maps.push("training");
//            _maps.push("trainstation");
//            _maps.push("village");
//            _maps.push("wd");
//            _maps.push("zengarden");
//            _maps.push("zgk");

// simulates the round-trip test
//			_maps.push("barton");         // slow to unload
//			_maps.push("village");
//			_maps.push("bf1");
//			_maps.push("zengarden");
//			_maps.push("bf1");
//			_maps.push("village");
//			_maps.push("barton");         // slow to unload

			// Rings
//			_maps.push("divinity");

			_maps.push("uimanager2");

			addButton("Load Next SWF", onLoadNext);
			addButton("Load Next SWF into current domain", onLoadNextWithAppDomain);
			addButton("Stop all stage animations", onStopAnimations);
			addButton("Cleanup", onCleanup);
			addTextField();
			
			_tmd = new TotalMemoryDisplay;
			_tmd.x = 100;
			_tmd.y = _btnY;
			_tmd.autoUpdate = true;
			
			addChild(_tmd);
		}
		
		private var _obj:DisplayObject;
		private function onCleanup(unused:Event):void
		{
			if (_obj) {
				_obj.parent.removeChild(_obj);
				_obj = null;
			}

			System.gc();
			_tmd.update();
		}
		private function onLoadNext(unused:Event):void
		{
			loadNext(false);
		}
		private function onLoadNextWithAppDomain(unused:Event):void
		{
			loadNext(true);
		}

		private var _store:AnimationStore;
		private function onLoaded(e:Event):void
		{
			var LI:LoaderInfo = LoaderInfo(e.target); 
			LI.removeEventListener(Event.COMPLETE, onLoaded);
			_store = new AnimationStore(LI.loader);

			_store.stopAll();

//			_store.report();
//			dumpDisplayList(LI.loader);
			
			var typeName:String = _typeToCreate.text;
			if (typeName.length) {
				var ctor:Class = LI.applicationDomain.getDefinition(typeName) as Class;
				
				_obj = new ctor();
				_obj.x = 200;
				_obj.y = _btnY + 100;
				addChild(_obj);
			}				
		}				

		private function onStopAnimations(e:Event):void
		{
			stopAnimation(stage);
		}

		private function loadNext(setAppDomain:Boolean):void
		{
			if (_maps.length)
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);						

				var lc:LoaderContext;
				if (setAppDomain)
				{ 
					lc = new LoaderContext();
					lc.applicationDomain = flash.system.ApplicationDomain.currentDomain;
				}
				
				const swf:String = _maps.shift(); 
				
				loader.load(new URLRequest( BIN_ROOT + swf + ".swf"), lc);
//				loader.load(new URLRequest( "C:/source/zomgc/mmo/Battle/bin/rings/" + swf + ".swf") );
				_maps.push(swf);
//				addChild(loader);
			}
		}

		private static function stopAnimation(obj:DisplayObject):void
		{
			//
			// Recursively search for animation frames
			var mc:MovieClip = obj as MovieClip;
			if (mc && mc.totalFrames > 1)
			{
				mc.stop();
			}
			
			var container:DisplayObjectContainer = obj as DisplayObjectContainer;
			if (container && container.numChildren)
			{
				for (var i:int = 0; i < container.numChildren; ++i)
				{
					stopAnimation(container.getChildAt(i));
				}
			}
		}
		private var _btnY:Number = 10;
		private static var _fmt:TextFormat;
		private function addButton(label:String, listener:Function):void
		{
			if (!_fmt)
			{
				_fmt = new TextFormat("Arial", 20, 0xff);
			}
			var btn:TextField = new TextField();
			btn.text = label;
			btn.selectable = false;
			btn.background = true;
			btn.border = true;
			btn.backgroundColor = 0xffffff;
			btn.setTextFormat(_fmt);
			btn.autoSize = TextFieldAutoSize.LEFT;

			var parent:Sprite = new Sprite();
			parent.useHandCursor = true;
			parent.buttonMode = true;
			parent.mouseChildren = false;
			parent.addChild(btn);
			parent.addEventListener(MouseEvent.CLICK, listener);
			parent.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			parent.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);

			parent.x = 10;
			parent.y = _btnY;
			_btnY += 40;

			addChild(parent);			
		}
		private function onButtonOver(e:MouseEvent):void
		{
			TextField(Sprite(e.currentTarget).getChildAt(0)).backgroundColor = 0xBCC8FF;
		}
		private function onButtonOut(e:MouseEvent):void
		{
			TextField(Sprite(e.currentTarget).getChildAt(0)).backgroundColor = 0xffffff;
		}
		private var _typeToCreate:TextField;
		private function addTextField():void
		{
			_typeToCreate = new TextField();
			_typeToCreate.type = TextFieldType.INPUT;
			_typeToCreate.border = true;
			_typeToCreate.defaultTextFormat = _fmt;
			_typeToCreate.x = 10;
			_typeToCreate.y = _btnY;
			_btnY += 40;

			_typeToCreate.autoSize = TextFieldAutoSize.LEFT;
			var savedHeight:Number = _typeToCreate.height;
			_typeToCreate.autoSize = TextFieldAutoSize.NONE;
			_typeToCreate.width = 200;
			_typeToCreate.height = savedHeight;

			_typeToCreate.text = "m01_windy_01";
//			_typeToCreate.text = "windyController";
//			_typeToCreate.text = "leavesAnimator";
			
			addChild(_typeToCreate);
		}


		private static function tr(str:String, level:int):void {
			
			var out:String = "";
			for (var i:int = 0; i < level; ++i)
			{
				out += " ";
			}
			trace(out + str);
		}

		private static var _nthObject:int = 0;
		private static function dumpDisplayList(obj:DisplayObject, level:int = 0):void {

			if (level == 0) {
				_nthObject = 0;
			}
			++_nthObject;

			const type:String = (String(obj)).replace("]", "").replace("[object ", "").replace(" ", "");
			var tag:String = "<" + type;
			
			if (obj.name && obj.name.length && obj.name.search("instance") != 0)
			{
				tag += " name='" + obj.name + "'";
			}

			var mc:MovieClip = obj as MovieClip;
			if (mc && mc.totalFrames > 1) {
				tag += " totalFrames='" + mc.totalFrames + "'";
			}

//			tag += " nth='" + _nthObject + "'";

			var objAsParent:DisplayObjectContainer = obj as DisplayObjectContainer;
			const numChildren:int = objAsParent ? objAsParent.numChildren : 0;
			if (numChildren)
			{
				tag += ">";
				tr(tag, level);

				for (var i:int; i < numChildren; ++i)
				{
					var child:DisplayObject = objAsParent.getChildAt(i);
					dumpDisplayList(child, level+1);
				}
				tr("</" + type + ">", level);
			}
			else
			{
				tag += "/>";
				tr(tag, level);
			}
		}
	}
}
