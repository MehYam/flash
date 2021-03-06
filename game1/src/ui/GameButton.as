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
	
	import karnold.ui.ShadowTextField;
	import karnold.utils.Util;
	
	// There are about a million better ways to do this - resorting to this	because I'm running out of
	// time and can't get 9 sliced Buttons to work from CS3.
	public class GameButton extends Sprite
	{
		private var _up:DisplayObject;
		private var _over:DisplayObject;
		private var _down:DisplayObject;
		private var _text:*;  // sucks, but because it could be a TextField or ShadowTextField
		private var _offset:Point;

		public static function create(label:String, raised:Boolean = true, size:Number = 24, distance:Number = 2, textOffset:Point = null):GameButton
		{
			var tf:TextFormat = AssetManager.instance.createFont(AssetManager.FONT_COMPUTER, size); 
			tf.align = TextFormatAlign.CENTER;

			var text:ShadowTextField = new ShadowTextField(0xffffff, 0x000000, distance);
			AssetManager.instance.assignTextFormat(text, tf);
			text.text = label;

			return new GameButton(text, AssetManager.instance.buttonFace(raised), AssetManager.instance.buttonFaceOver(raised), AssetManager.instance.buttonFaceDown(), textOffset);
		}
		public function GameButton(text:DisplayObject, up:DisplayObject, over:DisplayObject, down:DisplayObject, textOffset:Point = null)
		{
			super();
			
			this.mouseChildren = false;
			this.buttonMode = true;
			this.useHandCursor = true;
			this.tabEnabled = false;
			
			Util.listen(this, MouseEvent.ROLL_OUT, onRollOut);
			Util.listen(this, MouseEvent.ROLL_OVER, onRollOver);
			Util.listen(this, MouseEvent.MOUSE_DOWN, onMouseDown);
			
			_up = up;
			_over = over;
			_down = down;
			_text = text;

			_offset = textOffset || TEXTOFFSET;
			_text.x = _offset.x;
			_text.y = _offset.y;
			_text.mouseEnabled = false;

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
		public function set enabled(b:Boolean):void
		{
			this.alpha = b ? 1 : 0.5;
			mouseChildren = b;
			mouseEnabled = b;
		}
		
		private static const TEXTOFFSET:Point = new Point(7, 2);
		private static const TEXTOFFSET_DOWN:Point = new Point(2, 2);
		private function setFace(sprite:DisplayObject):void
		{
			removeChildAt(0);
			addChildAt(sprite, 0);

			_text.x = _offset.x;
			_text.y = _offset.y;
			if (sprite == _down)
			{
				_text.x += TEXTOFFSET_DOWN.x;
				_text.y += TEXTOFFSET_DOWN.y;
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
			
			AssetManager.instance.uiClick();
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
	}
}