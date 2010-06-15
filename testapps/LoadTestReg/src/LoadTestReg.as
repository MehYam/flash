package {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.setTimeout;

	public class LoadTestReg extends Sprite
	{
		public function LoadTestReg()
		{
//			setTimeout(load, 1000);
			setTimeout(load2, 1000);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		private function load():void
		{
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest("c:/source/zomgc/mmo/guest/guestRegistration.swf"));

			addChild(loader);			
		}
		
		private function onComplete(e:Event):void
		{
			var guest:* = Sprite(LoaderInfo(e.target).content);
			
			var params:Object = 
			{ 
				avPath:"http://a2.cdn.gaiaonline.com/gaia/members/",
				mainServer:"www.gaiaonline.com",
				parentApp: "Battle",	// == zOMG
				loginPrompt: "false",
				gsiSubdomain: "test42.open.dev",
				relPath: "../../../zomgc/mmo/guest/",
				type: "registration"
			};

			guest.initialize(params);
			
			EventDispatcher(guest).addEventListener("CLOSE", onRegClose);
			EventDispatcher(guest).addEventListener("REGISTRATION_COMPLETE", onRegComplete);
		}
		
		private function onRegClose(e:Event):void
		{
			trace("closed");
		}
		
		private function onRegComplete(e:Event):void
		{
			trace("complete");
		} 


		private function load2():void
		{
			var loader:Loader = new Loader();
			
			var lc:LoaderContext = new LoaderContext();
//			lc.applicationDomain = 

			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete2);
			loader.load(new URLRequest("c:/source/zomgc/mmo/Battle/bin/RingPlayer.swf"));

			addChild(loader);			
		}
		
		private function onComplete2(e:Event):void
		{
		}
	}
}
