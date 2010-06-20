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
			_tiles.put(_factory.getTile(tileID), x, y);
		}
		
		public function get tilesArray():Array2D
		{
			return _tiles;
		}

		public function pointToLocation(cameraPos:Point, relativePoint:Point, tileLocOut:Location):void
		{
			
		}
			
		private var _lastMapBounds:Bounds = new Bounds;
		// [kja] premature optimization - these are kept around to avoid allocating them every frame
		// all premature optimization is marked as po_
		private var po_currentMapBounds:Bounds = new Bounds;
		private var po_cellOffset:Point = new Point;
		public function setCamera(cameraPos:Point):void
		{
			const CELL_SIZE:Number = _factory.tileSize;

			// determine the before/after of the world scene bounds
			po_currentMapBounds.left = cameraPos.x/CELL_SIZE;
			po_currentMapBounds.right = (cameraPos.x + _displaySize.x)/CELL_SIZE;
			
			po_currentMapBounds.top = cameraPos.y/CELL_SIZE;
			po_currentMapBounds.bottom = (cameraPos.y + _displaySize.y)/CELL_SIZE;
			
			po_cellOffset.x = cameraPos.x%CELL_SIZE;
			po_cellOffset.y = cameraPos.y%CELL_SIZE;
			
			// loop through the objects in current bounds, setting their position, and adding
			// them to the stage if they're not yet there
			var slotX:uint;
			var slotY:uint;
			for (slotX = Math.max(0, po_currentMapBounds.left); slotX <= po_currentMapBounds.right; ++slotX)
			{
				for (slotY = Math.max(0, po_currentMapBounds.top); slotY <= po_currentMapBounds.bottom; ++slotY)
				{
					var wo:DisplayObject = DisplayObject(_tiles.lookup(slotX, slotY));
					if (wo)
					{
						wo.x = (slotX - po_currentMapBounds.left) * CELL_SIZE - po_cellOffset.x;
						wo.y = (slotY - po_currentMapBounds.top) * CELL_SIZE - po_cellOffset.y;
						if (!wo.parent)
						{
							_parent.addChild(wo);
//							trace("adding", slotX, slotY);							
						}
					}
				}
			} 
			// loop through the objects of the last bounds, removing them if they're offscreen
			if (!po_currentMapBounds.equals(_lastMapBounds))
			{
				//				trace("bounds change", _lastMapBounds, "to", po_currentMapBounds);
				const left:uint = Math.max(0, _lastMapBounds.left); 
				for (slotX = left; slotX <= _lastMapBounds.right; ++slotX)
				{
					for (slotY = Math.max(0, _lastMapBounds.top); slotY <= _lastMapBounds.bottom; ++slotY)
					{
						var removee:DisplayObject = DisplayObject(_tiles.lookup(slotX, slotY));
						if (removee)
						{
							if (removee.parent && !po_currentMapBounds.contains(slotX, slotY))
							{
								removee.parent.removeChild(removee);
//								trace("removing", slotX, slotY);
							}
						}
					}
				} 
			}
			_lastMapBounds.setBounds(po_currentMapBounds);
		}
	}
}