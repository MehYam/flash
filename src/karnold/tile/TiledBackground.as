package karnold.tile
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	
	import karnold.utils.Array2D;
	import karnold.utils.Bounds;
	import karnold.utils.Location;

	public class TiledBackground
	{
		private var _parent:DisplayObjectContainer;
		private var _displaySize:Point;
		private var _factory:ITileFactory;
		private var _tiles:Array2D;
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
		// all premature optimization is marked as po_
		private var po_tempBounds:Bounds = new Bounds;
		public function setCamera(cameraPos:Point):void
		{
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
						wo.x = (slotX - po_tempBounds.left) * TILE_SIZE - _tileOffset.x;
						wo.y = (slotY - po_tempBounds.top) * TILE_SIZE - _tileOffset.y;
						if (!wo.parent)
						{
							_parent.addChild(wo);
//							trace("adding", slotX, slotY);							
						}
					}
				}
			} 
			// loop through the objects of the last bounds, removing them if they're offscreen
			if (!po_tempBounds.equals(_bounds))
			{
//				trace("bounds change", _lastMapBounds, "to", po_currentMapBounds);
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
//								trace("removing", slotX, slotY);
							}
						}
					}
				} 
			}
			_bounds.setBounds(po_tempBounds);
		}
	}
}