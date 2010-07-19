package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	
	import gameData.BaseStats;
	
	import karnold.ui.ProgressMeter;
	import karnold.utils.Util;
	
	public class StatList extends Sprite
	{
		public function StatList(stats:BaseStats, height:Number)
		{
			super();
			
			var skin:DisplayObject = AssetManager.instance.innerFace();
			
			skin.width = 150;
			
			s_fieldTop = 0;
			var fields:Sprite = new Sprite;
			addStatField(fields, "Armor", stats.armor);
			addStatField(fields, "Damage", stats.damage);
			addStatField(fields, "Fire Rate", stats.fireRate);
			addStatField(fields, "Ammo", 1);
			addStatField(fields, "Speed", stats.speed);
			
			skin.height = height;
			addChild(skin);
			
			fields.x = skin.x + 5;
			fields.y = skin.y + 5;
			addChild(fields);
		}
		static private var s_fieldTop:Number;
		static private var s_dropShadow:Array = [new DropShadowFilter(2, 45, 0, 1, 0, 0)];
		static private function addStatField(parent:DisplayObjectContainer, label:String, meterValue:Number, meterColor:uint = 0x0033ff):void
		{
			var tf:TextFormat = new TextFormat("SF Transrobotics", 18);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0x00, 0xff, 1);
			labelField.text = label + ":";
			labelField.y = s_fieldTop;
			
			s_fieldTop += 20;
			
			var valueField:ProgressMeter = new ProgressMeter(50, 7, 0, meterColor);
			valueField.pct = meterValue;
			valueField.filters = s_dropShadow
			
			Util.centerChild(valueField, labelField);
			valueField.y += 2;
			valueField.x = 135 - valueField.width;
			
			parent.addChild(labelField);
			parent.addChild(valueField);
		}
	}
}