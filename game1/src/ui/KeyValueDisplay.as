package ui
{
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	import karnold.ui.ShadowTextField;
	
	public class KeyValueDisplay extends Sprite
	{
		private var _valueField:ShadowTextField;
		public function KeyValueDisplay(label:String)
		{
			super();

			var tf:TextFormat = new TextFormat("Computerfont", 18);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0xffffff, 0x00, 1);
			labelField.text = label;
			labelField.y = 7;
			
			_valueField = new ShadowTextField(new TextFormat("SF Transrobotics", 24), Consts.CREDIT_FIELD_COLOR, 0, 1);
			_valueField.x = labelField.width + 5;
			_valueField.text = "32768";
			
			addChild(labelField);
			addChild(_valueField);
		}
		public function set valColor(clr:uint):void
		{
			_valueField.fgColor = clr;
		}
		public function set value(c:uint):void
		{
			_valueField.text = String(c);
		}
	}
}