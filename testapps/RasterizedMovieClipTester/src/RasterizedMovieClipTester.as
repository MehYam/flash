package {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.getTimer;

	public class RasterizedMovieClipTester extends Sprite
	{
		static private const TEST_FLA:String = "SampleAsset.swf";
		static private const TEST_ASSET:String = "Asset1";
		public function RasterizedMovieClipTester()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			loader.load(new URLRequest(TEST_FLA));
			
			var _tmd:TotalMemoryDisplay = new TotalMemoryDisplay;
			_tmd.x = 100;
			_tmd.y = 0;
			_tmd.autoUpdate = true;
			addChild(_tmd);			
		}
		
		private static const OBJ_SIZE:uint = 100;
//private var _mc:MovieClip;
		private function onLoaded(e:Event):void
		{
			const loaderInfo:LoaderInfo = LoaderInfo(e.target);
			loaderInfo.removeEventListener(Event.COMPLETE, onLoaded);

			const type:Class = Class(loaderInfo.applicationDomain.getDefinition("TestStopper"));
		
			var obj:MovieClip = new type();
			addChild(obj);
			
			obj.x = 100;
			obj.y = 100;
			obj.addEventListener(Event.ENTER_FRAME, onTestStopperEnterFrame);
//_mc = obj;

//			obj = new type();
//			addChild(obj);
				
return;			
			////////////////////////////////////////////
			/*
			const loaderInfo:LoaderInfo = LoaderInfo(e.target);
			loaderInfo.removeEventListener(Event.COMPLETE, onLoaded);

			const type:Class = Class(loaderInfo.applicationDomain.getDefinition(TEST_ASSET));

			//
			// Create one
			var parent:MovieClip = new MovieClip();
			var instance:MovieClip = new type();
				
			parent.x = OBJ_SIZE;
			parent.y = OBJ_SIZE;
			instance.width = OBJ_SIZE;
			instance.height = OBJ_SIZE;
			parent.addChild(instance);
			addChild(parent);

			//
			// Rasterize another one
			var rmc:RasterizedMovieClip = new RasterizedMovieClip(type, 50, 50);
			rmc.y = 300;
			addChild(rmc);
			*/
		}
		
		private var _doOnce:Boolean = false;
		private function closureMinimizer(mc:MovieClip):Function
		{
			return function():void { mc.stop(); } 
		}
		
		private var _stoppedTime:int = 0;
		private function onTestStopperEnterFrame(e:Event):void
		{
			var mc:MovieClip = e.target as MovieClip;
			trace("frame:", mc.currentFrame);

			if (!_doOnce && mc.currentFrame == 4)
			{
				_doOnce = true;

				new MovieClipFrameStopper(mc, 1);

				_stoppedTime = getTimer();
			}

			if (_doOnce && (getTimer() > (_stoppedTime + 3000)))
			{
				if (mc["mcffStopped"] == true)
				{
					mc["frame" + mc.currentFrame]();
					mc["mcffStopped"] = false;
					mc.play();
				}
			}
		}
		
		private function getFrameFunction(mc:MovieClip):Function
		{
			var code:Function = mc["frame3"];
			return code;
		}
	}
}
