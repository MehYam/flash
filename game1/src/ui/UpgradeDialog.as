package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	import karnold.ui.ProgressMeter;
	import karnold.utils.Util;

	public class UpgradeDialog extends GameDialog
	{
		public function UpgradeDialog()
		{
			super(false);

			title = "HANGAR";
			
			addShipList();
			addTankHullList();
			addTankTurretList();
			addVehicleDisplay();
			addStatDisplay();

			//KAI: find something less ridiculous
			width = width + 100;
			height = height + 100;
		}
		private function addList(label:String, locX:Number, locY:Number, width:Number, height:Number):void
		{
			var skin:DisplayObject = AssetManager.instance.innerFace();
			skin.width =   width;
			skin.height =  height;
			
			skin.x = locX;
			skin.y = locY;
			
			addChild(skin);
			
			var tf:TextFormat = new TextFormat("Radio Stars", 14);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0, 0x00ff00, 1);
			labelField.text = label;
			
			labelField.x = skin.x + 3;
			labelField.y = skin.y;
			
			addChild(labelField);
			
			var upgradeSkin:DisplayObject = AssetManager.instance.innerFace();
			upgradeSkin.width = upgradeSkin.height = skin.height;
			upgradeSkin.x = skin.x + skin.width + 5;
			upgradeSkin.y = skin.y;
			
			addChild(upgradeSkin);
		}
		private function addShipList():void
		{
			addList("Ships", 10, TOPMARGIN, 200, 100);
		}
		private function addTankHullList():void
		{
			addList("Tank Hulls", 10, TOPMARGIN + 110, 200, 100);
		}
		private function addTankTurretList():void
		{
			addList("Tank Turrets", 10, TOPMARGIN + 220, 200, 100);
		}
		
		private function addVehicleDisplay():void
		{
			var skin:DisplayObject = AssetManager.instance.innerFace();
			
			skin.width = 100;
			skin.height = 100;
			
			skin.y = TOPMARGIN;
			skin.x = 350;
			
			var ship:DisplayObject = ActorAssetManager.createShip(12);
			ship.x = skin.x + skin.width/2;
			ship.y = skin.y + skin.height/2;
			
			addChild(skin);
			addChild(ship);
		}
		static private var s_fieldTop:Number;
		private function addStatDisplay():void
		{
			var skin:DisplayObject = AssetManager.instance.innerFace();
			
			skin.width = 150;

			s_fieldTop = 0;
			var fields:Sprite = new Sprite;
			addStatField(fields, "Armor", 0.2);
			addStatField(fields, "Damage", 0.3);
			addStatField(fields, "Fire Rate", 0.7);
			addStatField(fields, "Ammo", 1);
			addStatField(fields, "Speed", 0.3);
			
			skin.height = fields.height + 10;
			skin.x = 350;
			skin.y = 150;
			addChild(skin);
			
			fields.x = skin.x + 5;
			fields.y = skin.y + 5;
			addChild(fields);
		}
		static private function addStatField(parent:DisplayObjectContainer, label:String, meterValue:Number, meterColor:uint = 0x0033cc):void
		{
			var tf:TextFormat = new TextFormat("SF Transrobotics", 18);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0x00, 0xff, 1);
			labelField.text = label + ":";
			labelField.y = s_fieldTop;
			
			s_fieldTop += 20;

			var valueField:ProgressMeter = new ProgressMeter(30, 7, 0, meterColor);
			valueField.pct = meterValue;
			
			Util.centerChild(valueField, labelField);
			valueField.x = 135 - valueField.width;
			
			parent.addChild(labelField);
			parent.addChild(valueField);
		}
	}
}