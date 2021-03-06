package karnold.ui
{
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	// really no reason to use this in favor of a dropshadow other than a negligable performance difference
	public class ShadowTextField extends Sprite
	{
		private var _top:TextField;
		private var _bottom:TextField;
		public function ShadowTextField(textColor:uint = 0xffffff, shadowColor:uint = 0x000000, distance:Number = 2)
		{
			_top = new TextField();
			_top.selectable = false;
			_top.autoSize = TextFieldAutoSize.LEFT;
			_top.textColor = textColor;
			
			_bottom = new TextField();
			_bottom.selectable = false;
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
		public function set autoSize(sizeType:String):void
		{
			_top.autoSize = sizeType;
			_bottom.autoSize = sizeType;
		}
		public function set wordWrap(w:Boolean):void
		{
			_top.wordWrap = w;
			_bottom.wordWrap = w;
		}
		public function set defaultTextFormat(tf:TextFormat):void
		{
			_top.defaultTextFormat = tf;
			_bottom.defaultTextFormat = tf;
		}
		public function set embedFonts(b:Boolean):void
		{
			_top.embedFonts = true;
			_bottom.embedFonts = true;
		}
		public function set htmlText(text:String):void
		{
			_top.htmlText = text;
			_bottom.htmlText = text;
		}
	}
}