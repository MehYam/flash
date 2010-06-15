package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class test2 extends Sprite
	{
		private var _btnY:Number = 10;
		private function addButton(label:String, listener:Function):void
		{
			var btn:TextField = new TextField();
			btn.text = label;
			btn.selectable = false;
			
			btn.x = 10;
			btn.y = _btnY;
			_btnY += 20;
			btn.addEventListener(MouseEvent.CLICK, listener);
			addChild(btn);			
		}
		public function test2()
		{
			trace("version", Capabilities.version);

var foo:Array = Capabilities.version.split(" ")[1].split(",");

var ba:ByteArray = new ByteArray();

//ba.hasOwnProperty("foo");
			addButton("add instance", addInstance);
			addButton("remove all instances", removeAll);
			addButton("rasterize", rasterize);
			addButton("remove rasterizations", removeRasterizations);
			addButton("gc", gc);
			addButton("add instance set for timeout removal", addInstanceForTimeout);
		}
		
		private function addInstance(e:Event):void
		{
			var l:Loader = new Loader();

			l.contentLoaderInfo.addEventListener(Event.COMPLETE, onImgLoaded, false, 0, true);
			l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImgIoError, false, 0, true);
			l.contentLoaderInfo.addEventListener(IOErrorEvent.DISK_ERROR, onImgIoError, false, 0, true);
			l.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, onImgIoError, false, 0, true);

//			l.load(new URLRequest("C:\\source\\zomgc\\mmo\\Battle\\bin\\splashscreen\\village.jpg"));
			StepLoader.add(l, new URLRequest("C:\\source\\zomgc\\mmo\\Battle\\bin\\splashscreen\\village.jpg"));
		}

		private static var s_timeout:uint = 0;
		private static var s_pendingRemovees:Array = [];		
		private function addInstanceForTimeout(e:Event):void
		{
			s_pendingRemovees.push({hey: "yo"});
			s_timeout = setTimeout(removeInstanceForTimeout, 0);
		}
		
		private function removeInstanceForTimeout():void
		{
//			clearTimeout(s_timeout);
			while (s_pendingRemovees.length) {
				s_pendingRemovees.pop();
			}
		}

		private var dobj:DisplayObject;
		private function removeAll(e:Event):void
		{
			removeChild(dobj);
			dobj = null;
		}
		
		private function gc(e:Event):void
		{
			System.gc();
		}
		
		private var _lastX:Number = 30;
//		private var _bmd:BitmapData;
		private function rasterize(e:Event):void
		{
			var _bmd:BitmapData;
			if (!_bmd)
			{
				var obj:Sprite = new Sprite();
				obj.graphics.beginFill(0xff0000, 0.5);
				obj.graphics.lineStyle(3, 0xff);
				obj.graphics.drawCircle(10, 10, 20);
				
				_bmd = new BitmapData(obj.width, obj.height);
				_bmd.draw(obj);
			}
			
			var bmp:Bitmap = new Bitmap(_bmd);
			bmp.x = _lastX;
			
			_lastX += 30;
			bmp.y = 50;
			
			addChild(bmp);
			
			bmp = new Bitmap(_bmd);
			bmp.x = _lastX;
			
			_lastX += 30;
			bmp.y = 50;
			
			addChild(bmp);
			bmp = new Bitmap(_bmd);
			bmp.x = _lastX;
			
			_lastX += 30;
			bmp.y = 50;
			
			addChild(bmp);
		}

		private function removeRasterizations(e:Event):void
		{
			while (this.numChildren)
			{
				this.removeChildAt(this.numChildren - 1);
			}
		}

		private function onImgLoaded(e:Event):void
		{
			dobj = LoaderInfo(e.target).content;
			dobj.width = 20;
			dobj.height = 20;
			dobj.x = 100;
			dobj.y = 100; 
			this.addChild(dobj);
		}
		private function onImgIoError(e:Event):void
		{
			trace('error');
		}
		private function removeLoaderListeners(l:LoaderInfo):void
		{
			l.removeEventListener(Event.COMPLETE, onImgLoaded);
			l.removeEventListener(IOErrorEvent.IO_ERROR, onImgIoError);
			l.removeEventListener(IOErrorEvent.DISK_ERROR, onImgIoError);
			l.removeEventListener(IOErrorEvent.NETWORK_ERROR, onImgIoError);
			
		}
	}
}
