package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import karnold.utils.Util;

	public class GameList extends Sprite
	{
		public function GameList()
		{
		}
		
		private var _bounds:Point = new Point;
		public function setBounds(width:Number, height:Number):void
		{
			Util.setPointXY(_bounds, width, height);
			
			scrollRect = new Rectangle(0, 0, width, height);
		}

		private var _items:Array = [];
		public function addItem(item:DisplayObject):void
		{
			_items.push(item);
		}
		
		public function getItem(index:uint):DisplayObject
		{
			return _items[index];
		}

		//KAI: this is all quick and dirty, and brittle
		public function render(hGap:Number = 10):void
		{
			var hPos:Number = 0;
			var bounds:Rectangle;
			for each (var dobj:DisplayObject in _items)
			{
				bounds = dobj.getBounds(dobj);
//				dobj.x = hPos + dobj.width/2;
//				dobj.y = _bounds.y/2;
				dobj.x = -bounds.left + hPos;
				dobj.y = -bounds.top;
				
				addChild(dobj);
				
				hPos = dobj.x + bounds.width;
				if (hPos > _bounds.x)
				{
					break;
				}
			}
			graphics.lineStyle(1, 0xff0000);
			graphics.drawRect(0, 0, width, height);
		}
	}
}