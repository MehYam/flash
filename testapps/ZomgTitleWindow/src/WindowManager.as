package
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class WindowManager extends EventDispatcher
	{
		public function WindowManager()
		{
		}

		static private const s_instance:WindowManager = new WindowManager;
		static public function get instance():WindowManager
		{
			return s_instance;
		}

		static public function toSnapEvent(root:DisplayObject, source:MouseEvent, event:String):Event
		{
			var toLocal:Point = new Point(source.localX, source.localY);
			toLocal = root.globalToLocal(DisplayObject(source.target).localToGlobal(toLocal));

			var evt:WindowManagerEvent = new WindowManagerEvent(event);
			evt.localX = toLocal.x;
			evt.localY = toLocal.y;
			return evt;
		}
		
		private var _objs:Dictionary = new Dictionary(true);		
		public function add(obj:DisplayObject):void  
		{
			if (!_objs[obj])
			{
				_objs[obj] = new DragInfo;
				
				obj.addEventListener(WindowManagerEvent.DRAG_START, onDragStart, false, 0, true);
				obj.addEventListener(WindowManagerEvent.RESIZE_START, onDragStart, false, 0, true);
				obj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
	
				// [kja] we never unhook these event listeners so that show/hides of the window automatically re-add it to our lookup.
				// This is okay, the listeners are weak, as is our reference to the object 
				obj.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);		
				obj.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			}		
			DragInfo(_objs[obj]).active = true;
		}
		public function remove(obj:DisplayObject):void
		{
			if (_objs[obj])
			{
				DragInfo(_objs[obj]).active = false;

//				obj.removeEventListener(WindowManagerEvent.DRAG_START, onDragStart);
//				obj.removeEventListener(WindowManagerEvent.RESIZE_START, onDragStart);
//				obj.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		private function onAddedToStage(e:Event):void
		{
			add(DisplayObject(e.target));
		}
		private function onRemovedFromStage(e:Event):void
		{
			remove(DisplayObject(e.target));		
		}
		private function addDragListeners(stage:Stage, onMouseMove:Function, onMouseUp:Function):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp, false, 0, true);
		}
		private function removeDragListeners(stage:Stage, onMouseMove:Function, onMouseUp:Function):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
		}
		private var _current:DisplayObject;
		private function onDragStart(e:WindowManagerEvent):void
		{
			_current = DisplayObject(e.target);
			_current.alpha = .66;

			if (!_objs[_current])
			{
				throw "Receiving drag event for unknown snappee";
			}
			
			var di:DragInfo = DragInfo(_objs[_current]);
			di.offset = _current.globalToLocal(new Point(e.stageX, e.stageY));

			if (e.type == WindowManagerEvent.DRAG_START)
			{
				addDragListeners(_current.stage, onDrag, onDragEnd);
			}
			else
			{
				di.startWidth = _current.width;
				di.startHeight = _current.height;
				addDragListeners(_current.stage, onResize, onResizeEnd);
			}
		}
		private function onMouseDown(e:MouseEvent):void
		{
			var target:DisplayObject = DisplayObject(e.currentTarget); 
			target.parent.setChildIndex(target, target.parent.numChildren - 1);
		}
		private static function overlapsHorz(child1:DisplayObject, child2:DisplayObject):Boolean
		{
			return (child1.x >= child2.x && child1.x <= (child2.x + child2.width));
		}		
		private static function overlapsVert(child1:DisplayObject, child2:DisplayObject):Boolean
		{
			return (child1.y >= child2.y && child1.y <= (child2.y + child2.height));
		}
		private static const SNAP_THRESHHOLD:Number = 12;
		private static function willSnap(pos1:Number, pos2:Number):Boolean
		{
			return Math.abs(pos1 - pos2) <= SNAP_THRESHHOLD;
		}
		private static function findEdgeX(objects:Dictionary, obj:DisplayObject):Number
		{
			var retval:Number = NaN;

			// find a sibling edge to snap to
			const currentRight:Number = obj.x + obj.width;
			for (var sobj:Object in objects)
			{
				var sibling:DisplayObject = DisplayObject(sobj);
				if (sibling != obj && DragInfo(objects[sobj]).active && (overlapsVert(obj, sibling) || overlapsVert(sibling, obj)))
				{
					var siblingRight:Number = sibling.x + sibling.width;
					if (willSnap(obj.x, siblingRight))  // snap to a right edge
					{
						retval = siblingRight;
						break;
					}
					else if (willSnap(obj.x, sibling.x)) // snap to a left edge
					{
						retval = sibling.x;
						break;
					}
					// snap our right edge
					else if (willSnap(currentRight, sibling.x)) // snap our right edge to a left edge
					{
						retval = sibling.x - obj.width;
						break;
					}
					else if (willSnap(currentRight, siblingRight))
					{
						retval = siblingRight - obj.width;
						break; 
					}
				}
			}
			// last chance: find a screen edge to snap to
			if (isNaN(retval))
			{
				if (willSnap(obj.x, 0))
				{
					retval = 0;
				}
				else if (willSnap(currentRight, obj.parent.width))
				{
					retval = obj.parent.width - obj.width;
				}
			}
			return retval;
		}
		private static function findEdgeY(objects:Dictionary, obj:DisplayObject):Number  //[kja] a copy/paste of findEdgeX.  If you want to consolidate 'em nicely, show me how you did it 
		{
			var retval:Number = NaN;

			// find a sibling edge to snap to
			const currentBottom:Number = obj.y + obj.height;
			for (var sobj:Object in objects)
			{
				var sibling:DisplayObject = DisplayObject(sobj);
				if (sibling != obj && DragInfo(objects[sobj]).active && (overlapsHorz(obj, sibling) || overlapsHorz(sibling, obj)))
				{
					var siblingBottom:Number = sibling.y + sibling.height;
					if (willSnap(obj.y, siblingBottom)) // snap to a bottom edge
					{
						retval = siblingBottom;
						break;
					}
					else if (willSnap(obj.y, sibling.y)) // snap to a top edge
					{
						retval = sibling.y;
						break;
					}
					else if (willSnap(currentBottom, sibling.y)) // snap our bottom to a top edge.  That's what she said
					{
						retval = sibling.y - obj.height;
						break; 
					}
					else if (willSnap(currentBottom, siblingBottom))
					{
						retval = siblingBottom - obj.height;
						break; 
					}
				}
			}
			// find a screen edge to snap to
			if (isNaN(retval))
			{
				if (willSnap(obj.y, 0))
				{
					retval = 0;
				}
				else if (willSnap(currentBottom, obj.parent.height))
				{
					retval = obj.parent.height - obj.height;
				}
			}
			return retval;
		}
		private function onDrag(e:MouseEvent):void
		{
			var di:DragInfo = _objs[_current];
			const enableLock:Boolean = !e.ctrlKey;	
			const newUpperLeft:Point = _current.parent.globalToLocal(new Point(e.stageX, e.stageY)).subtract(di.offset);

			// NOTE: right now all snappee's are expected to share the same parent;  this doesn't necessarily
			// need to stay true, we can allow for disparate tree level snapping simply by translating everything
			// to stage coordinates
			var sibling:DisplayObject;
			var obj:Object;

			// Snapping along the horizontal axis
			if (isNaN(di.lockedX) && enableLock)
			{
				di.lockedX = findEdgeX(_objs, _current);
			}
			else
			{
				// already snapped, see if we should unsnap
				if (!willSnap(di.lockedX, newUpperLeft.x))
				{
					di.lockedX = NaN;
				}
			}
			_current.x = isNaN(di.lockedX) ? newUpperLeft.x : di.lockedX;
	
			// snapping along the vertical axis
			if (isNaN(di.lockedY) && enableLock)
			{
				di.lockedY = findEdgeY(_objs, _current);
			}
			else
			{
				// already snapped, see if we should unsnap
				if (!willSnap(di.lockedY, newUpperLeft.y))
				{
					di.lockedY = NaN;
				}
			}
			_current.y = isNaN(di.lockedY) ? newUpperLeft.y: di.lockedY;
		}
		private function onDragEnd(e:Event):void
		{
			var evt:WindowManagerEvent = new WindowManagerEvent(WindowManagerEvent.SNAP_DONE, _current);

			DragInfo(_objs[_current]).clear();
			_current.alpha = 1;
			_current = null;

			removeDragListeners(DisplayObject(e.target).stage, onDrag, onDragEnd);

			dispatchEvent(evt);
		}
		
		private static function findEdgeX_forResizing(objects:Dictionary, obj:DisplayObject, refX:Number):Number //KAI: lame
		{
			var retval:Number = NaN;

			// find a sibling edge to snap to
			for (var sobj:Object in objects)
			{
				var sibling:DisplayObject = DisplayObject(sobj);
				if (sibling != obj && (overlapsVert(obj, sibling) || overlapsVert(sibling, obj)))
				{
					var siblingRight:Number = sibling.x + sibling.width;
					if (willSnap(refX, siblingRight))  // snap to a right edge
					{
						retval = siblingRight;
						break;
					}
					else if (willSnap(refX, sibling.x)) // snap to a left edge
					{
						retval = sibling.x;
						break;
					}
				}
			}
			// last chance: find a screen edge to snap to
			if (isNaN(retval))
			{
				if (willSnap(refX, obj.parent.width))
				{
					retval = obj.parent.width;
				}
			}
			return retval;
		}
		private static function findEdgeY_forResizing(objects:Dictionary, obj:DisplayObject, refY:Number):Number //KAI: lame
		{
			var retval:Number = NaN;

			// find a sibling edge to snap to
			for (var sobj:Object in objects)
			{
				var sibling:DisplayObject = DisplayObject(sobj);
				if (sibling != obj && (overlapsHorz(obj, sibling) || overlapsHorz(sibling, obj)))
				{
					var siblingBottom:Number = sibling.y + sibling.height;
					if (willSnap(refY, siblingBottom))
					{
						retval = siblingBottom;
						break;
					}
					else if (willSnap(refY, sibling.y))
					{
						retval = sibling.y;
						break;
					}
				}
			}
			// last chance: find a screen edge to snap to
			if (isNaN(retval))
			{
				if (willSnap(refY, obj.parent.height))
				{
					retval = obj.parent.height;
				}
			}
			return retval;
		}
		private function onResize(e:MouseEvent):void
		{
			var di:DragInfo = _objs[_current];
			const enableLock:Boolean = !e.ctrlKey;	

			const currentPoint:Point = _current.globalToLocal(new Point(e.stageX, e.stageY));
			const distanceFromStart:Point = currentPoint.subtract(di.offset);

			const newRightEdge:Number = _current.x + di.startWidth + distanceFromStart.x;
			if (isNaN(di.lockedX) && enableLock)
			{
				di.lockedX = findEdgeX_forResizing(_objs, _current, newRightEdge);
			}
			else
			{
				// already snapped, see if we should unsnap
				if (!willSnap(di.lockedX, newRightEdge))
				{
					di.lockedX = NaN;
				}
			}
			_current.width = Math.max(100, (isNaN(di.lockedX) ? newRightEdge : di.lockedX) - _current.x);

			const newBottomEdge:Number = _current.y + di.startHeight + distanceFromStart.y;
			if (isNaN(di.lockedY) && enableLock)
			{
				di.lockedY = findEdgeY_forResizing(_objs, _current, newBottomEdge);
			}
			else
			{
				// already snapped, see if we should unsnap
				if (!willSnap(di.lockedY, newBottomEdge))
				{
					di.lockedY = NaN;
				}
			}
			
			_current.height = Math.max(100, (isNaN(di.lockedY) ? newBottomEdge : di.lockedY) - _current.y);
		}
		private function onResizeEnd(e:Event):void
		{
			DragInfo(_objs[_current]).clear();
			_current.alpha = 1;
			_current = null;

			removeDragListeners(e.target.stage, onResize, onResizeEnd);
		}
		
		public function findOverlapped(obj:DisplayObject):DisplayObject //KAI: weak
		{
			for (var sobj:Object in _objs)
			{
				var sibling:DisplayObject = DisplayObject(sobj);
				if (sibling != obj && sibling.x == obj.x && sibling.y == obj.y)
				{
					return sibling;
				}
			}
			return null;
		}
	}
}
	import flash.geom.Point;
	

class DragInfo
{
	public var offset:Point;
	public var lockedY:Number;
	public var lockedX:Number;

	public var startWidth:Number; //KAI: lame
	public var startHeight:Number; //KAI: lame
	public var active:Boolean = true;
	public function clear():void
	{
		offset = null;
		lockedY = NaN;
		lockedX = NaN;
		startWidth = NaN;
		startHeight = NaN;
	}
};