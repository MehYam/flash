package
{
	import flash.display.DisplayObject;
	
	import karnold.tile.ITileFactory;
	
	public class BitmapTileFactory implements ITileFactory
	{
		public function BitmapTileFactory()
		{
		}
		
		public function getTile(tileID:uint):DisplayObject
		{
			return AssetManager.instance.getBitmap(tileID);
		}
		
		public function get tileSize():Number
		{
			return AssetManager.TILES_SIZE;
		}
	}
}