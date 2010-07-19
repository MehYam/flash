package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import karnold.utils.Util;

	public class GameList extends Sprite
	{
		static public const DEBUG_MODE:Boolean = false;

		private var _scroll:Boolean;
		public function GameList(scroll:Boolean = true)
		{
			_scroll = scroll;
		}
		private var _bounds:Point = new Point;
		public function setBounds(width:Number, height:Number):void
		{
			Util.setPointXY(_bounds, width, height);

			if (!DEBUG_MODE)
			{
				scrollRect = new Rectangle(0, 0, width, height);
			}
		}

		private var _items:Array = [];
		private var _currentSelection:DisplayObject;
		public function addItem(item:DisplayObject):void
		{
			_items.push(item);
			Util.listen(item, MouseEvent.MOUSE_DOWN, onItemMouseDown);
		}
		
		public function getItem(index:uint):DisplayObject
		{
			return _items[index];
		}

		public function selectItem(item:DisplayObject):void
		{
			if (item != _currentSelection)
			{
				if (_currentSelection is GameListItem)
				{
					GameListItem(_currentSelection).selected = false;
				}
				_currentSelection = item as DisplayObject;
				if (_currentSelection is GameListItem)
				{
					GameListItem(_currentSelection).selected = true;
				}
			}			
		}
		public function get selection():DisplayObject
		{
			return _currentSelection;
		}
		private function onItemMouseDown(e:Event):void
		{
			selectItem(DisplayObject(e.currentTarget));
			
			dispatchEvent(new Event(Event.SELECT));
		}

		public function clear():void
		{
			for each (var removee:DisplayObject in _items)
			{
				if (removee.parent)
				{
					removee.parent.removeChild(removee);
				}
			}
			updateScrollButtons();
		}

		//KAI: this is all quick and dirty, and brittle
		private var _scrollPos:uint = 0;
		private var _itemsVisible:uint = 0;
		private var _leftButton:GameButton;
		private var _rightButton:GameButton;
		public function render():void
		{
			clear();

			var hPos:Number = 4;
			_itemsVisible = 0;
			for (var item:uint = _scrollPos; item < _items.length; ++item)
			{
				var dobj:DisplayObject = _items[item];
				dobj.x = hPos;
				
				addChildAt(dobj, 0);
				
				hPos = dobj.x + dobj.width;
				if (hPos > _bounds.x)
				{
					break;
				}
				++_itemsVisible;
			}
			if (DEBUG_MODE)
			{
				graphics.clear();
				graphics.lineStyle(1, 0xff0000);
				graphics.drawRect(0, 0, width, height);
			}			
			if (!_leftButton && _scroll)
			{
				_leftButton = GameButton.create("<", true, 12, 1);
				_leftButton.x = 0;
				_leftButton.y = _bounds.y - _leftButton.height;
				_leftButton.enabled = false;
				Util.listen(_leftButton, MouseEvent.MOUSE_DOWN, onScrollLeft);
				addChild(_leftButton);
				
				_rightButton = GameButton.create(">", true, 12, 1);
				_rightButton.x = _bounds.x - _rightButton.width;
				_rightButton.y = _leftButton.y;
				Util.listen(_rightButton, MouseEvent.MOUSE_DOWN, onScrollRight);
				addChild(_rightButton);
			}
			updateScrollButtons();
		}
		
		private function onScrollLeft(e:Event):void
		{
			if (_scrollPos > 0)
			{
				--_scrollPos;
				render();
			}
		}
		private function get allTheWayRight():Boolean
		{
			return (_scrollPos + _itemsVisible) >= _items.length; 
		}
		private function onScrollRight(e:Event):void
		{
			if (!allTheWayRight)
			{
				++_scrollPos;
				render();
			}
		}
		private function updateScrollButtons():void
		{
			if (_leftButton)
			{
				_leftButton.enabled = (_scrollPos > 0);
				_rightButton.enabled = !allTheWayRight;
				
				//hack on hack on hack....... this fixes that annoying bug where you scroll all the way in either direction
				_leftButton.mouseEnabled = true;
				_rightButton.mouseEnabled = true;
			}
		}
	}
}