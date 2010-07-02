package
{
	import flash.display.Bitmap;
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

		static private function rasterize(target:DisplayObject):BitmapData
		{
			const bounds:Rectangle = target.getBounds(target);
			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);

			var matrix:Matrix = new Matrix;
			matrix.translate(-bounds.left, -bounds.top);
			bitmapData.draw(target, matrix);
			return bitmapData;
		}

		static private const RASTERIZING:Boolean = true;
		static private var s_rasterizationStore:Dictionary = new Dictionary;

		static private var s_dropShadowFilter:Array = [new DropShadowFilter(4, 45, 0, 0.5)];
		static private function createAssetRasterized(clss:Class, centered:Boolean, dropShadow:Boolean):DisplayObject
		{
			var bmd:BitmapData = s_rasterizationStore[clss] as BitmapData;
			var retval:DisplayObject;
			if (!bmd)
			{
				retval = new clss();
				if (RASTERIZING)
				{
					bmd = rasterize(retval);
					s_rasterizationStore[clss] = bmd;
				}
			}

			if (bmd)
			{
				var bmp:DisplayObject = new Bitmap(bmd);
				if (centered)
				{
					bmp.x = -bmp.width/2;
					bmp.y = -bmp.height/2;
				}
				retval = new Sprite;
				if (dropShadow)
				{
					retval.filters = s_dropShadowFilter;
				}
				DisplayObjectContainer(retval).addChild(bmp);
			}
			return retval; // this will be either a bitmap, a bitmap centered on a sprite, or the source vector object 
		}
		[Embed(source="assets/master.swf", symbol="ship0")]
		static private const REDSHIP:Class;
		static public function createRedShip():DisplayObject
		{
			return createAssetRasterized(REDSHIP, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship1")]
		static private const BLUESHIP:Class;
		static public function createBlueShip():DisplayObject
		{
			return createAssetRasterized(BLUESHIP, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship2")]
		static private const ORANGESHIP:Class;
		static public function createOrangeShip():DisplayObject
		{
			return createAssetRasterized(ORANGESHIP, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship3")]
		static private const GREENSHIP:Class;
		static public function createGreenShip():DisplayObject
		{
			return createAssetRasterized(GREENSHIP, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship4")]
		static private const GRAYSHIP:Class;
		static public function createGrayShip():DisplayObject
		{
			return createAssetRasterized(GRAYSHIP, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship5")]
		static private const FUNNELSHIP:Class;
		static public function createFunnelShip():DisplayObject
		{
			return createAssetRasterized(FUNNELSHIP, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship6")]
		static private const BLUEBOSS:Class;
		static public function createBlueBossShip():DisplayObject
		{
			return createAssetRasterized(BLUEBOSS, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship7")]
		static private const FIGHTER:Class;
		static public function createFighterShip():DisplayObject
		{
			return createAssetRasterized(FIGHTER, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship8")]
		static private const SHIP8:Class;
		static public function createShip8():DisplayObject
		{
			return createAssetRasterized(SHIP8, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship9")]
		static private const SHIP9:Class;
		static public function createShip9():DisplayObject
		{
			return createAssetRasterized(SHIP9, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship10")]
		static private const SHIP10:Class;
		static public function createShip10():DisplayObject
		{
			return createAssetRasterized(SHIP10, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship11")]
		static private const SHIP11:Class;
		static public function createShip11():DisplayObject
		{
			return createAssetRasterized(SHIP11, true, true);
		}
		[Embed(source="assets/master.swf", symbol="ship12")]
		static private const SHIP12:Class;
		static public function createShip12():DisplayObject
		{
			return createAssetRasterized(SHIP12, true, true);
		}

		[Embed(source="assets/master.swf", symbol="hull1")]
		static private const HULL0:Class;
		static public function createHull0():DisplayObject
		{
			return createAssetRasterized(HULL0, false, false);
		}
		[Embed(source="assets/master.swf", symbol="turret0")]
		static private const TURRET0:Class;
		static public function createTurret0():DisplayObject
		{
			return createAssetRasterized(TURRET0, false, false);
		}

		[Embed(source="assets/master.swf", symbol="trackNonAnimated")]
		static private const TRACK:Class;
		static public function createTrack():MovieClip
		{
			var dummy:MovieClip = new MovieClip;
			dummy.addChild(new TRACK);
			return dummy;
		}

		static private const EXPLOSION_SIZE:Number = 2;
		static private const HALFSIZE:Number = EXPLOSION_SIZE/2;
		static public function createExplosionParticle():DisplayObject
		{
			var bmd:BitmapData = s_rasterizationStore[arguments.callee] as BitmapData;
			if (!bmd)
			{
				var particle:Shape = new Shape;
				particle.graphics.lineStyle(0, 0xffff00);
				particle.graphics.beginFill(0xffff00);
				particle.graphics.drawRect(-HALFSIZE, -HALFSIZE, EXPLOSION_SIZE, EXPLOSION_SIZE);
				particle.graphics.endFill();
				if (!RASTERIZING)
				{
					return particle;
				}
				
				bmd = rasterize(particle);
				s_rasterizationStore[arguments.callee] = bmd;
			}
			return new Bitmap(bmd);
		}
		public static function createBullet():DisplayObject
		{
			var bmd:BitmapData = s_rasterizationStore[arguments.callee] as BitmapData;
			if (!bmd)
			{
				var bullet:DisplayObject = createCircle(0xff7f00, 6, 6);
				if (!RASTERIZING)
				{
					return bullet;
				}
				bmd = rasterize(bullet);
				s_rasterizationStore[arguments.callee] = bmd;
			}
			return new Bitmap(bmd);
		}
		private static const LASER_LENGTH:Number = 10;
		public static function createLaser():DisplayObject
		{
			var bmd:BitmapData = s_rasterizationStore[arguments.callee] as BitmapData;
			if (!bmd)
			{
				var bullet:Shape = new Shape;
				bullet.graphics.lineStyle(3, 0xff0000);
				bullet.graphics.moveTo(0, -LASER_LENGTH/2);
				bullet.graphics.lineTo(0, LASER_LENGTH/2);
				if (!RASTERIZING)
				{
					return bullet;
				}
				bmd = rasterize(bullet);
				s_rasterizationStore[arguments.callee] = bmd;
			}
			return new Bitmap(bmd);
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