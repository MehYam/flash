package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import karnold.utils.Util;
	
	public final class ActorAssetManager
	{
		static public function rasterize(target:DisplayObject, scale:Number = 1, filterExtra:Number = 0):BitmapData
		{
			const bounds:Rectangle = target.getBounds(target);
			bounds.inflate(filterExtra, filterExtra);
			var bitmapData:BitmapData = new BitmapData(bounds.width * scale, bounds.height * scale, true, 0);

			var matrix:Matrix = new Matrix;
			matrix.translate(-bounds.left, -bounds.top);
			matrix.scale(scale, scale);
			bitmapData.draw(target, matrix);
			
			perlinizeIt(bitmapData);
			return bitmapData;
		}

		static private var s_perlinTemplate:BitmapData;
		static private var s_perlinWorkspace:BitmapData;
		static private var s_perlinRect:Rectangle;
		static private function perlinizeIt(bmd:BitmapData):void
		{
			if (!s_perlinTemplate)
			{
				s_perlinRect = new Rectangle(0, 0, 200, 200);
				s_perlinTemplate = new BitmapData( s_perlinRect.width, s_perlinRect.height );
				s_perlinTemplate.perlinNoise( 165, 125, 4, 93, true, true, 0x7, false);
				
				s_perlinWorkspace = new BitmapData( s_perlinTemplate.width, s_perlinTemplate.height);
			}
			s_perlinWorkspace.copyPixels(s_perlinTemplate, s_perlinRect, new Point(0, 0)); 
			s_perlinWorkspace.copyChannel(bmd,
				new Rectangle(0, 0, bmd.width, bmd.height),
				new Point(0, 0),
				BitmapDataChannel.ALPHA,
				BitmapDataChannel.ALPHA);
			bmd.draw(s_perlinWorkspace, null, null, BlendMode.OVERLAY);
		}
		
		static public const RASTERIZING:Boolean = true;
		static private var s_rasterizationStore:Dictionary = new Dictionary;

		static private var s_dropShadow:Array = [new DropShadowFilter(4, 45, 0, 0.5, 0, 0)];
		static private var s_dropShadowTank:Array = [new DropShadowFilter(2, 45, 0, 0.5, 0, 0)];
		static private var s_blur:Array = [new BlurFilter(5, 5, BitmapFilterQuality.MEDIUM)];
		static private var s_blurHeavy:Array = [new BlurFilter(25, 25, BitmapFilterQuality.LOW)];
		static public function get planeDropShadow():Array { return s_dropShadow; }
		static public function get tankDropShadow():Array { return s_dropShadowTank; }
		static private function createAssetRasterized(clss:Class, 
													  centered:Boolean,
													  scale:Number = 1,
													  preFilter:Array = null,
													  postFilter:Array = null):DisplayObject
		{
			var bmd:BitmapData = s_rasterizationStore[clss] as BitmapData;
			var retval:DisplayObject;
			if (!bmd)
			{
				retval = new clss();
				retval.scaleX = scale;
				retval.scaleY = scale;
				if (preFilter)
				{
					if (retval.filters.length) throw "filter";
					retval.filters = preFilter;
				}
				if (RASTERIZING)
				{
					var filterExtra:Number = 0;
					var blur:BlurFilter = retval.filters.length ? (retval.filters[0] as BlurFilter) : null;
					if (blur)
					{
						filterExtra = Math.max(blur.blurX, blur.blurY) / 2;
					}
					bmd = rasterize(retval, scale, filterExtra);
					s_rasterizationStore[clss] = bmd;
				}
			}

			if (bmd)
			{
				var bmp:DisplayObject = new Bitmap(bmd);
				Bitmap(bmp).smoothing = true;
				if (centered)
				{
					bmp.x = -bmp.width/2;
					bmp.y = -bmp.height/2;
					retval = new Sprite;
					DisplayObjectContainer(retval).addChild(bmp);
				}
				else
				{
					retval = bmp;
				}
				if (postFilter)
				{
					retval.filters = postFilter;
				}
			}
			return retval; // this will be either a bitmap, a bitmap centered on a sprite, or the source vector object 
		}
		// Ship assets /////////////////////////////////////////////////////
		[Embed(source="assets/master.swf", symbol="ship2_0")]		static private const SHIP0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_0_0")]		static private const SHIP0_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_0_1")]		static private const SHIP0_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_1")]		static private const SHIP1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_1_0")]		static private const SHIP1_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_1_1")]		static private const SHIP1_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_2")]		static private const SHIP2:Class;
		[Embed(source="assets/master.swf", symbol="ship2_2_0")]		static private const SHIP2_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_2_1")]		static private const SHIP2_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_3")]		static private const SHIP3:Class;
		[Embed(source="assets/master.swf", symbol="ship2_3_0")]		static private const SHIP3_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_3_1")]		static private const SHIP3_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_4")]		static private const SHIP4:Class;
		[Embed(source="assets/master.swf", symbol="ship2_4_0")]		static private const SHIP4_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_4_1")]		static private const SHIP4_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_5")]		static private const SHIP5:Class;
		[Embed(source="assets/master.swf", symbol="ship2_5_0")]		static private const SHIP5_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_5_1")]		static private const SHIP5_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_6")]		static private const SHIP6:Class;
		[Embed(source="assets/master.swf", symbol="ship2_6_0")]		static private const SHIP6_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_6_1")]		static private const SHIP6_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_7")]		static private const SHIP7:Class;
		[Embed(source="assets/master.swf", symbol="ship2_7_0")]		static private const SHIP7_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_7_1")]		static private const SHIP7_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_8")]		static private const SHIP8:Class;
		[Embed(source="assets/master.swf", symbol="ship2_9")]		static private const SHIP9:Class;
		[Embed(source="assets/master.swf", symbol="ship2_9_1")]		static private const SHIP9_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_9_2")]		static private const SHIP9_2:Class;
		[Embed(source="assets/master.swf", symbol="ship2_10")]		static private const SHIP10:Class;
		[Embed(source="assets/master.swf", symbol="ship2_10_1")]		static private const SHIP10_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_10_2")]		static private const SHIP10_2:Class;
		[Embed(source="assets/master.swf", symbol="ship2_11")]		static private const SHIP11:Class;
		[Embed(source="assets/master.swf", symbol="ship2_11_1")]		static private const SHIP11_1:Class;
		[Embed(source="assets/master.swf", symbol="ship2_11_2")]		static private const SHIP11_2:Class;
		[Embed(source="assets/master.swf", symbol="ship2_12")]		static private const SHIP12:Class;
		[Embed(source="assets/master.swf", symbol="ship2_12_0")]		static private const SHIP12_0:Class;
		[Embed(source="assets/master.swf", symbol="ship2_12_1")]		static private const SHIP12_1:Class;

		static private const SHIP_TYPES:Array = 
			[SHIP0, SHIP0_0, SHIP0_1, SHIP1, SHIP1_0, SHIP1_1, SHIP2, SHIP2_0, SHIP2_1, SHIP3, SHIP3_0, SHIP3_1, SHIP4, SHIP4_0, SHIP4_1, SHIP5, SHIP5_0, SHIP5_1, SHIP6, SHIP6_0, SHIP6_1, SHIP7, SHIP7_0, SHIP7_1, SHIP8, SHIP9, SHIP9_1, SHIP9_2, SHIP10, SHIP10_1, SHIP10_2, SHIP11, SHIP11_1, SHIP11_2, SHIP12, SHIP12_0, SHIP12_1];
		static private var SHIP_SCALES:Array;
	
		static public function createShip(index:uint):DisplayObject
		{
			if (!SHIP_SCALES)
			{
				SHIP_SCALES = [];
				SHIP_SCALES[21] = 0.7;
				SHIP_SCALES[22] = 0.7;
				SHIP_SCALES[23] = 0.7;
				SHIP_SCALES[34] = 0.8;
				SHIP_SCALES[35] = 0.8;
				SHIP_SCALES[36] = 0.8;
				SHIP_SCALES[28] = 0.8;
				SHIP_SCALES[29] = 0.8;
				SHIP_SCALES[30] = 0.8;
				SHIP_SCALES[15] = 0.9;
				SHIP_SCALES[16] = 0.9;
				SHIP_SCALES[17] = 0.9;
			}
			const scale:Number = SHIP_SCALES[index] || 1;
			return createAssetRasterized(SHIP_TYPES[index], true, scale, null, s_dropShadow);
		}
		static public function createShipRaw(index:uint):DisplayObject
		{
			var ship:DisplayObject = new SHIP_TYPES[index];
			ship.filters = s_dropShadow;
			return ship;
		}

		// end ships /////////////////////////////////////////////////////////////
		[Embed(source="assets/master.swf", symbol="rocket0")]		static private const ROCKET0:Class;
		[Embed(source="assets/master.swf", symbol="rocket1")]		static private const ROCKET1:Class;
		[Embed(source="assets/master.swf", symbol="rocket2")]		static private const ROCKET2:Class;
		[Embed(source="assets/master.swf", symbol="rocket3")]		static private const ROCKET3:Class;
		static private const ROCKET_TYPES:Array = [ROCKET0, ROCKET1, ROCKET2, ROCKET3];
		
		static public function createRocket(index:uint):DisplayObject
		{
			return createAssetRasterized(ROCKET_TYPES[index], false);
		}
		[Embed(source="assets/master.swf", symbol="flame")]		static private const FLAME:Class;
		[Embed(source="assets/master.swf", symbol="blueflame")]		static private const BLUEFLAME:Class;
		[Embed(source="assets/master.swf", symbol="shield")]		static private const SHIELD:Class;
		static public function createFlame():DisplayObject
		{
			return createAssetRasterized(FLAME, false, 1, s_blur);
		}
		static public function createBlueFlame():DisplayObject
		{
			return createAssetRasterized(BLUEFLAME, false, 1, s_blur);
		}
		static public function createShield():DisplayObject
		{
			return createAssetRasterized(SHIELD, true, 1, s_blur);
		}
		[Embed(source="assets/master.swf", symbol="explosion1")] static private const EXPLOSION1:Class;
		[Embed(source="assets/master.swf", symbol="explosion2")] static private const EXPLOSION2:Class;
		[Embed(source="assets/master.swf", symbol="explosion3")] static private const EXPLOSION3:Class;
		[Embed(source="assets/master.swf", symbol="explosion4")] static private const EXPLOSION4:Class;
		[Embed(source="assets/master.swf", symbol="explosion5")] static private const EXPLOSION5:Class;
		[Embed(source="assets/master.swf", symbol="explosionsmall1")] static private const SMALLEXPLOSION1:Class;
		[Embed(source="assets/master.swf", symbol="explosionsmall2")] static private const SMALLEXPLOSION2:Class;
		[Embed(source="assets/master.swf", symbol="smoke1")] static private const SMOKE1:Class;
		[Embed(source="assets/master.swf", symbol="smoke2")] static private const SMOKE2:Class;
		static private const EXPLOSION_TYPES:Array = [EXPLOSION1, EXPLOSION2, EXPLOSION3, EXPLOSION4, EXPLOSION5];
		static private const SMALLEXPLOSION_TYPES:Array = [SMALLEXPLOSION1, SMALLEXPLOSION2];
		static private const SMOKE_TYPES:Array = [SMOKE1, SMOKE2];
		static public function createExplosion(index:uint):DisplayObject
		{
			return createAssetRasterized(EXPLOSION_TYPES[index], true, 1, s_blurHeavy);
		}
		static public function createSmallExplosion(index:uint):DisplayObject
		{
			return createAssetRasterized(SMALLEXPLOSION_TYPES[index], true, 1, s_blur);
		}
		static public function createSmoke(index:uint):DisplayObject
		{
			return createAssetRasterized(SMOKE_TYPES[index], true, 1, s_blurHeavy);
		}

		// tanks ////////////////////////////////////////////////////////////////
		[Embed(source="assets/master.swf", symbol="tankhull0")]		static private const HULL0:Class;
		[Embed(source="assets/master.swf", symbol="tankhull1")]		static private const HULL1:Class;
		[Embed(source="assets/master.swf", symbol="tankhull2")]		static private const HULL2:Class;
		[Embed(source="assets/master.swf", symbol="tankhull3")]		static private const HULL3:Class;
		[Embed(source="assets/master.swf", symbol="tankhull4")]		static private const HULL4:Class;
		[Embed(source="assets/master.swf", symbol="tankturret0")]		static private const TURRET0:Class;
		[Embed(source="assets/master.swf", symbol="tankturret1")]		static private const TURRET1:Class;
		[Embed(source="assets/master.swf", symbol="tankturret2")]		static private const TURRET2:Class;
		[Embed(source="assets/master.swf", symbol="tankturret3")]		static private const TURRET3:Class;
		[Embed(source="assets/master.swf", symbol="tankturret4")]		static private const TURRET4:Class;

		static private const HULL_TYPES:Array =	[HULL0, HULL2, HULL3, HULL4, HULL1];
		static private const TURRET_TYPES:Array = [TURRET0, TURRET1, TURRET2, TURRET3, TURRET4];
		static public function createHull(index:uint, rasterized:Boolean = true):DisplayObject
		{
			return rasterized ? createAssetRasterized(HULL_TYPES[index], false, Consts.TANK_SCALE) : new HULL_TYPES[index];
		}
		static public function createTurret(index:uint, rasterized:Boolean = true):DisplayObject
		{
			return rasterized ? createAssetRasterized(TURRET_TYPES[index], false, Consts.TANK_SCALE * 1.1) : new TURRET_TYPES[index];
		}

		[Embed(source="assets/master.swf", symbol="tanktread")]		static private const TANKTREAD:Class;
		[Embed(source="assets/master.swf", symbol="tanktreadtop")]		static private const TANKTREADTOP:Class;
		static public function createTrack():DisplayObjectContainer
		{
			var base:DisplayObjectContainer = new TANKTREAD;
			base.addChild(new TANKTREADTOP);
			return base;
		}
		[Embed(source="assets/master.swf", symbol="cannonround0")]		static private const CANNONROUND0:Class;
		[Embed(source="assets/master.swf", symbol="cannonround1")]		static private const CANNONROUND1:Class;
		static private const CANNONS:Array = [CANNONROUND0, CANNONROUND1];
		static public function createCannonBlast(level:uint):DisplayObject
		{
			return createAssetRasterized(CANNONS[level], true);
		}
		[Embed(source="assets/master.swf", symbol="muzzleflash0")]		static private const MUZZLEFLASH0:Class;
		[Embed(source="assets/master.swf", symbol="muzzleflash1")]		static private const MUZZLEFLASH1:Class;
		[Embed(source="assets/master.swf", symbol="muzzleflash2")]		static private const MUZZLEFLASH2:Class;
		static private const MUZZLEFLASH:Array = [MUZZLEFLASH0, MUZZLEFLASH1, MUZZLEFLASH2];
		static public function createMuzzleFlash(level:uint):DisplayObject
		{
			return createAssetRasterized(MUZZLEFLASH[level], true, 1, s_blur); 
		}
		static public function createExplosionParticle(color:uint):DisplayObject
		{
			return AbstractSimpleRasterizedObjectCreator.getInstance(ExplosionCreator).create(color);
		}
		static public function createBullet(color:uint = 0xff7f00):DisplayObject
		{
			return AbstractSimpleRasterizedObjectCreator.getInstance(BulletCreator).create(color);
		}
		static public function createLaser(color:uint = 0xff0000):DisplayObject
		{
			return AbstractSimpleRasterizedObjectCreator.getInstance(LaserCreator).create(color);
		}
		static public function createFusionBlast(color:uint = 0xff00ff):DisplayObject
		{
			return AbstractSimpleRasterizedObjectCreator.getInstance(FusionBlastCreator).create(color);
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
			
//			wo.graphics.lineStyle(0);
			var matrix:Matrix = new Matrix;
			matrix.createGradientBox(width, height, 0, -width/2, -height/2);
			
			wo.graphics.beginGradientFill(GradientType.RADIAL, [color, color], [100, 0], [63, 255], matrix); 
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
		
		public static function createReticle(radius:Number):DisplayObject
		{
			var foo:Shape = new Shape;
			foo.graphics.lineStyle(1);
			foo.graphics.beginFill(0xff0000, .5);
			foo.graphics.drawCircle(0, 0, radius);
			foo.graphics.moveTo(10, 0);
			foo.graphics.lineTo(-10, 0);
			foo.graphics.moveTo(0, 10);
			foo.graphics.lineTo(0, -10);
			foo.graphics.endFill();
			return foo;
		}
	}
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.utils.Dictionary;

