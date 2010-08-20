package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	
	import gameData.VehiclePartStats;
	
	import karnold.ui.ProgressMeter;
	import karnold.ui.ShadowTextField;
	import karnold.utils.Util;
	
	public class StatList extends Sprite
	{
		private var _armor:ProgressMeter;
		private var _damage:ProgressMeter;
		private var _fireRate:ProgressMeter;
		private var _speed:ProgressMeter;
		private var _stats:VehiclePartStats;
		public function StatList(stats:VehiclePartStats, height:Number)
		{
			super();
			
			var skin:DisplayObject = AssetManager.instance.innerFace();
			
			skin.width = 150;
			
			s_fieldTop = 0;
			var fields:Sprite = new Sprite;
			_armor = addStatField(fields, "Armor", stats.armor);
			_damage = addStatField(fields, "Damage", stats.damage);
			_fireRate = addStatField(fields, "Fire Rate", stats.fireRate);
			addStatField(fields, "Ammo", 0.1);
			_speed = addStatField(fields, "Speed", stats.speed);
			_stats = stats;
			
			skin.height = height;
			addChild(skin);
			
			fields.x = skin.x + 5;
			fields.y = skin.y + 5;
			addChild(fields);
		}
		static private var s_fieldTop:Number;
		static private var s_dropShadow:Array = [new DropShadowFilter(2, 45, 0, 1, 0, 0)];
		static private function addStatField(parent:DisplayObjectContainer, label:String, meterValue:Number, meterColor:uint = 0x0033ff):ProgressMeter
		{
			var tf:TextFormat = new TextFormat("SF Transrobotics", 18);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0x00, 0xff, 1);
			labelField.text = label + ":";
			labelField.y = s_fieldTop;
			
			s_fieldTop += 20;
			
			var meter:ProgressMeter = new ProgressMeter(50, 7, 0, meterColor);
			meter.pct = meterValue;
			meter.filters = s_dropShadow
			
			Util.centerChild(meter, labelField);
			meter.y += 2;
			meter.x = 135 - meter.width;
			
			parent.addChild(labelField);
			parent.addChild(meter);
			
			return meter;
		}
	
		public function set stats(stats:VehiclePartStats):void
		{
			_stats = stats;
			
			_armor.pct = stats.armor;
			_damage.pct = stats.damage;
			_fireRate.pct = stats.fireRate;
			_speed.pct = stats.speed;
		}

		// pass in null to turn off the compare
		public function set compare(vs:VehiclePartStats):void
		{
			if (vs)
			{
				_armor.diff = vs.armor - _stats.armor;
				_damage.diff = vs.damage - _stats.damage;
				_fireRate.diff = vs.fireRate - _stats.fireRate;
				_speed.diff = vs.speed - _stats.speed;
			}
			else
			{
				_armor.diff = 0;
				_damage.diff = 0;
				_fireRate.diff = 0;
				_speed.diff = 0;
			}
		}
		// pass in BaseStats.ZERO to turn off the diff
		public function set diff(diff:VehiclePartStats):void
		{
			if (diff)
			{
				_armor.diff = diff.armor;
				_damage.diff = diff.damage;
				_fireRate.diff = diff.fireRate;
				_speed.diff = diff.speed;
			}
		}
	}
}