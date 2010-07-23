package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import karnold.utils.IToolTip;
	
	public class GameToolTip extends Sprite implements IToolTip
	{
		private var _skin:DisplayObject;
		private var _textField:TextField;
		public function GameToolTip()
		{
			_skin = AssetManager.instance.uiFace(0x77ff77);
			_textField = new TextField();
			_textField.autoSize = TextFieldAutoSize.LEFT;
			
			addChild(_skin);
			addChild(_textField);
			
			filters = [new DropShadowFilter];
			
			alpha = 0.7;
		}
		
		public function set text(t:String):void
		{
			_textField.htmlText = t;
			_skin.width = _textField.width;
			_skin.height = _textField.height;
		}
		
		public function get displayObject():DisplayObject
		{
			return this;
		}
	}
}