// The point of this is to rasterize a simple vector object once, and look up its BitmapData
// to create Bitmap instances later.
internal class AbstractSimpleRasterizedObjectCreator
{
	static private var s_store:Dictionary = new Dictionary;

	private var _centered:Boolean;
	public function AbstractSimpleRasterizedObjectCreator(centered:Boolean = false)
	{
		_centered = centered;
	}
	private var _keyLookup:Object = {};
	protected function create_impl(color:uint):DisplayObject { throw "override me"; } // "abstract" template method, to be overridden by subclass 
	public function create(color:uint):DisplayObject
	{
		var key:Object = _keyLookup[color];
		if (!key)
		{
			key = _keyLookup[color] = new Object;
		}
		var bmd:BitmapData = s_store[key] as BitmapData;
		if (!bmd)
		{
			var raw:DisplayObject = create_impl(color);
			if (!ActorAssetManager.RASTERIZING)
			{
				return raw;
			}
			bmd = ActorAssetManager.rasterize(raw);
			s_store[key] = bmd;
		}
		
		var retval:DisplayObject = new Bitmap(bmd);
		if (_centered)
		{
			retval.x = -retval.width/2;
			retval.y = -retval.height/2;
			
			var parent:Sprite = new Sprite;
			parent.addChild(retval);
			retval = parent;
		}
		return retval; 
	}

