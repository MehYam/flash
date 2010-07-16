package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	
	import karnold.tile.IBitmapFactory;

	public class AssetManager implements IBitmapFactory
	{
		public function AssetManager()
		{
		}

		//KAI: if this goes in-game, it's better to load it and ditch the loader so that the bitmap data's not duplicated
		// when we copy it out - OR - see if Bitmap is really smart, and just use the tiled thing.  Worth profiling to
		// see what the difference is
		[Embed(source="assets/tiled_sepia_inv.png")]
		private var TiledImages:Class;
		
		static private var s_instance:AssetManager;
		static public function get instance():AssetManager
		{
			if (!s_instance)
			{
				s_instance = new AssetManager;
			}
			return s_instance;
		}

		static public const TILES:uint = 14;
		static public const TILES_SIZE:uint = 40;
		static private const TILE_COLUMNS:uint = 4;

		private var _cachedTiles:Array;

		public function getBitmap(index:uint):Bitmap
		{
			if (!_cachedTiles)
			{
				_cachedTiles = [];

				var bitmap:Bitmap = new TiledImages;
				var origin:Point = new Point(0, 0);
				for (var i:uint = 0; i < TILES; ++i)
				{
					var tileBMD:BitmapData = new BitmapData(TILES_SIZE, TILES_SIZE, false);
					var srcRect:Rectangle = new Rectangle((i % TILE_COLUMNS) * TILES_SIZE, int(i / TILE_COLUMNS) * TILES_SIZE, TILES_SIZE, TILES_SIZE);

					tileBMD.copyPixels(bitmap.bitmapData, srcRect, origin);
					
					_cachedTiles.push(tileBMD);
				}
			}
			return new Bitmap(_cachedTiles[index]);
		}
		
		[Embed(source="assets/crash1.mp3")]
		static private const CrashSound:Class;
		private var _crashSound:Sound;
		public function crashSound():void
		{
			if (!_crashSound)
			{
				_crashSound = new CrashSound() as Sound;
			}
			_crashSound.play();
		}
		[Embed(source="assets/laser1.mp3")]
		static private const WeaponSound:Class;
		private var _weaponSound:Sound;
		public function laserSound():void
		{
			if (!_weaponSound)
			{
				_weaponSound = new WeaponSound() as Sound;
			}
			_weaponSound.play();
		}

		static private const s_uiFaceScale9:Rectangle = new Rectangle(10, 10, 30, 30);
		static private function uiFace(color:uint):DisplayObject
		{
			var rect:Shape = new Shape;
			
			rect.graphics.lineStyle(1);
			rect.graphics.beginFill(color);
			rect.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
			rect.graphics.endFill();
			
			rect.scale9Grid = s_uiFaceScale9;
			return rect;			
		}
		static private const s_faceFilter:Array = [new BevelFilter(3, 45)]; 
		public function buttonFace(raised:Boolean = true):DisplayObject
		{
			var retval:DisplayObject = uiFace(0xa6a6a6);
			if (raised)
			{
				retval.filters = s_faceFilter;
			}
			return retval;
		}
		public function buttonFaceDown():DisplayObject
		{
			var retval:DisplayObject = uiFace(0xa6a6a6); 
			var colorTransform:ColorTransform = retval.transform.colorTransform;
			colorTransform.greenOffset = 10;
			colorTransform.blueOffset = -0xff;
			colorTransform.redOffset = -0xff;
			
			retval.transform.colorTransform = colorTransform;
			return retval;
		}
		static private const s_faceOverFilter:Array = [new BevelFilter(3, 45), new DropShadowFilter(2)];
		public function buttonFaceOver(raised:Boolean = true):DisplayObject
		{
			var retval:DisplayObject = uiFace(0xa6a6a6);
			var colorTransform:ColorTransform = retval.transform.colorTransform;
			colorTransform.greenOffset = 32;
			colorTransform.blueOffset = -0xff;
			colorTransform.redOffset = -0xff;

			retval.transform.colorTransform = colorTransform;
			if (raised)
			{
				retval.filters = s_faceOverFilter;
			}
			return retval;
		}
		static private const s_innerFaceFilter:Array = [new BevelFilter(3, 235)];
		public function innerFace():DisplayObject
		{
			var rect:DisplayObject = uiFace(0xcccccc);
			rect.filters = s_innerFaceFilter
			return rect;
		}
	}
}