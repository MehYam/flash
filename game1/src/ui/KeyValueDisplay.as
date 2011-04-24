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

			var labelField:ShadowTextField = new ShadowTextField(0xffffff, 0x00, 1);
			AssetManager.instance.assignFont(labelField, AssetManager.FONT_COMPUTER, 18);
			labelField.text = label;
			labelField.y = 7;
			
			_valueField = new ShadowTextField(Consts.CREDIT_FIELD_COLOR, 0, 1);
			AssetManager.instance.assignFont(_valueField, AssetManager.FONT_ROBOT, 24); 
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