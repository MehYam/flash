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
			
//			scrollRect = new Rectangle(0, 0, width, height);
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
			for each (var dobj:DisplayObject in _items)
			{
				dobj.x = hPos;
				
				addChild(dobj);
				
				hPos = dobj.x + dobj.width;
				if (hPos > _bounds.x)
				{
					break;
				}
			}
			graphics.lineStyle(1, 0xff0000);
			graphics.drawRect(0, 0, width, height);
			
			var leftButton:GameButton = GameButton.create("<", true, 12, 1);
			leftButton.x = 0;
			leftButton.y = _bounds.y - leftButton.height;
			leftButton.enabled = false;
			addChild(leftButton);
			
			var rightButton:GameButton = GameButton.create(">", true, 12, 1);
			rightButton.x = _bounds.x - rightButton.width;
			rightButton.y = leftButton.y;
			addChild(rightButton);
		}
	}
}