package ui
{
	import flash.text.TextFormat;
	
	import karnold.utils.Util;

	public class LevelCompleteDialog extends GameDialog
	{
		public function LevelCompleteDialog()
		{
			super();
			
			title = "STATS";
			
			addFields();
			addBottomStuff();
			
			width = width + 20;
			height = height + 20;
		}
		
		private function addFields():void
		{
			addField("Enemies Killed", "30/50 (60%)");
			addField("Credits Earned", "3550", Consts.CREDIT_FIELD_COLOR);
			addField("Max Combo", "23");
			addField("Time", "12:34");
			addField("Damage per second", "35.65");
			addField("DPS received", "23.23");
		}
		private var _lastFieldBottom:Number = TOPMARGIN;
		private function addField(label:String, value:String, valueColor:uint = 0xffffff):void
		{
			var tf:TextFormat = new TextFormat("Computerfont", 24);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0xffffff, 0x444444, 1);
			labelField.text = label + ":";
			labelField.x = 20;
			labelField.y = _lastFieldBottom;

			var valueField:ShadowTextField = new ShadowTextField(new TextFormat("SF Transrobotics", 24), 0x77aa77, valueColor, 1);
			
			valueField.y = labelField.y - 2;
			valueField.x = 250 - valueField.width;
			valueField.text = value;
			
			addChild(labelField);
			addChild(valueField);

			_lastFieldBottom = labelField.y + labelField.height;
		}
		
		private function addBottomStuff():void
		{
			var continueButton:GameButton = GameButton.create("Next", true, 24, 1);
			
			Util.centerChild(continueButton, this);
			continueButton.y = _lastFieldBottom + 20;
			
			addChild(continueButton);
		}
	}
}