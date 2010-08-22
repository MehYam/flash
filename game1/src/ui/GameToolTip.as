package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import karnold.utils.IToolTip;
	
	public class GameToolTip extends Sprite implements IToolTip
	{
		private var _skin:DisplayObject;
		private var _textField:TextField;
		static private const _fmt:TextFormat = new TextFormat("Arial", 12);
		static private const MARGIN:Number = 5;

		public function GameToolTip()
		{
			_skin = AssetManager.instance.uiFace(0xaaffaa);
			_textField = new TextField();
			_textField.x = MARGIN;
			_textField.y = MARGIN;
			_textField.defaultTextFormat = _fmt;
			_textField.autoSize = TextFieldAutoSize.LEFT;
			_textField.multiline = true;
			_textField.wordWrap = true;
			_textField.width = 300;
			
			addChild(_skin);
			addChild(_textField);
			
			filters = [new DropShadowFilter];
			
			alpha = 0.95;
		}
		public function set text(t:String):void
		{
			_textField.htmlText = t;
			_skin.width = _textField.width + MARGIN*2;
			_skin.height = _textField.height + MARGIN*2;
		}
		
		public function get displayObject():DisplayObject
		{
			return this;
		}
	}
}