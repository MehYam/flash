package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.primitives.Rect;
	
	public class GameListItem extends Sprite
	{
		public function GameListItem(child:DisplayObject, width:Number, height:Number)
		{
			super();
			
			const bounds:Rectangle = child.getBounds(child);
			const childOriginOffset:Point = new Point(-bounds.left, -bounds.top);
			const sizeDiff:Point = new Point(width - child.width, height - child.height);
			
			child.x = childOriginOffset.x + sizeDiff.x/2;
			child.y = childOriginOffset.y + sizeDiff.y/2;
			
			addChild(child);
			
			graphics.lineStyle(1, 0x00ff00);
			graphics.drawRect(0, 0, width, height);
		}
	}
}