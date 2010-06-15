package {
	import flash.display.Bitmap;
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
	import flash.text.TextFormat;

	public class TestSWFUnloading extends Sprite
	{
		private var _swfs:Array = 
		[
		];
		
		private var _tmd:TotalMemoryDisplay;
		public function TestSWFUnloading()
		{
			// UI
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

//			_swfs.push("village");
//			_swfs.push("simplefla");
			_swfs.push("LevelOne");
//			_swfs.push("ledge");

			addButton("Load Next SWF", onLoadNext);
			addButton("Load Next SWF into current domain", onLoadNextWithAppDomain);
			addButton("Cleanup", onCleanup);
//			addButton("dump display list", onDumpDisplayList);
			
			_tmd = new TotalMemoryDisplay;
			_tmd.x = 100;
			_tmd.y = _btnY;
			_tmd.autoUpdate = true;
			
			addChild(_tmd);
		}
		private function onCleanup(unused:Event):void
		{
removeChildAt(0);			
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
		
		private function loadNext(setAppDomain:Boolean):void
		{
			if (_swfs.length)
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);						

				var lc:LoaderContext;
				if (setAppDomain)
				{ 
					lc = new LoaderContext();
					lc.applicationDomain = flash.system.ApplicationDomain.currentDomain;
				}
				
				const swf:String = _swfs.shift(); 
				loader.load(new URLRequest( swf + ".swf"), lc);
				_swfs.push(swf);
			}
		}

private var _hangOnto:Object;
		private function onLoaded(e:Event):void
		{
			const loaderInfo:LoaderInfo = LoaderInfo(e.target); 
			loaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
			
			stopAnimation(loaderInfo.content);

			var cls:Class = Class(loaderInfo.applicationDomain.getDefinition("LevelOneDeleteme"));
//            var cls:Class = MovieClip(loaderInfo.content).getChildAt(0)['constructor'];

			var mc:MovieClip = new cls();
addChildAt(mc, 0);			

			var bmd:BitmapData = new BitmapData(mc.width, mc.height);
			bmd.draw(mc);

_hangOnto = bmd;

//			loaderInfo.loader.unloadAndStop();  Flash 10
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
			btn.autoSize = TextFieldAutoSize.CENTER;
			
			btn.x = 10;
			btn.y = _btnY;
			_btnY += 40;
			
			var parent:Sprite = new Sprite();
			parent.useHandCursor = true;
			parent.buttonMode = true;
			parent.mouseChildren = false;
			parent.addChild(btn);
			parent.addEventListener(MouseEvent.CLICK, listener);
			parent.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			parent.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);

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
	}
}
