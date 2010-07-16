package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
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

		[Embed(source="assets/master.swf", symbol="buttonFace")]
		static private const BUTTONFACE:Class;
		[Embed(source="assets/master.swf", symbol="buttonFaceDown")]
		static private const BUTTONFACEDOWN:Class;
		[Embed(source="assets/master.swf", symbol="buttonFaceOver")]
		static private const BUTTONFACEOVER:Class;
		public function buttonFace():DisplayObject { return new BUTTONFACE; } 
		public function buttonFaceDown():DisplayObject { return new BUTTONFACEDOWN; } 
		public function buttonFaceOver():DisplayObject { return new BUTTONFACEOVER; } 
	}
}