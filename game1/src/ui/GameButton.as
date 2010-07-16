package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import karnold.utils.Util;
	
	// There are about a million better ways to do this - resorting to this	because I'm running out of
	// time and can't get 9 sliced Buttons to work from CS3.
	public class GameButton extends Sprite
	{
		private var _up:DisplayObject;
		private var _over:DisplayObject;
		private var _down:DisplayObject;
		private var _text:*;  // sucks, but because it could be a TextField or ShadowTextField
		
		public static function create(label:String):GameButton
		{
			var tf:TextFormat = new TextFormat("Computerfont", 24);
			tf.align = TextFormatAlign.CENTER;

			var text:ShadowTextField = new ShadowTextField(tf);
			text.text = label;

			return new GameButton(text, AssetManager.instance.buttonFace(), AssetManager.instance.buttonFaceOver(), AssetManager.instance.buttonFaceDown());
		}
		public function GameButton(text:DisplayObject, up:DisplayObject, over:DisplayObject, down:DisplayObject)
		{
			super();
			
			this.mouseChildren = false;
			this.buttonMode = true;
			this.useHandCursor = true;
			
			Util.listen(this, MouseEvent.ROLL_OUT, onRollOut);
			Util.listen(this, MouseEvent.ROLL_OVER, onRollOver);
			Util.listen(this, MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_up = up;
			_over = over;
			_down = down;
			_text = text;
			
			_text.x = TEXTOFFSET.x;
			_text.y = TEXTOFFSET.y;

			width = 2*_text.x + _text.width;
			height = 2*_text.y + _text.height - 3;

			addChild(_up);
			addChild(_text);
		}
		public override function set height(value:Number):void
		{
			_up.height = value;
			_down.height = value;
			_over.height = value;
		}
		public override function set width(value:Number):void
		{
			_up.width = value;
			_down.width = value;
			_over.width = value;
		}
		public function set label(text:String):void
		{
			_text.text = text;
		}
		
		private static const TEXTOFFSET:Point = new Point(7, 2);
		private static const TEXTOFFSET_DOWN:Point = new Point(TEXTOFFSET.x + 4, TEXTOFFSET.y + 4);
		private function setFace(sprite:DisplayObject):void
		{
			removeChildAt(0);
			addChildAt(sprite, 0);

			if (sprite == _down)
			{
				_text.x = TEXTOFFSET_DOWN.x;
				_text.y = TEXTOFFSET_DOWN.y;
			}
			else
			{
				_text.x = TEXTOFFSET.x;
				_text.y = TEXTOFFSET.y;
			}
		}
		
		private var _mouseDown:Boolean = false;
		private var _mouseOver:Boolean = false;       
		private function onMouseDown(e:Event):void
		{
			_mouseDown = true;
			setFace(_down);
			
			Util.listen(stage, MouseEvent.MOUSE_UP, onMouseUp);
			Util.listen(stage, Event.MOUSE_LEAVE, onMouseUp);
			Util.listen(this, MouseEvent.CLICK, onClick);
		}
		private function onMouseUp(e:Event):void
		{
			_mouseDown = false;
			setFace(_mouseOver ? _over : _up);
		}
		private function onRollOver(e:Event):void
		{
			_mouseOver = true;
			setFace(_mouseDown ? _down : _over);
		}
		private function onRollOut(e:Event):void
		{
			_mouseOver = false;
			setFace(_up);
		}
		private function onClick(e:Event):void
		{
//KAI: play a sound
		}
	}
}