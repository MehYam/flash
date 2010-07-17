package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	import karnold.ui.ProgressMeter;
	import karnold.utils.Util;
	
	public class StatList extends Sprite
	{
		public function StatList(height:Number)
		{
			super();
			
			var skin:DisplayObject = AssetManager.instance.innerFace();
			
			skin.width = 150;
			
			s_fieldTop = 0;
			var fields:Sprite = new Sprite;
			addStatField(fields, "Armor", 0.2);
			addStatField(fields, "Damage", 0.3);
			addStatField(fields, "Fire Rate", 0.7);
			addStatField(fields, "Ammo", 1);
			addStatField(fields, "Speed", 0.3);
			
			skin.height = height;
			addChild(skin);
			
			fields.x = skin.x + 5;
			fields.y = skin.y + 5;
			addChild(fields);
		}
		static private var s_fieldTop:Number;
		static private function addStatField(parent:DisplayObjectContainer, label:String, meterValue:Number, meterColor:uint = 0x0033ff):void
		{
			var tf:TextFormat = new TextFormat("SF Transrobotics", 18);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0x00, 0xff, 1);
			labelField.text = label + ":";
			labelField.y = s_fieldTop;
			
			s_fieldTop += 20;
			
			var valueField:ProgressMeter = new ProgressMeter(50, 7, 0, meterColor);
			valueField.pct = meterValue;
			
			Util.centerChild(valueField, labelField);
			valueField.y += 2;
			valueField.x = 135 - valueField.width;
			
			parent.addChild(labelField);
			parent.addChild(valueField);
		}
	}
}