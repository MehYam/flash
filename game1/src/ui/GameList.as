package ui
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import karnold.utils.Util;

	// this is possibly the most poorly written UI code in history.  The fact that it looks okay
	// and actually works means i'm awesome
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
//				scrollRect = new Rectangle(0, 0, width, height);
			}
		}

		private var _items:Array = [];
		private var _currentSelection:DisplayObject;
		public function addItem(item:DisplayObject):void
		{
			_items.push(item);
			Util.listen(item, MouseEvent.MOUSE_DOWN, onItemMouseDown);
			Util.listen(item, MouseEvent.ROLL_OVER, onItemRollOver);
			Util.listen(item, MouseEvent.ROLL_OUT, onItemRollOut);
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
		public function get scrollPos():uint
		{
			return _scrollPos;
		}
		public function set scrollPos(where:uint):void
		{
			_scrollPos = where;
			render();
		}
		private function onItemMouseDown(e:Event):void
		{
			selectItem(DisplayObject(e.currentTarget));
			
			dispatchEvent(new Event(Event.SELECT));
		}
		private var _currentRolledOver:DisplayObject;
		private function onItemRollOver(e:Event):void
		{
			_currentRolledOver = DisplayObject(e.target);
			
			dispatchEvent(e.clone());
		}
		private function onItemRollOut(e:Event):void
		{
			_currentRolledOver = null;
			
			dispatchEvent(e.clone());
		}
		public function get rolledOverItem():DisplayObject
		{
			return _currentRolledOver;
		}

		public function clearItems():void
		{
			//KAI: brittle as hell... just use Flex 4 dammit
			selectItem(null);
			clear();
			_items.length = 0;
		}
		private function clear():void
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
		private var _indicators:Sprite;
		public function render():void
		{
			clear();

			var hPos:Number = 4;
			_itemsVisible = 0;
			for (var item:uint = _scrollPos; item < _items.length; ++item)
			{
				var dobj:DisplayObject = _items[item];
				dobj.x = hPos;
				
				hPos = dobj.x + dobj.width;
				if (hPos > _bounds.x)
				{
					break;
				}
				addChildAt(dobj, 0);
				++_itemsVisible;
			}
			if (DEBUG_MODE)
			{
				graphics.clear();
				graphics.lineStyle(1, 0xff0000);
				graphics.drawRect(0, 0, width, height);
			}
			if (_scroll)
			{
				if (!_leftButton)
				{
					_leftButton = GameButton.create("<", true, 9, 1, new Point(0, 36));
					_leftButton.x = -3;
					_leftButton.enabled = false;
					Util.listen(_leftButton, MouseEvent.MOUSE_DOWN, onScrollLeft);
					addChild(_leftButton);
					
					_rightButton = GameButton.create(">", true, 9, 1, new Point(0, 36));
					Util.listen(_rightButton, MouseEvent.MOUSE_DOWN, onScrollRight);
					addChild(_rightButton);
					
					_leftButton.height = height - 10;
					_rightButton.height = _leftButton.height;
					_leftButton.width = 10;
					_rightButton.width = 10;
					
					_rightButton.x = _bounds.x - _rightButton.width + 2;
				}
				if (!_indicators)
				{
					_indicators = new Sprite;
					_indicators.buttonMode = true;
					
					for (var i:int = 0; i <= (_items.length - _itemsVisible); ++i)
					{
						var indicator:Sprite = new Sprite;
						indicator.graphics.lineStyle();
						indicator.graphics.beginFill(0, 0.8);
						indicator.graphics.drawRect(0, 0, 5, 4);
						indicator.graphics.endFill();
						
						indicator.x = i * 7;
						_indicators.addChild(indicator);
					}
					_indicators.x = (this.width - _indicators.width)/2;
					_indicators.y = this.height - 1;

					_indicators.graphics.beginFill(0, 0.05);
					_indicators.graphics.drawRect(0, 0, _indicators.width, _indicators.height);
					_indicators.graphics.endFill();
					
					Util.listen(_indicators, MouseEvent.MOUSE_DOWN, onIndicatorDown);
					addChild(_indicators);
				}
			}
			
			updateScrollButtons();
		}

		private function onIndicatorDown(e:MouseEvent):void
		{
			Util.listen(stage, MouseEvent.MOUSE_MOVE, onIndicatorMove);
			Util.listen(stage, MouseEvent.MOUSE_UP, onIndicatorUp);
			Util.listen(stage, Event.MOUSE_LEAVE, onIndicatorUp);
			
			onIndicatorMove(e);
		}
		private function onIndicatorMove(e:MouseEvent):void
		{
			const ptLocal:Point = _indicators.globalToLocal(stage.localToGlobal(new Point(e.stageX, e.stageY)));
			const pct:Number = ptLocal.x / _indicators.width + 0.02; // on Windows, there's a bit of a weird offset with the hand cursor!? 
			const newScrollPos:int = Math.max(0, Math.min(maxScrollPos, pct * (maxScrollPos + 1)));
			if (_scrollPos != newScrollPos)
			{
				this.scrollPos = newScrollPos;
				
				AssetManager.instance.uiClick();
			}
		}
		private function onIndicatorUp(e:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onIndicatorMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onIndicatorUp);
			stage.removeEventListener(Event.MOUSE_LEAVE, onIndicatorUp);
		}
		public function renderVert():void  // atrocities!
		{
			clear();
			
			var vPos:Number = 4;
			for (var item:uint = _scrollPos; item < _items.length; ++item)
			{
				var dobj:DisplayObject = _items[item];
				dobj.y = vPos;
				
				vPos = dobj.y + dobj.height;
				if (vPos > _bounds.y)
				{
					break;
				}
				addChildAt(dobj, 0);
				++_itemsVisible;
			}
		}

		private function onScrollLeft(e:Event):void
		{
			if (_scrollPos > 0)
			{
				--_scrollPos;
				render();
			}
		}
		private function get maxScrollPos():int
		{
			return _items.length - _itemsVisible;
		}
		private function onScrollRight(e:Event):void
		{
			if (_scrollPos < maxScrollPos)
			{
				++_scrollPos;
				render();
			}
		}
		private function updateScrollButtons():void
		{
			if (_leftButton)
			{
				var canScroll:Boolean = (_scrollPos > 0);
				_leftButton.enabled = canScroll;
				_leftButton.alpha = canScroll ? 1 : 0.1;
				
				canScroll = _scrollPos < maxScrollPos;
				_rightButton.enabled = canScroll;
				_rightButton.alpha = canScroll ? 1 : 0.1;
			}
			if (_indicators)
			{
				for (var i:int = 0; i <= (_items.length - _itemsVisible); ++i)
				{
					var indicator:DisplayObject = _indicators.getChildAt(i);
					indicator.alpha = (i == _scrollPos) ? 1 : 0.25;
				}
			}
		}
	}
}