package karnold.tile
{
	import flash.display.DisplayObject;

	public interface ITileFactory
	{
		function getTile(tileID:uint):DisplayObject;
		function idFromTile(obj:DisplayObject):uint;
		function get tileSize():Number;
	}
}