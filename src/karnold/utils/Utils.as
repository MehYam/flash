package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	
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
		public function Utils(hide:CONSTRUCTOR_HIDER) {}
	}
}
internal class CONSTRUCTOR_HIDER {}