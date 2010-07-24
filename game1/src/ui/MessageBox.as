package ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import karnold.utils.Util;

	public class MessageBox extends GameDialog
	{
		static private const FILTER:Array = [new DropShadowFilter(2, 45, 0xffffff, 1, 0, 0)];
		public function MessageBox(title:String, caption:String)
		{
			super(true);
			
			this.title = title;

			var fmt:TextFormat = new TextFormat("Computerfont", 18, 0);
			var txt:TextField = new TextField;
			txt.defaultTextFormat = fmt;
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.text = caption;
			txt.x = 10;
			txt.y = TOP_MARGIN;
			txt.width = 200;
			txt.filters = FILTER;
			addChild(txt);
			
			var yes:GameButton = GameButton.create("Yes");
			var no:GameButton = GameButton.create("No");
			
			no.width = yes.width;
			no.x = yes.x + yes.width + 5;

			var dumbParent:Sprite = new Sprite;
			dumbParent.addChild(yes);
			dumbParent.addChild(no);

			dumbParent.x = (width-dumbParent.width)/2 + 10;
			dumbParent.y = txt.y + txt.height + 20;
			
			addChild(dumbParent);
			Util.listen(yes, MouseEvent.CLICK, onYes);
			Util.listen(no, MouseEvent.CLICK, onNo);

			render();
		}
		
		private function onYes(_unused:Event):void
		{
			trace("need to dispatch yes");
		}
		private function onNo(_unused:Event):void
		{
			trace("need to dispatch no");
		}
	}
}