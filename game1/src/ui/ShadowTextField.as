package ui
{
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class ShadowTextField extends Sprite
	{
		private var _top:TextField;
		private var _bottom:TextField;
		public function ShadowTextField(tf:TextFormat, textColor:uint = 0xffffff, shadowColor:uint = 0x000000, distance:Number = 2)
		{
			_top = new TextField();
			_top.selectable = false;
			_top.defaultTextFormat = tf;
			_top.autoSize = TextFieldAutoSize.LEFT;
			_top.textColor = textColor;
			
			_bottom = new TextField();
			_bottom.selectable = false;
			_bottom.defaultTextFormat = tf;
			_bottom.autoSize = TextFieldAutoSize.LEFT;
			_bottom.x = distance;
			_bottom.y = distance;
			_bottom.textColor = shadowColor;
			
			addChild(_bottom);
			addChild(_top);
		}

		public function set fgColor(color:uint):void
		{
			_top.textColor = color;
		}
		public function set bgColor(color:uint):void
		{
			_bottom.textColor = color;
		}
		public function set text(str:String):void
		{
			_top.text = str;
			_bottom.text = str;
		}
	}
}