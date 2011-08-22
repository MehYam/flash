package ui.dialogs
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import karnold.utils.Util;
	import ui.GameButton;

	public class MessageBox extends GameDialog
	{
		public function MessageBox(title:String, caption:String, btn1:String = "Yes", btn2:String = "No")
		{
			super(true);
			
			this.title = title;

			var fmt:TextFormat = AssetManager.instance.messageBoxFont;
			var txt:TextField = new TextField;
			txt.defaultTextFormat = fmt;
			txt.embedFonts = true;
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.text = caption;
			txt.x = 10;
			txt.y = TOP_MARGIN;
			txt.width = 300;
			txt.filters = AssetManager.instance.messageBoxFontShadow;
			addChild(txt);
			
			var yes:GameButton = GameButton.create(btn1);
			var no:GameButton = GameButton.create(btn2);
			
			no.width = yes.width;
			no.x = yes.x + yes.width + 5;

			var btnParent:Sprite = new Sprite;
			btnParent.addChild(yes);
			btnParent.addChild(no);
			addChild(btnParent);

			Util.centerChild(btnParent, this);
			btnParent.y = txt.y + txt.height + 20;
			
			Util.listen(yes, MouseEvent.CLICK, onYes);
			Util.listen(no, MouseEvent.CLICK, onNo);

			render();
		}
		
		private function onYes(_unused:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		private function onNo(_unused:Event):void
		{
			dispatchEvent(new Event(Event.CANCEL));
		}
	}
}