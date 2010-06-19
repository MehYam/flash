package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class AssetManager
	{
		public function AssetManager()
		{
		}

		//KAI: if this goes in-game, it's better to load it and ditch the loader so that the bitmap data's not duplicated
		// when we copy it out - OR - see if Bitmap is really smart, and just use the tiled thing.  Worth profiling to
		// see what the difference is
		[Embed(source="../game1/assets/tiled.png")]
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
					var srcRect:Rectangle = new Rectangle((i % TILE_COLUMNS) * TILES_SIZE, i / TILE_COLUMNS, TILES_SIZE, TILES_SIZE);

					tileBMD.copyPixels(bitmap.bitmapData, srcRect, origin);
					
					_cachedTiles.push(tileBMD);
				}
			}
			return new Bitmap(_cachedTiles[index]);
		}
	}
}