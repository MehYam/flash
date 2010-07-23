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

			renderHighlight();
			
			Util.listen(this, MouseEvent.ROLL_OVER, onRollOver);
			Util.listen(this, MouseEvent.ROLL_OUT, onRollOut);
			
			mouseChildren = false;
		}

		private var _border:Boolean = false;
		public function set border(b:Boolean):void
		{
			_border = b;
			renderHighlight();
			
//			UIUtil.addGroupBox(this, "", 0, 0, _explicitWidth, _explicitHeight);
		}
		private var _selected:Boolean = false;
		private var _rolledOver:Boolean = false;
		public function set selected(b:Boolean):void
		{
			_selected = b;
			renderHighlight();
		}
		static private const ROLLOVER_ALPHA:Number = 0.1;
		static private const SELECT_ALPHA:Number = 0.3;
		private function renderHighlight():void
		{
			if (GameList.DEBUG_MODE)
			{
				graphics.lineStyle(1, 0x00ff00);
			}

			var amount:Number = 0;
			if (_selected)
			{
				amount += SELECT_ALPHA;
			}
			if (_rolledOver)
			{
				amount += ROLLOVER_ALPHA;
			}
			this.graphics.clear();
			if (_border)
			{
				this.graphics.lineStyle(1, 0);
				this.graphics.drawRoundRect(1, 1, _explicitWidth-2, _explicitHeight-2, 20, 20);
				this.graphics.lineStyle(0, 0, 0);
			}
			this.graphics.beginFill(0x337777, amount);
			this.graphics.drawRoundRect(0, 0, _explicitWidth, _explicitHeight, 20, 20);
		}
		private function onRollOver(e:Event):void
		{
			_rolledOver = true;
			renderHighlight();
		}
		private function onRollOut(e:Event):void
		{
			_rolledOver = false;
			renderHighlight();
		}
	}
}