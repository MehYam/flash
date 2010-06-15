package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class FlashLib
	{
		[Embed("c:/source/zomg/client/project_as3/mmo/Battle/src/com/gaiaonline/battle/newrings/iconAssets.swf",mimeType='application/octet-stream')]
		private static var embeddedClass:Class;

		private static var loader:Loader;
		private static var _eventDispatcher:EventDispatcher;
		private static var calledInit:Boolean = false;
		// unfortunately, this doesn't trigger until the class is accessed:
		FlashLib.init();
		
		public static function init():void {
			if (calledInit) { return; }
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT,handleLoaderInit);
			loader.loadBytes(new embeddedClass());
			_eventDispatcher = new EventDispatcher();
			calledInit = true;
		}
		
		private static function handleLoaderInit(p_evt:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.INIT,handleLoaderInit);
			_eventDispatcher.dispatchEvent(new Event(Event.INIT));
		}
		
		public static function get eventDispatcher():EventDispatcher {
			return _eventDispatcher;
		}
		
		public static function get inited():Boolean {
			return (loader.content != null);
		}

		private static var _bitmapDatas:Object = {};
		public static function getBitmap(name:String):Bitmap
		{
			if (!_bitmapDatas[name])
			{
				var BitmapDataSubClass:Class = getDefinition(name);
				_bitmapDatas[name] = new BitmapDataSubClass(0, 0);
			}
			return new Bitmap(BitmapData(_bitmapDatas[name]));
		}
		
		public static function getInstance(className:String):DisplayObject {
			var SymbolClass:Class = getDefinition(className);
			return (SymbolClass) ? new SymbolClass() : null;
		}
		
		public static function getDefinition(className:String):Class {
			return (inited) ? loader.contentLoaderInfo.applicationDomain.getDefinition(className) as Class : null;
		}
	}
}