package {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	[SWF(width="1068", height="555", frameRate="17", backgroundColor="#3a3a3a")]
	public class TestLoader extends Sprite
	{
		private var testCachingLoaders:Object = {};
		public function TestLoader()
		{
			var swfs:Array = 
			[
				"preloader.swf",
				"uiactionbar.swf",
				"uimanager.swf",
				"uimanager2.swf"
			];
			for (var i:int = 1; i <= 18; ++i)
			{
				swfs.push(i + ".swf");
			}
			
			var foo:int = 0;
			for each (var swf:String in swfs) 
			{ 
				var loader:Loader = new Loader(); 
				loader.load(new URLRequest( swf ) );

//				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);						
//				loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
//				loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
//				loader.contentLoaderInfo.addEventListener(Event.OPEN, onOpen);
//				loader.contentLoaderInfo.addEventListener(Event.UNLOAD, onUnload);
//				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
//									
//				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
//				loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, onIOError);
//				loader.contentLoaderInfo.addEventListener(IOErrorEvent.VERIFY_ERROR, onIOError);
//				loader.contentLoaderInfo.addEventListener(IOErrorEvent.DISK_ERROR, onIOError);

//				this.addChild(loader);
//				if (++foo % 2)
//				{
//					testCachingLoaders[swf] = loader.contentLoaderInfo;
//				}
//				testCachingLoaders[swf] = loader.contentLoaderInfo;
				testCachingLoaders[swf] = loader;
 			}
 			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
 			
 			this.graphics.lineStyle(3, 0xff0000);
 			this.graphics.beginFill(0x00ff00);
 			this.graphics.drawRect(0, 0, 300, 300);
 			this.graphics.endFill();
 			
 			
 			var mc:MovieClip = new MovieClip;
 			
 			mc.graphics.lineStyle(3, 0xff0000);
 			mc.graphics.beginFill(0x00ff00);
 			mc.graphics.drawRect(0, 0, 300, 300);
 			mc.graphics.endFill();
 			mc.y = 200;
 			mc.cacheAsBitmap = true;
 			
 			this.addChild(mc);
		}
		private function onClick(e:Event):void
		{
			for (var swf:String in testCachingLoaders)
			{
				testCachingLoaders[swf] = null;
				delete testCachingLoaders[swf];
			}

		}
		private function swfFromLoader(loaderInfo:LoaderInfo):String
		{
			for (var swf:String in testCachingLoaders)
			{
				if (testCachingLoaders[swf] == loaderInfo)
				{
					return swf;
				}
			}
			return null;
		}
		private function tr(str:String):void
		{
//			trace("test: " + str);
		}
		private function onInit(e:Event):void
		{
			tr("onInit");
		}
		private function onComplete(e:Event):void
		{
//			this.removeChild(LoaderInfo(e.target).loader);
			tr("onComplete");
			
			var swf:String = swfFromLoader(LoaderInfo(e.target));
			if (swf)
			{
//				setTimeout(function():void 
//					{
//						testCachingLoaders[swf] = null;
//						delete testCachingLoaders[swf];
//					}, 
//				0);

				testCachingLoaders[swf] = null;
				delete testCachingLoaders[swf];
			}
		}
		private function onHttpStatus(e:HTTPStatusEvent):void
		{
			tr("onHttpStatus");
		}
		private function onOpen(e:Event):void
		{
			tr("onOpen");
		}
		private function onUnload(e:Event):void
		{
			tr("onUnload");
		}
		private function onLoadProgress(e:ProgressEvent):void
		{
			if (e.bytesLoaded > 0)
			{
				tr("onLoadProgress - " + swfFromLoader(LoaderInfo(e.target)));
			}
		}
		private function onIOError(e:IOErrorEvent):void
		{
			tr("onIOError");
		}
	}
}
