package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	final public class ToolTipMgr
	{
		static public const DEFAULT_DELAY:uint = 400;
		static public const DEFAULT_OFFSETX:Number = 5;
		static public const DEFAULT_OFFSETY:Number = -5;
		
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
			const stage:Stage = _lastMousedOverItem.stage;
			if (entry && stage)
			{
				var dobj:DisplayObject = _tooltip.displayObject;

				if (!dobj.parent)
				{	
					_tooltip.text = entry.text;
				}
				dobj.x = Math.min(Math.max(0, x + entry.offsetX), stage.stageWidth - dobj.width);
				dobj.y = Math.min(Math.max(0, y - dobj.height + entry.offsetY), stage.stageHeight - dobj.height);

				if (!dobj.parent)
				{	
					_tooltip.text = entry.text;
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
		
		public function addToolTip(target:DisplayObject, 
								   text:String, 
								   delay:int = DEFAULT_DELAY, 
								   offsetX:Number = DEFAULT_OFFSETX, 
								   offsetY:Number = DEFAULT_OFFSETY):void
		{
			if (target != null)
			{						
				this._hosts[target] = new ToolTipEntry(text, delay, offsetX, offsetY); 
				
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
//			Util.ASSERT(evt.target == _lastMousedOverItem);
			_lastMouseOverSpot.x = evt.stageX;
			_lastMouseOverSpot.y = evt.stageY;
			if (_tooltip.displayObject.parent)
			{
				show(_lastMouseOverSpot.x, _lastMouseOverSpot.y);
			}
		}
		private function onMouseOut(evt:MouseEvent):void
		{
			if (evt.relatedObject != _tooltip.displayObject)
			{
				_timer.stop();
				hide();
				
				IEventDispatcher(evt.currentTarget).removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
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
	private var _offsetX:Number;
	private var _offsetY:Number;
	public function ToolTipEntry(text:String, delay:int, offsetX:Number, offsetY:Number):void
	{
		_text = text;
		_delay = delay;
		_offsetX = offsetX;
		_offsetY = offsetY;
	}
	public function get text():String
	{
		return _text;
	}
	public function get delay():int
	{
		return _delay;
	}
	public function get offsetX():Number
	{
		return _offsetX;
	}
	public function get offsetY():Number
	{
		return _offsetY;
	}
};

final internal class SINGLETON { } 