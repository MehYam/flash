package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	final public class ToolTipMgr
	{
		public function ToolTipMgr(s:SINGLETON)	{if (!s) throw "don't";}
		
		static private var s_instance:ToolTipMgr;
		static public function get instance():ToolTipMgr
		{
			if (!s_instance)
			{
				s_instance = new ToolTipMgr(new SINGLETON);
			}
			return s_instance;
		}

		private var _tooltip:IToolTip;
		public function set tooltip(tooltipDisplayObject:IToolTip):void
		{
			_tooltip = tooltipDisplayObject;
		}
		private var _hosts:Object = new Dictionary(true);
		private var _lastMousedOverItem:DisplayObject;  // could arguably use a weak reference here, but this gets reset so often it probably doesn't matter
		private function show(x:Number, y:Number):void
		{
			const entry:ToolTipEntry = _hosts[_lastMousedOverItem];
			if (entry && _lastMousedOverItem.stage)
			{
				var dobj:DisplayObject = _tooltip.displayObject;
				dobj.x = x + 3;
				dobj.y = y - dobj.height - 3;

				if (!dobj.parent)
				{	
					_lastMousedOverItem.stage.addChild(dobj);
				}
			}				
		}
		private function hide():void
		{
			var dobj:DisplayObject = _tooltip.displayObject;
			if (dobj.parent)
			{
				dobj.parent.removeChild(dobj);
			}
		}
		
		public function addToolTip(target:DisplayObject, text:String, delay:int = 400):void
		{
			if (target != null)
			{						
				this._hosts[target] = new ToolTipEntry(text, delay); 
				
				Util.listen(target, MouseEvent.MOUSE_OVER, onMouseOver);				
				Util.listen(target, MouseEvent.MOUSE_OUT, onMouseOut);			
				
				// if the tooltip's already open, update its contents immediately
				if (this._lastMousedOverItem == target)
				{
					_tooltip.text = text;
				}
			}
		}
		
		public function removeToolTip(target:DisplayObject):void
		{			
			if (this._hosts[target])
			{
				target.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				target.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				delete this._hosts[target];
			}
		}
	
		private var _lastMouseOverSpot:Point = new Point;
		private var _timer:FrameTimer = new FrameTimer(onTimer);
		private function onMouseOver(me:MouseEvent):void
		{
			const entry:ToolTipEntry = this._hosts[me.currentTarget];
			if (entry)
			{
				_lastMousedOverItem = DisplayObject(me.currentTarget);
				_lastMouseOverSpot.x = me.stageX;
				_lastMouseOverSpot.y = me.stageY;
				
				_timer.stop();
				_timer.start(entry.delay, 1);
				
				Util.listen(_lastMousedOverItem, MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		private function onMouseMove(evt:MouseEvent):void
		{
			Util.ASSERT(evt.target == _lastMousedOverItem);

			_lastMouseOverSpot.x = evt.stageX;
			_lastMouseOverSpot.y = evt.stageY;
			if (_tooltip.displayObject.parent)
			{
				show(_lastMouseOverSpot.x, _lastMouseOverSpot.y);
			}
		}
		private function onMouseOut(evt:MouseEvent):void
		{
			_timer.stop();
			hide();
			
			IEventDispatcher(evt.currentTarget).removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onTimer():void
		{
			_timer.stop();
			if (_lastMousedOverItem)
			{
				const entry:ToolTipEntry = this._hosts[this._lastMousedOverItem];
				if (entry && entry.text != null)
				{			
					show(_lastMouseOverSpot.x, _lastMouseOverSpot.y);			
				}
			}
		}
	}
}

final class ToolTipEntry
{
	private var _text:String;
	private var _delay:int;
	public function ToolTipEntry(text:String, delay:int):void
	{
		_text = text;
		_delay = delay;
	}
	public function get text():String
	{
		return _text;
	}
	public function get delay():int
	{
		return _delay;
	}
};

final internal class SINGLETON { } 