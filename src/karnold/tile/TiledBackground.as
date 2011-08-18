package karnold.tile
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import gameData.UserData;
	
	import karnold.utils.Array2D;
	import karnold.utils.Bounds;
	import karnold.utils.Location;

	public class TiledBackground
	{
		private var _parent:DisplayObjectContainer;
		private var _displaySize:Point;
		private var _factory:ITileFactory;
		private var _tiles:Array2D;

		// Blt'ing all the tiles to a single display-size buffer seems to be more efficient than
		// parenting the actual bitmaps on the display - mind blown.  Also, the non-buffered mode
		// has some weird aliasing on the row and column boundaries when the parent is scaled.
		static private const BUFFERED_TILES:Boolean = true;
		static public function createFromString(parent:DisplayObjectContainer, factory:ITileFactory, displayWidth:Number, displayHeight:Number, string:String):TiledBackground
		{
			var horz:uint = 0;
			var vert:uint = 0;

			var tiles:Array = string.split(",");
			for each (var tile:String in tiles)
			{
				var parts:Array = tile.split("-");
				if (parts[1] > horz)
				{
					horz = parts[1];
				}
				if (parts[2] > vert)
				{
					vert = parts[2];
				}
			}
			var retval:TiledBackground = new TiledBackground(parent, factory, horz + 1, vert + 1, displayWidth, displayHeight);
			retval.fromString(string);
			return retval;
		}
		public function TiledBackground(parent:DisplayObjectContainer, factory:ITileFactory, 
							 horzSlots:uint, vertSlots:uint,
							 displayWidth:Number, displayHeight:Number)
		{
			_parent = parent;
			_displaySize = new Point(displayWidth, displayHeight);
			_factory = factory;
			_tiles = new Array2D(horzSlots, vertSlots);
		}
		
		public function putTile(tileID:uint, x:uint, y:uint):void
		{
			removeChildAt(x, y);
			_tiles.put(_factory.getTile(tileID), x, y);
		}
		
		public function clearTile(x:uint, y:uint):void
		{
			removeChildAt(x, y);
			_tiles.put(null, x, y);
		}

		public function deparent():void
		{
			const width:uint = _tiles.width;
			const height:uint = _tiles.height;
			for (var x:uint = 0; x < width; ++x)
			{
				for (var y:uint = 0; y < height; ++y)
				{
					removeChildAt(x, y);
				}
			}
			if (_buffer && _buffer.parent)
			{
				_buffer.parent.removeChild(_buffer);
				_buffer = null;
			}
		}

		private function removeChildAt(x:uint, y:uint):void
		{
			var tile:DisplayObject = DisplayObject(_tiles.lookup(x, y));
			if (tile && tile.parent)
			{
				tile.parent.removeChild(tile);
			}
		}

		public function get tilesArray():Array2D
		{
			return _tiles;
		}

		public function pointToLocation(point:Point, tileLocOut:Location):void
		{
			const TILE_SIZE:Number = _factory.tileSize;
			tileLocOut.x = (point.x + _tileOffset.x) / TILE_SIZE + _bounds.left;
			tileLocOut.y = (point.y + _tileOffset.y) / TILE_SIZE + _bounds.top;
		}
			
		private var _bounds:Bounds = new Bounds;
		private var _tileOffset:Point = new Point;

		// [kja] premature optimization - these are kept around to avoid allocating them every frame
		// all premature optimization is marked as po_*
		private var po_tempBounds:Bounds = new Bounds;
		private var po_tempTileSource:Rectangle = new Rectangle;
		private var po_tempTileDest:Point = new Point;
		private var _buffer:Bitmap;
		public function setCamera(cameraPos:Point):void
		{
			if (BUFFERED_TILES && !_buffer)
			{
				var bmd:BitmapData = new BitmapData(_displaySize.x, _displaySize.y, false);
				_buffer = new Bitmap(bmd);
				_parent.addChild(_buffer);
			}
			const TILE_SIZE:Number = _factory.tileSize;

			// determine the before/after of the world scene bounds
			po_tempBounds.left = cameraPos.x/TILE_SIZE;
			po_tempBounds.right = (cameraPos.x + _displaySize.x)/TILE_SIZE;
			
			po_tempBounds.top = cameraPos.y/TILE_SIZE;
			po_tempBounds.bottom = (cameraPos.y + _displaySize.y)/TILE_SIZE;
			
			_tileOffset.x = cameraPos.x%TILE_SIZE;
			_tileOffset.y = cameraPos.y%TILE_SIZE;
			
			// loop through the objects in current bounds, setting their position, and adding
			// them to the stage if they're not yet there
			var slotX:uint;
			var slotY:uint;
			for (slotX = Math.max(0, po_tempBounds.left); slotX <= po_tempBounds.right; ++slotX)
			{
				for (slotY = Math.max(0, po_tempBounds.top); slotY <= po_tempBounds.bottom; ++slotY)
				{
					var wo:DisplayObject = DisplayObject(_tiles.lookup(slotX, slotY));
					if (wo)
					{
						const destX:Number = (slotX - po_tempBounds.left) * TILE_SIZE - _tileOffset.x;
						const destY:Number = (slotY - po_tempBounds.top) * TILE_SIZE - _tileOffset.y;
						if (BUFFERED_TILES)
						{
							po_tempTileSource.width = wo.width;
							po_tempTileSource.height = wo.height;
							po_tempTileDest.x = destX;
							po_tempTileDest.y = destY;
							_buffer.bitmapData.copyPixels(Bitmap(wo).bitmapData, po_tempTileSource, po_tempTileDest); 
						}
						else
						{
							wo.x = destX;
							wo.y = destY;
							if (!wo.parent)
							{
								_parent.addChild(wo);
								// trace("adding", slotX, slotY);							
							}
						}
					}
				}
			} 
			// loop through the objects of the last bounds, removing them if they're offscreen
			if (BUFFERED_TILES && !po_tempBounds.equals(_bounds))
			{
				const left:uint = Math.max(0, _bounds.left); 
				for (slotX = left; slotX <= _bounds.right; ++slotX)
				{
					for (slotY = Math.max(0, _bounds.top); slotY <= _bounds.bottom; ++slotY)
					{
						var removee:DisplayObject = DisplayObject(_tiles.lookup(slotX, slotY));
						if (removee)
						{
							if (removee.parent && !po_tempBounds.contains(slotX, slotY))
							{
								removee.parent.removeChild(removee);
								// trace("removing", slotX, slotY);
							}
						}
					}
				} 
			}
			_bounds.setBounds(po_tempBounds);
		}
		
		public function toString():String
		{
			var retval:String = "";
			for (var x:uint = 0; x < _tiles.width; ++x)
			{
				for (var y:uint = 0; y < _tiles.height; ++y)
				{
					var obj:DisplayObject = _tiles.lookup(x, y) as DisplayObject;
					if (obj)
					{
						if (retval.length)
						{
							retval += ",";
						}
						retval += _factory.idFromTile(obj) + "-" + x + "-" + y;
					}
				}
			}
			return retval;
		}
		public function fromString(str:String):void
		{
			if (str.length)
			{
				var tiles:Array = str.split(",");
				for each (var tile:String in tiles)
				{
					var parts:Array = tile.split("-");
					putTile(parseInt(parts[0]), parseInt(parts[1]), parseInt(parts[2]));
				}
			}
		}
	}
}