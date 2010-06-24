package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import karnold.utils.Utils;

	public final class DebugVectorObject extends Sprite
	{
		public function DebugVectorObject()
		{
			super();
			mouseEnabled = false;
		}

//		[Embed(source="assets/spaceship1.svg")]
//		static private const SPACESHIP:Class;
//		static public function createSpaceship():DisplayObject
//		{
//			var sprite:Sprite = new SPACESHIP;
//			
//			var fudge:Sprite = new Sprite;
//			sprite.x = -sprite.width/2;
//			sprite.y = -sprite.height/2;
//			fudge.addChild(sprite);
//			return fudge;
//		}
		[Embed(source="assets/redship.swf")]
		static private const REDSHIP:Class;
		static public function createRedShip():DisplayObject
		{
			var retval:MovieClip = new REDSHIP;
			Utils.traceDisplayList(retval);
			Utils.listen(retval, Event.ENTER_FRAME, onFirstFrame);
			return retval;
		}
		[Embed(source="assets/blueship.swf")]
		static private const BLUESHIP:Class;
		static public function createBlueShip():DisplayObject
		{
			var retval:MovieClip = new BLUESHIP;
			Utils.traceDisplayList(retval);
			Utils.listen(retval, Event.ENTER_FRAME, onFirstFrame);
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
		public static function createSpiro(color:uint, width:Number, height:Number):DebugVectorObject
		{
			var wo:DebugVectorObject = new DebugVectorObject;
			
			wo.graphics.lineStyle(1, 0);
			wo.graphics.beginFill(color);
			wo.graphics.drawEllipse(width/4, 0, width/2, height);
			wo.graphics.drawEllipse(0, height/4, width, height/2);
			wo.graphics.endFill();
			
			drawOrigin(wo);
			return wo;
		}
		
		public static function createCircle(color:uint, width:Number, height:Number):DebugVectorObject
		{
			var wo:DebugVectorObject = new DebugVectorObject;
			
			wo.graphics.lineStyle(1, 0);
			wo.graphics.beginFill(color);
			wo.graphics.drawEllipse(0, 0, width, height);
			wo.graphics.endFill();
			
			return wo;
		}
		
		public static function createSquare(color:uint, size:Number):DebugVectorObject
		{
			var wo:DebugVectorObject = new DebugVectorObject;
			
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