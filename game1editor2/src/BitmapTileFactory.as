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
			var retval:DisplayObject = AssetManager.instance.getBitmap(tileID);
			retval.name = String(tileID);
			return retval;
		}
		public function get tileSize():Number
		{
			return AssetManager.TILES_SIZE;
		}
		
		static public function tileToID(tile:DisplayObject):uint
		{
			return parseInt(tile.name);
		}
	}
}