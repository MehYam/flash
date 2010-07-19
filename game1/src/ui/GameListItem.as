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

			if (sizeDiff.x < 0 || sizeDiff.y < 0)
			{
				const scale:Number = Math.min(width/child.width, height/child.height);
				child.scaleX = scale;
				child.scaleY = scale;
			}
			child.x = childOriginOffset.x + sizeDiff.x/2;
			child.y = childOriginOffset.y + sizeDiff.y/2;
			
			addChild(child);
			
			graphics.lineStyle(1, 0x00ff00);
			graphics.drawRect(0, 0, width, height);
		}
		
		public function set selected(b:Boolean):void
		{
			if (b)
			{
				this.graphics.beginFill(0xff, 0.3);
				this.graphics.drawRoundRect(0, 0, width, height, 20, 20);
			}
			else
			{
				this.graphics.clear();
			}
		}
	}
}