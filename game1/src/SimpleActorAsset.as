package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import karnold.utils.Utils;

	public final class SimpleActorAsset extends Sprite
	{
		public function SimpleActorAsset()
		{
			super();
			mouseEnabled = false;
		}

		[Embed(source="assets/redship.swf")]
		static private const REDSHIP:Class;
		static public function createRedShip():DisplayObject
		{
			var retval:MovieClip = new REDSHIP;
			Utils.listen(retval, Event.ENTER_FRAME, onFirstFrame);
			return retval;
		}
		[Embed(source="assets/blueship.swf")]
		static private const BLUESHIP:Class;
		static public function createBlueShip():DisplayObject
		{
			var retval:MovieClip = new BLUESHIP;
			Utils.listen(retval, Event.ENTER_FRAME, onFirstFrame);
			return retval;
		}
		[Embed(source="assets/greenship.swf")]
		static private const GREENSHIP:Class;
		static public function createGreenShip():DisplayObject
		{
			var retval:MovieClip = new GREENSHIP;
			Utils.listen(retval, Event.ENTER_FRAME, onFirstFrame);
			return retval;
		}
		[Embed(source="assets/smallexplosion.swf")]
		static private const SMALLEXPLOSION:Class;
		static public function createSmallExplosion():DisplayObject
		{
			var retval:MovieClip = new SMALLEXPLOSION;
			return retval;
		}
		[Embed(source="assets/mediumexplosion.swf")]
		static private const MEDIUMEXPLOSION:Class;
		static public function createMediumExplosion():DisplayObject
		{
			var retval:MovieClip = new MEDIUMEXPLOSION;
			return retval;
		}
		static private function onFirstFrame(e:Event):void
		{
			var mc:MovieClip = MovieClip(e.target);
			if (mc.numChildren && mc.getChildAt(0) && DisplayObjectContainer(mc.getChildAt(0)).numChildren)
			{
				Utils.stopAllMovieClips(mc);
				mc.removeEventListener(e.type, arguments.callee);
			}
		}
		public static function createSpiro(color:uint, width:Number, height:Number):SimpleActorAsset
		{
			var wo:SimpleActorAsset = new SimpleActorAsset;
			
			wo.graphics.lineStyle(1, 0);
			wo.graphics.beginFill(color);
			wo.graphics.drawEllipse(width/4, 0, width/2, height);
			wo.graphics.drawEllipse(0, height/4, width, height/2);
			wo.graphics.endFill();
			
			drawOrigin(wo);
			return wo;
		}
		
		public static function createCircle(color:uint, width:Number, height:Number):SimpleActorAsset
		{
			var wo:SimpleActorAsset = new SimpleActorAsset;
			
			wo.graphics.lineStyle(1, 0);
			wo.graphics.beginFill(color);
			wo.graphics.drawEllipse(-width/2, -height/2, width, height);
			wo.graphics.endFill();
			
			return wo;
		}
		
		public static function createSquare(color:uint, size:Number):SimpleActorAsset
		{
			var wo:SimpleActorAsset = new SimpleActorAsset;
			
			wo.graphics.lineStyle(1, color);
			wo.graphics.drawRect(0, 0, size, size);
			
			drawOrigin(wo);
			return wo;
		}
		
		private static function drawOrigin(obj:Sprite):void
		{
			obj.graphics.lineStyle(1, 0x777777, 0.5);
			obj.graphics.moveTo(0, 0);
			obj.graphics.lineTo(5, 0);
			obj.graphics.moveTo(0, 0);
			obj.graphics.lineTo(0, 5);
		}
	}
}