package ui.dialogs
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import karnold.ui.ShadowTextField;
	import karnold.utils.Util;
	
	import ui.GameButton;

	public class TutorialDialog extends GameDialog
	{
		static private const TEXT:Array = 
		[
			"- Use your tank and plane to finish off the opponents on each level\n\n- Earn credits to buy upgrades in the Tank Garage and Plane Hangar",
			"- Use W,S,A,D or the arrow keys to move your vehicle\n\n-Aim and shoot using the mouse, or shoot forward with SPACE\n\n-Killing enemies quickly raises the combo multiplier higher for better rewards"
		];
		static public function get steps():uint { return TEXT.length; }
		public function TutorialDialog(step:uint)
		{
			super(true);
			
			this.title = "Instructions " + (step+1) + " of " + steps;
			var txt:TextField = new TextField();
			txt.filters = AssetManager.instance.messageBoxFontShadow;
			AssetManager.instance.assignTextFormat(txt, AssetManager.instance.messageBoxFont);
			
			txt.text = TEXT[step];
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.multiline = true;
			txt.wordWrap = true;
			
			txt.x = 20;
			txt.y = TOP_MARGIN;
			txt.width = 400;
			addChild(txt);
			
			var img:DisplayObject = AssetManager.instance.getTutorialImage(step);
			Util.centerChild(img, this);
			img.y = txt.y + txt.height + 20;
			addChild(img);
			
			var ok:GameButton = GameButton.create(step == (steps-1) ? "Done" : "Next");
			
			Util.centerChild(ok, this);
			ok.y = img.y + img.height + 20;
			
			Util.listen(ok, MouseEvent.CLICK, onDone);
			addChild(ok);

			render();
		}
		private function onDone(e:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}