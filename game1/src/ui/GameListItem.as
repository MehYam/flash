package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import karnold.utils.Util;
	
	import spark.primitives.Rect;
	
	public class GameListItem extends Sprite
	{
		private var _explicitWidth:Number;
		private var _explicitHeight:Number;
		
		public var cookie:uint;
		public function GameListItem(child:DisplayObject, width:Number, height:Number, cookie:uint = 0)
		{
			super();
			
			_explicitWidth = width;
			_explicitHeight = height;
			this.cookie = cookie;

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

			highlight(0);
			
			Util.listen(this, MouseEvent.ROLL_OVER, onRollOver);
			Util.listen(this, MouseEvent.ROLL_OUT, onRollOut);
		}

		private var _selected:Boolean = false;
		public function set selected(b:Boolean):void
		{
			highlight(b ? 0.3 : 0);
			_selected = b;
		}
		private function highlight(amount:Number):void
		{
			if (GameList.DEBUG_MODE)
			{
				graphics.lineStyle(1, 0x00ff00);
			}

			this.graphics.clear();
			this.graphics.beginFill(0xff, amount);
			this.graphics.drawRoundRect(0, 0, _explicitWidth, _explicitHeight, 20, 20);
		}
		private function onRollOver(e:Event):void
		{
			highlight(_selected ? 0.5 : 0.1);
		}
		private function onRollOut(e:Event):void
		{
			highlight(_selected ? 0.3 : 0);
		}
	}
}