package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	public class Utils
	{
		static public function tr(str:String):void
		{
			trace("kai:", str);
		}
		
		//
		// Like the Windows RGB macro
		static public function RGB(red:uint, green:uint, blue:uint):uint
		{
			return (red << 16) | (green << 8) | blue;
		}
		static public function random(min:uint, numValues:uint):uint
		{
			return Math.floor(Math.random()*numValues) + min;
		}
		static public function assert(b:Boolean, msg:String = ""):void
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
		
		public static function traceDisplayList(obj:DisplayObject, level:int = 0, visibilityReport:Object = null):void
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
			
			const numChildren:int = objAsContainer ? objAsContainer.numChildren : 0;
			if (numChildren)
			{
				tag += ">";
				trIndented(tag, level);
				
				for (var i:int; i < numChildren; ++i)
				{
					var child:DisplayObject = objAsContainer.getChildAt(i);
					traceDisplayList(child, level+1, visibilityReport);
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
		}
		
		public static function bringToFront(dobj:DisplayObject):void
		{
			if (dobj.parent)
			{
				dobj.parent.setChildIndex(dobj, dobj.parent.numChildren-1);
			}
		}
		
		public function Utils(hide:CONSTRUCTOR_HIDER) {}
	}
}
internal class CONSTRUCTOR_HIDER {}