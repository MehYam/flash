package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import karnold.utils.Util;
	
	public final class SimpleActorAsset extends Sprite
	{
		public function SimpleActorAsset()
		{
			super();
			mouseEnabled = false;
		}

		static private var s_rasterizationStore:Dictionary = new Dictionary;
		static private function getRasterization(key:Object):BitmapData
		{
			return s_rasterizationStore[key] as BitmapData;
		}
		static private function rasterize(key:Object, target:DisplayObject):void
		{
			const bounds:Rectangle = target.getBounds(target);
			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);

			var matrix:Matrix = new Matrix;
			matrix.identity();
			matrix.translate(-bounds.left, -bounds.top);
//			bitmapData.draw(sprite, matrix, null);
		}

		static private var s_dropShadowFilter:Array = [new DropShadowFilter(4, 45, 0, 0.5)];
		static private function createShipHelper(clss:Class):DisplayObject
		{
			var retval:DisplayObject = new clss();
			retval.filters = s_dropShadowFilter;
			return retval;
		}
		[Embed(source="assets/master.swf", symbol="ship0")]
		static private const REDSHIP:Class;
		static public function createRedShip():DisplayObject
		{
			return createShipHelper(REDSHIP);
		}
		[Embed(source="assets/master.swf", symbol="ship1")]
		static private const BLUESHIP:Class;
		static public function createBlueShip():DisplayObject
		{
			return createShipHelper(BLUESHIP);
		}
		[Embed(source="assets/master.swf", symbol="ship2")]
		static private const ORANGESHIP:Class;
		static public function createOrangeShip():DisplayObject
		{
			return createShipHelper(ORANGESHIP);
		}
		[Embed(source="assets/master.swf", symbol="ship3")]
		static private const GREENSHIP:Class;
		static public function createGreenShip():DisplayObject
		{
			return createShipHelper(GREENSHIP);
		}
		[Embed(source="assets/master.swf", symbol="ship4")]
		static private const GRAYSHIP:Class;
		static public function createGrayShip():DisplayObject
		{
			return createShipHelper(GRAYSHIP);
		}
		[Embed(source="assets/master.swf", symbol="ship5")]
		static private const FUNNELSHIP:Class;
		static public function createFunnelShip():DisplayObject
		{
			return createShipHelper(FUNNELSHIP);
		}
		[Embed(source="assets/master.swf", symbol="ship6")]
		static private const BLUEBOSS:Class;
		static public function createBlueBossShip():DisplayObject
		{
			return createShipHelper(BLUEBOSS);
		}
		static private const EXPLOSION_SIZE:Number = 2;
		static private const HALFSIZE:Number = EXPLOSION_SIZE/2;
		static public function createExplosionParticle():DisplayObject
		{
			var particle:Shape = new Shape;
			particle.graphics.lineStyle(0, 0xffff00);
			particle.graphics.beginFill(0xffff00);
			particle.graphics.drawRect(-HALFSIZE, -HALFSIZE, EXPLOSION_SIZE, EXPLOSION_SIZE);
			particle.graphics.endFill();
			return particle;
		}
		public static function createSpiro(color:uint, width:Number, height:Number):DisplayObject
		{
			var wo:Shape = new Shape;
			
			wo.graphics.lineStyle(1, 0);
			wo.graphics.beginFill(color);
			wo.graphics.drawEllipse(width/4, 0, width/2, height);
			wo.graphics.drawEllipse(0, height/4, width, height/2);
			wo.graphics.endFill();
			
			drawOrigin(wo.graphics);
			return wo;
		}
		
		public static function createBullet():DisplayObject
		{
			return createCircle(0xff0000, 5, 5);			
		}
		public static function createCircle(color:uint, width:Number, height:Number):DisplayObject
		{
			var wo:Shape = new Shape;
			
			wo.graphics.lineStyle(0, color);
			wo.graphics.beginFill(color);
			wo.graphics.drawEllipse(-width/2, -height/2, width, height);
			wo.graphics.endFill();
			
			return wo;
		}
		
		public static function createSquare(color:uint, size:Number):DisplayObject
		{
			var wo:Shape = new Shape;
			
			wo.graphics.lineStyle(1, color);
			wo.graphics.drawRect(0, 0, size, size);
			
			drawOrigin(wo.graphics);
			return wo;
		}
		
		private static function drawOrigin(graphics:Graphics):void
		{
			graphics.lineStyle(1, 0x777777, 0.5);
			graphics.moveTo(0, 0);
			graphics.lineTo(5, 0);
			graphics.moveTo(0, 0);
			graphics.lineTo(0, 5);
		}
	}
}