	static private var s_instances:Dictionary = new Dictionary;
	static public function getInstance(clss:Class):AbstractSimpleRasterizedObjectCreator
	{
		if (!s_instances[clss])
		{
			s_instances[clss] = new clss;
		}
		return s_instances[clss];
	}
}

final internal class ExplosionCreator extends AbstractSimpleRasterizedObjectCreator
{
	static private const EXPLOSION_SIZE:Number = 3;
	static private const HALFSIZE:Number = EXPLOSION_SIZE/2;
	protected override function create_impl(color:uint):DisplayObject
	{
		var particle:Shape = new Shape;
		particle.graphics.lineStyle(0, color);
		particle.graphics.beginFill(color);
		particle.graphics.drawRect(-HALFSIZE, -HALFSIZE, EXPLOSION_SIZE, EXPLOSION_SIZE);
		particle.graphics.endFill();
		return particle;
	}
}
final internal class BulletCreator extends AbstractSimpleRasterizedObjectCreator
{
	protected override function create_impl(color:uint):DisplayObject
	{
//		return ActorAssetManager.createCircle(color, 7, 7);
		return ActorAssetManager.createCircle(color, 10, 10);
	}
}
final internal class LaserCreator extends AbstractSimpleRasterizedObjectCreator
{
	public function LaserCreator() { super(true); }

	private static const LASER_LENGTH:Number = 10;
	protected override function create_impl(color:uint):DisplayObject
	{
		var bullet:Shape = new Shape;
		bullet.graphics.lineStyle(3, color);
		bullet.graphics.moveTo(0, -LASER_LENGTH/2);
		bullet.graphics.lineTo(0, LASER_LENGTH/2);
		return bullet;
	}
}
final internal class FusionBlastCreator extends AbstractSimpleRasterizedObjectCreator
{
	public function FusionBlastCreator() { super(true); }

	static private const HEIGHT:Number = 20;
	static private const WIDTH:Number = 10;
	protected override function create_impl(color:uint):DisplayObject
	{
		var blast:Shape = new Shape;
		blast.graphics.lineStyle(0, 0, 0);
		blast.graphics.beginFill(color, 0.5);
		blast.graphics.drawRoundRect(-WIDTH/2, -HEIGHT/2, WIDTH, HEIGHT, 4, 4);
		blast.graphics.endFill();
		return blast;
	}
}

