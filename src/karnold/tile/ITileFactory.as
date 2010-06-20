package karnold.tile
{
	import flash.display.DisplayObject;

	public interface ITileFactory
	{
		function getTile(tileID:uint):DisplayObject;
		function get tileSize():Number;
	}
}