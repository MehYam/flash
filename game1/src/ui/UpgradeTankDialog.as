package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import karnold.ui.ProgressMeter;
	import karnold.utils.Util;

	public class UpgradeTankDialog extends GameDialog
	{
		public function UpgradeTankDialog()
		{
			super(false);

			title = "HANGAR";
			
			addTankHullList();
			addTankTurretList();
			addVehicleDisplay();
			addStatDisplay();
			addButtons();

			render();
		}
		static private const LEFT_MARGIN:Number = 10;
		static private const LIST_WIDTH:Number = 320;
		static private const LIST_HEIGHT:Number = 125;
		static private const ITEM_SIZE:Number = LIST_HEIGHT - 25;
		static private const UPGRADE_WIDTH:Number = LIST_HEIGHT;
		private function addTankHullList():void
		{
			const top:Number = TOP_MARGIN;
			UIUtil.addGroupBox(this, "Tank Hulls", LEFT_MARGIN, top, LIST_WIDTH, LIST_HEIGHT);
			UIUtil.addGroupBox(this, "Upgrades", LIST_WIDTH + 15, top, UPGRADE_WIDTH, LIST_HEIGHT);

			var list:GameList = new GameList;
			list.addItem(new GameListItem(ActorAssetManager.createHull0(), ITEM_SIZE, ITEM_SIZE));
			list.addItem(new GameListItem(ActorAssetManager.createHull1(), ITEM_SIZE, ITEM_SIZE));
			list.addItem(new GameListItem(ActorAssetManager.createHull2(), ITEM_SIZE, ITEM_SIZE));
			list.addItem(new GameListItem(ActorAssetManager.createHull3(), ITEM_SIZE, ITEM_SIZE));
			list.x = 15;
			list.y = top + 20;
			list.setBounds(LIST_WIDTH-10, LIST_HEIGHT-25);
			
			list.render();
			
			addChild(list);
		}
		private function addTankTurretList():void
		{
			const top:Number = TOP_MARGIN + (LIST_HEIGHT+10);
			UIUtil.addGroupBox(this, "Tank Turrets", LEFT_MARGIN, top, LIST_WIDTH, LIST_HEIGHT);
			UIUtil.addGroupBox(this, "Upgrades", LIST_WIDTH + 15, top, UPGRADE_WIDTH, LIST_HEIGHT);

			var list:GameList = new GameList;
			list.addItem(new GameListItem(ActorAssetManager.createTurret0(), ITEM_SIZE, ITEM_SIZE));
			list.addItem(new GameListItem(ActorAssetManager.createTurret1(), ITEM_SIZE, ITEM_SIZE));
			list.addItem(new GameListItem(ActorAssetManager.createTurret2(), ITEM_SIZE, ITEM_SIZE));
			list.addItem(new GameListItem(ActorAssetManager.createTurret3(), ITEM_SIZE, ITEM_SIZE));
			list.x = 15;
			list.y = top + 20;
			list.setBounds(LIST_WIDTH-10, LIST_HEIGHT-25);
			
			list.render();
			
			addChild(list);
		}
		
		private function addVehicleDisplay():void
		{
			var skin:DisplayObject = AssetManager.instance.innerFace();
			
			skin.width = 150;
			skin.height = LIST_HEIGHT;
			
			skin.y = TOP_MARGIN;
			skin.x = 470;
			
			var ship:DisplayObject = ActorAssetManager.createShip(12);
			ship.x = skin.x + skin.width/2;
			ship.y = skin.y + skin.height/2;
			
			addChild(skin);
			addChild(ship);
		}
		private function addStatDisplay():void
		{
			var stats:DisplayObject = new StatList(LIST_HEIGHT);
			stats.x = 470;
			stats.y = LIST_HEIGHT + 50;
			
			addChild(stats);
		}
		private function addButtons():void
		{
			var btn:GameButton = GameButton.create("Done", true, 24, 1);
			btn.y = height + 10;
			btn.x = width - btn.width;
			
			addChild(btn);
			Util.listen(btn, MouseEvent.CLICK, onDone);

			var purchase:GameButton = GameButton.create("Purchase", true, 24, 1);
			purchase.y = btn.y;
			purchase.x = btn.x - purchase.width - 5;
			purchase.enabled = false;
			addChild(purchase);

			var fieldParent:DisplayObjectContainer = UIUtil.createCreditDisplay();
			
			fieldParent.x = purchase.x - fieldParent.width - 5;
			fieldParent.y = purchase.y;
			
			addChild(fieldParent);
			
		}
		private function onDone(e:Event):void
		{
			UIUtil.closeDialog(parent, this);
		}
	}
}