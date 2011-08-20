package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	public class Util
	{
		static public function tr(str:String):void
		{
			trace("kai:", str);
		}
		
		static public function ASSERT(b:Boolean, msg:String = ""):void
		{
			if (!b)
			{
				const fullMsg:String =  "ASSERTION: " + msg;
				tr(fullMsg);
				
				throw fullMsg;   
			}
		}
		static public function clone(source:Object):*
		{
			var serializer:ByteArray = new ByteArray();
			serializer.writeObject(source);
			serializer.position = 0;
			return serializer.readObject();
		}
		// addresses the fact that weakReference should be *true* by default
		static public function listen(source:EventDispatcher, type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			source.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		static public function removeAllChildren(parent:DisplayObjectContainer):void
		{
			while(parent.numChildren)
			{
				parent.removeChildAt(parent.numChildren - 1);
			}
		}       
		static public function setPoint(dest:Point, src:Point):void
		{
			dest.x = src.x;
			dest.y = src.y;
		}
		static public function setPointXY(dest:Point, x:Number, y:Number):void
		{
			dest.x = x;
			dest.y = y;
		}
		static public function centerChild(child:DisplayObject, parent:DisplayObject):void
		{
			child.x = parent.x + (parent.width - child.width) / 2;
			child.y = parent.y + (parent.height - child.height) / 2;
		}
		static public function centerChildInRect(child:DisplayObject, rect:Rectangle):void
		{
			child.x = rect.x + (rect.width - child.width) / 2;
			child.y = rect.y + (rect.height - child.height) / 2;
		}
		static public function centerChildAtPoint(child:DisplayObject, point:Point):void
		{
			child.x = point.x - child.width/2;
			child.y = point.y - child.height/2;
		}
//		static public function centerNonOriginedChildInRect(child:DisplayObject, rect:Rectangle):void
//		{
//			const bounds:Rectangle = child.getBounds(child);
//		}
		static public function mapChildrenByName(parent:DisplayObjectContainer, map:Object):void
		{
			const children:uint = parent.numChildren;
			for (var i:uint = 0; i < children; ++i)
			{
				var child:DisplayObject = parent.getChildAt(i);
				
				if (child.name && child.name.indexOf("instance") == -1)
				{
					map[child.name] = child;
				}
				if (child is DisplayObjectContainer)
				{
					mapChildrenByName(DisplayObjectContainer(child), map);
				}
			}
		}
		
		public static function removeThyself(self:DisplayObject):void
		{
			self.parent.removeChild(self);
		}
		
		static public function tint(rgbFrom:uint, rgbTo:uint, pct:Number):uint
		{
			const rFrom:uint = (0xff0000 & rgbFrom) >> 16;
			const gFrom:uint = (0x00ff00 & rgbFrom) >> 8;
			const bFrom:uint = (0x0000ff & rgbFrom);
			const rTo:uint = (0xff0000 & rgbTo) >> 16;
			const gTo:uint = (0x00ff00 & rgbTo) >> 8;
			const bTo:uint = (0x0000ff & rgbTo);
			const rResult:uint = rFrom + pct*(rTo - rFrom);
			const gResult:uint = gFrom + pct*(gTo - gFrom);
			const bResult:uint = bFrom + pct*(bTo - bFrom);
			return (rResult << 16) | (gResult << 8) | bResult;  
		}
		static public function drawOutline(target:Sprite, color:uint = 0xff00ff):void
		{
			target.graphics.lineStyle(1, color);
			target.graphics.drawRect(0, 0, target.width, target.height);
		}
		static public function drawChildOutline(child:DisplayObject, parent:Sprite, color:uint = 0xff00ff):void
		{
			parent.graphics.lineStyle(1, color);
			parent.graphics.drawRect(child.x, child.y, child.width, child.height);
		}
		static public function addText(parent:DisplayObjectContainer, text:String, color:uint = 0):TextField
		{
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.RIGHT;
			tf.text = text;
			tf.textColor = color;
			
			centerChild(tf, parent);			
			parent.addChild(tf);
			return tf;
		} 

		private static function trIndented(str:String, level:int):void {
			
			var out:String = "";
			for (var i:int = 0; i < level; ++i)
			{
				out += " ";
			}
			trace(out + str);
		}
		
		public static function toPathString(dobj:DisplayObject):String
		{
			var history:Array = [];
			
			history.push(dobj);
			
			var parent:DisplayObject = dobj.parent;
			while(parent != null)
			{
				history.push(parent);
				parent = parent.parent;
			}
			
			var path:String = "";
			
			for(var index:int = 0; index < history.length; ++index)
			{
				var historyObj:DisplayObject = history[index];
				
				if(path.length > 0)
				{
					path += " -> ";
				}
				
				var name:String = historyObj.name || "null";
				
				if(name.indexOf("instance") == 0)
				{
					name = "instance";
				}
				
				path += name + " " + getQualifiedClassName(historyObj); 
			}
			
			return path;
		}
		
		// Recursive.  Returns number of objects.
		public static function traceDisplayList(obj:DisplayObject, level:int = 0, visibilityReport:Object = null):uint
		{
			if (!obj)
			{
				trIndented("<null/>", level);				
			}
			var type:String = (String(obj)).replace("]", "").replace("[object ", "").replace(" ", "");
			if (type.indexOf(".") >= 0)
			{
				type = type.split(".").pop();
			}
			var tag:String = "<" + type;
			
			if (obj.name && obj.name.length && obj.name.search("instance") != 0)
			{
				tag += " name='" + obj.name + "'";
			}
			
			if (obj is InteractiveObject)
			{
				tag += " mouseEnabled='" + InteractiveObject(obj).mouseEnabled + "'";
				
				if (obj.hasEventListener(MouseEvent.CLICK) ||
					obj.hasEventListener(MouseEvent.MOUSE_DOWN) ||
					obj.hasEventListener(MouseEvent.MOUSE_MOVE) ||
					obj.hasEventListener(MouseEvent.ROLL_OVER) ||
					obj.hasEventListener(MouseEvent.ROLL_OUT) ||
					obj.hasEventListener(MouseEvent.MOUSE_OVER) ||
					obj.hasEventListener(MouseEvent.MOUSE_OUT))
				{
					tag += " hasMouseListener='true'";
				}
			}
			
			if (obj is TextField)
			{
				tag += " text='" + TextField(obj).text + "'";
			}
			
			if (visibilityReport)
			{
				++visibilityReport.visTotal;
			}
			
			if (!obj.visible)
			{
				tag += " visible='false'";
				if (visibilityReport)
				{
					++visibilityReport.visDepth;
				}
				if (!visibilityReport)
				{
					visibilityReport =
						{
							visDepth: 1,
							visTotal: 1
						};
				}
			}
			
			var objAsContainer:Object = obj as DisplayObjectContainer;
			if (objAsContainer)
			{
				var flexContainer:Object;
				try { flexContainer = obj["rawChildren"]; } catch (e:Error) {}				
				if (flexContainer)
				{
					objAsContainer = flexContainer;
				}
			}

			var count:int = 1;
			const numChildren:int = objAsContainer ? objAsContainer.numChildren : 0;
			if (numChildren)
			{
				tag += ">";
				trIndented(tag, level);
				
				for (var i:int; i < numChildren; ++i)
				{
					var child:DisplayObject = objAsContainer.getChildAt(i);
					// It's actually possible, depending on where we are in a frame, to have numChildren be larger
					// than the number of children we actually have access to, hence the check:
					if (child)
					{
						count += traceDisplayList(child, level+1, visibilityReport);
					}
				}
				trIndented("</" + type + ">", level);
			}
			else
			{
				tag += "/>";
				trIndented(tag, level);
			}
			if (!obj.visible)
			{
				if (!--visibilityReport.visDepth)
				{
					trIndented("<!-- vis report: " + visibilityReport.visTotal + " invisible objects -->", level);
				}
			}
			return count;
		}
		
		public static function bringToFront(dobj:DisplayObject):void
		{
			if (dobj.parent)
			{
				dobj.parent.setChildIndex(dobj, dobj.parent.numChildren-1);
			}
		}

		//
		// Does a depth-first traversal of the display hierarchy, calling the onObject method of the
		// functor you pass in.  We're using a functor instead of Function to avoid closures.  Sample
		// usage:
		//
		// var functor:Object = { onObject: myCallback, foo:  "whatever" }
		// ...
		// private static var myCallback(functor:Object, parent:DisplayObject, child:DisplayObject):Boolean 
		// { 
		//   ...
		//     return true;  // or return false if you want to halt the recursion
		// }
		//
		public static function recurse(functor:Object, obj:DisplayObject):void
		{
			recurseImpl(functor, obj ? obj.parent : null, obj);
		}
		private static function recurseImpl(functor:Object, parent:DisplayObject, child:DisplayObject):void
		{
			if (functor.excludes && functor.excludes[child])
			{
				return; // this child's excluded
			}
			// prevent both parent and child from being null
			if ((parent || child) && functor.onObject(functor, parent, child))  // call the functor.  It can halt recursion by returning false
			{
				var container:DisplayObjectContainer = child as DisplayObjectContainer;
				if (container)
				{
					var rawChildren:Object;
// Turns out this generates a lot of String objects!  Unnecessary if we're not in Flex
//					try { rawChildren = container["rawChildren"]; } catch (e:Error) {}
					
					recurseImplLooper(rawChildren || container, functor, child);
				}				
			}
		}
		private static function recurseImplLooper(container:Object, functor:Object, child:DisplayObject):void
		{
			var childrenCount:Number = container.numChildren;
			for (var i:int = 0;  i < childrenCount; ++i)
			{
				var grandChild:DisplayObject = container.getChildAt(i);
				recurseImpl(functor, child, grandChild);
			}			
		}
		public static function stopAllMovieClips(mc:DisplayObject) : void
		{
			var functor:Object = {onObject: stopMovieClipsFn};
			recurse(functor, mc);
		}
		private static function stopMovieClipsFn(functor:Object, parent:DisplayObject, child:DisplayObject):Boolean
		{
			if (child is MovieClip)
			{
				MovieClip(child).gotoAndStop(0);
			}
			return true;
		}
		public static function startAllMovieClips(mc:DisplayObject) : void
		{
			var functor:Object = {onObject: startMovieClipsFn};
			recurse(functor, mc);
		}
		private static function startMovieClipsFn(functor:Object, parent:DisplayObject, child:DisplayObject):Boolean
		{
			if (child is MovieClip)
			{
				MovieClip(child).play();
			}
			return true;
		}

		public function Util(hide:CONSTRUCTOR_HIDER) {}
	}
}
internal class CONSTRUCTOR_HIDER {}