package 
{
	import flash.display.DisplayObject;
	
	import karnold.tile.ITileFactory;
	
	public class DebugVectorTileFactory implements ITileFactory
	{
		public function DebugVectorTileFactory()
		{
		}
		
		static public const TILE_SPIRO:uint = 0;
		static public const TILE_CIRCLE:uint = 1;
		static public const TILE_SQUARE:uint = 2;
		public function getTile(tileID:uint):DisplayObject
		{
			switch (tileID) {
			case TILE_SPIRO:
				return ActorAssetManager.createSpiro(Math.random() * 0xffffff, tileSize, tileSize)
			case TILE_CIRCLE:
				return ActorAssetManager.createCircle(Math.random() * 0xff0000, tileSize, tileSize);
			case TILE_SQUARE:
				return ActorAssetManager.createSquare(Math.random() * 0x00ff00, tileSize);
			}
			return null;
		}
		public function idFromTile(tile:DisplayObject):uint
		{
			return 0;  // we don't know
		}
		public function get tileSize():Number
		{
			return 20;
		}
	}
}