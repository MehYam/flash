package ui
{
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import karnold.ui.ShadowTextField;
	
	public class CreditDisplay extends Sprite
	{
		private var _creditField:ShadowTextField;
		public function CreditDisplay()
		{
			super();

			var tf:TextFormat = new TextFormat("Computerfont", 18);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0xffffff, 0x00, 1);
			labelField.text = "Credits:";
			labelField.y = 7;
			
			_creditField = new ShadowTextField(new TextFormat("SF Transrobotics", 24), Consts.CREDIT_FIELD_COLOR, 0, 1);
			_creditField.x = labelField.width + 5;
			_creditField.text = "32768";
			
			addChild(labelField);
			addChild(_creditField);
		}
		public function set credits(c:uint):void
		{
			_creditField.text = String(c);
		}
	}
}