package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	import karnold.ui.ProgressMeter;
	import karnold.utils.Util;

	public class UpgradeTankDialog extends GameDialog
	{
		public function UpgradeTankDialog()
		{
			super(false);

			title = "HANGAR";
			
			addShipList();
			addTankHullList();
			addTankTurretList();
			addVehicleDisplay();
			addStatDisplay();
			addButtons();

			//KAI: find something less ridiculous
			width = width + 20;
			height = height + 20;
		}
//		private function addGroupBox(label:String, locX:Number, locY:Number, width:Number, height:Number):void
//		{
//			var skin:DisplayObject = AssetManager.instance.innerFace();
//			skin.width =   width;
//			skin.height =  height;
//			
//			skin.x = locX;
//			skin.y = locY;
//			
//			addChild(skin);
//			
//			var tf:TextFormat = new TextFormat("Radio Stars", 14);
//			var labelField:ShadowTextField = new ShadowTextField(tf, 0, 0x00ff00, 1);
//			labelField.text = label;
//			
//			labelField.x = skin.x + 3;
//			labelField.y = skin.y;
//			
//			addChild(labelField);
//		}
		static private const LEFT_MARGIN:Number = 10;
		static private const LIST_WIDTH:Number = 200;
		static private const LIST_HEIGHT:Number = 125;
		static private const UPGRADE_WIDTH:Number = LIST_HEIGHT;
		private function addShipList():void
		{
			UIUtil.addGroupBox(this, "Ships", LEFT_MARGIN, TOPMARGIN, LIST_WIDTH, LIST_HEIGHT);
			UIUtil.addGroupBox(this, "Upgrades", LIST_WIDTH + 15, TOPMARGIN, UPGRADE_WIDTH, LIST_HEIGHT);
			
			var list:GameList = new GameList;
//			list.addItem(ActorAssetManager.createShip(0));
//			list.addItem(ActorAssetManager.createShip(1));
			list.addItem(ActorAssetManager.createShip(12));
			list.addItem(ActorAssetManager.createShip(2));
			list.addItem(ActorAssetManager.createShip(4));
			
			list.x = 15;
			list.y = TOPMARGIN + 20;
			list.setBounds(190, 70);
			list.render();
			
			addChild(list);
		}
		private function addTankHullList():void
		{
			const top:Number = TOPMARGIN + ((LIST_HEIGHT+10));
			UIUtil.addGroupBox(this, "Tank Hulls", LEFT_MARGIN, top, LIST_WIDTH, LIST_HEIGHT);
			UIUtil.addGroupBox(this, "Upgrades", LIST_WIDTH + 15, top, UPGRADE_WIDTH, LIST_HEIGHT);

			var list:GameList = new GameList;
			list.addItem(ActorAssetManager.createHull0());
			list.addItem(ActorAssetManager.createHull1());
			list.addItem(ActorAssetManager.createHull2());
			list.addItem(ActorAssetManager.createHull3());
			list.x = 15;
			list.y = top + 20;
			list.setBounds(190, 70);
			
			list.render();
			
			addChild(list);
		}
		private function addTankTurretList():void
		{
			const top:Number = TOPMARGIN + ((LIST_HEIGHT+10)*2)
			UIUtil.addGroupBox(this, "Tank Turrets", LEFT_MARGIN, top, LIST_WIDTH, LIST_HEIGHT);
			UIUtil.addGroupBox(this, "Upgrades", LIST_WIDTH + 15, top, UPGRADE_WIDTH, LIST_HEIGHT);

			var list:GameList = new GameList;
			list.addItem(ActorAssetManager.createTurret0());
			list.addItem(ActorAssetManager.createTurret1());
			list.addItem(ActorAssetManager.createTurret2());
			list.addItem(ActorAssetManager.createTurret3());
			list.x = 15;
			list.y = top + 20;
			list.setBounds(190, 70);
			
			list.render();
			
			addChild(list);
		}
		
		private function addVehicleDisplay():void
		{
			var skin:DisplayObject = AssetManager.instance.innerFace();
			
			skin.width = 150;
			skin.height = LIST_HEIGHT;
			
			skin.y = TOPMARGIN;
			skin.x = 350;
			
			var ship:DisplayObject = ActorAssetManager.createShip(12);
			ship.x = skin.x + skin.width/2;
			ship.y = skin.y + skin.height/2;
			
			addChild(skin);
			addChild(ship);
		}
		private function addStatDisplay():void
		{
			var stats:DisplayObject = new StatList(LIST_HEIGHT);
			stats.x = 350;
			stats.y = LIST_HEIGHT + 50;
			
			addChild(stats);
		}
		private function addButtons():void
		{
			var fieldParent:Sprite = new Sprite;
			
			var tf:TextFormat = new TextFormat("Computerfont", 18);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0xffffff, 0x00, 1);
			labelField.text = "Credits:";
			labelField.y = 7;
			
			var valueField:ShadowTextField = new ShadowTextField(new TextFormat("SF Transrobotics", 24), Consts.CREDIT_FIELD_COLOR, 0, 1);
			valueField.x = labelField.width + 5;
			valueField.text = "32768";
			
			fieldParent.addChild(labelField);
			fieldParent.addChild(valueField);
			
			fieldParent.x = width - fieldParent.width;
			fieldParent.y = 300;
			
			addChild(fieldParent);
			
			var btn:GameButton = GameButton.create("Done", true, 24, 1);
			btn.y = height - btn.height;
			btn.x = width - btn.width;
			
			addChild(btn);
		}
	}
}