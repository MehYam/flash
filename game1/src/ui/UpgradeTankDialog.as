package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import gameData.BaseStats;
	import gameData.TankPartData;
	import gameData.UserData;
	
	import karnold.ui.ProgressMeter;
	import karnold.ui.ShadowTextField;
	import karnold.utils.Util;

	public class UpgradeTankDialog extends GameDialog
	{
		public function UpgradeTankDialog()
		{
			super(false);

			title = "TANK GARAGE";
			
			addTankHullList();
			addTankTurretList();
			addVehicleDisplay();
			addStatDisplay();
			addButtons();

			render();
		}
		static private const LEFT_MARGIN:Number = 10;
		static private const LIST_WIDTH:Number = 325;
		static private const LIST_HEIGHT:Number = 125;
		static private const ITEM_SIZE:Number = LIST_HEIGHT - 25;
		static private const UPGRADE_WIDTH:Number = LIST_HEIGHT;
		private var _listHulls:GameList;
		private var _listHullUpgrades:GameList;
		private function addTankHullList():void
		{
			const top:Number = TOP_MARGIN;
			UIUtil.addGroupBox(this, "Tank Hulls", LEFT_MARGIN, top, LIST_WIDTH, LIST_HEIGHT);

			_listHulls = new GameList;
			var index:uint = 0;
			for each (var hull:TankPartData in TankPartData.hulls)
			{
				var item:GameListItem = new GameListItem(ActorAssetManager.createHull(hull.assetIndex, false), ITEM_SIZE, ITEM_SIZE, index); 
				_listHulls.addItem(item);
				if (UserData.instance.purchasedHulls[index])
				{
					UIUtil.addCheckmark(item);
				}
				if (index == UserData.instance.currentHull)
				{
					Util.ASSERT(UserData.instance.purchasedHulls[index]);
					_listHulls.selectItem(item);
				}
				++index;
			}
			_listHulls.x = 15;
			_listHulls.y = top + 20;
			_listHulls.setBounds(LIST_WIDTH-15, LIST_HEIGHT-25);
			
			_listHulls.render();
			
			addChild(_listHulls);
			
			Util.listen(_listHulls, Event.SELECT, onHullSelection);
			Util.listen(_listHulls, MouseEvent.ROLL_OVER, onHullRoll);
			Util.listen(_listHulls, MouseEvent.ROLL_OUT, onHullRoll);

			// Upgrades //////////////////////
			var parent:DisplayObject = UIUtil.addGroupBox(this, "Upgrades", LIST_WIDTH + 15, top, UPGRADE_WIDTH, LIST_HEIGHT);
			_listHullUpgrades = new GameList;
			_listHullUpgrades.x = parent.x + 5;
			_listHullUpgrades.y = parent.y + 15;
			
			addUpgrade(_listHullUpgrades, TankPartData(TankPartData.hulls[0]).upgradeA, 0);
			addUpgrade(_listHullUpgrades, TankPartData(TankPartData.hulls[0]).upgradeB, 1);
			
			_listHullUpgrades.setBounds(UPGRADE_WIDTH, LIST_HEIGHT); 
			_listHullUpgrades.renderVert();
			addChild(_listHullUpgrades);
		}

		static private function addUpgrade(list:GameList, text:String, cookie:uint):void
		{
			const fmt:TextFormat = new TextFormat("SF TransRobotics", 16);
			var tf:TextField = new TextField();
			tf.defaultTextFormat = fmt;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.wordWrap = true;
			tf.text = text;
			tf.mouseEnabled = false;
			tf.width = UPGRADE_WIDTH - 20;
			
			var upgrade:GameListItem = new GameListItem(tf, UPGRADE_WIDTH - 10, (LIST_HEIGHT-27)/2, cookie);
			upgrade.border = true;
			list.addItem(upgrade);
		}
		private var _listTurrets:GameList;
		private var _listTurretUpgrades:GameList;
		private function addTankTurretList():void
		{
			const top:Number = TOP_MARGIN + (LIST_HEIGHT+10);
			UIUtil.addGroupBox(this, "Tank Turrets", LEFT_MARGIN, top, LIST_WIDTH, LIST_HEIGHT);

			_listTurrets = new GameList;
			var index:uint = 0;
			for each (var turret:TankPartData in TankPartData.turrets)
			{
				var item:GameListItem = new GameListItem(ActorAssetManager.createTurret(turret.assetIndex, false), ITEM_SIZE, ITEM_SIZE, index); 
				_listTurrets.addItem(item);
				if (UserData.instance.purchasedHulls[index])
				{
					UIUtil.addCheckmark(item);
				}
				if (index == UserData.instance.currentTurret)
				{
					Util.ASSERT(UserData.instance.purchasedTurrets[index]);
					_listTurrets.selectItem(item);
				}

				++index;
			}
			_listTurrets.x = 15;
			_listTurrets.y = top + 20;
			_listTurrets.setBounds(LIST_WIDTH-15, LIST_HEIGHT-25);
			
			_listTurrets.render();
			
			addChild(_listTurrets);

			Util.listen(_listTurrets, Event.SELECT, onTurretSelection);
			Util.listen(_listTurrets, MouseEvent.ROLL_OVER, onTurretRoll);
			Util.listen(_listTurrets, MouseEvent.ROLL_OUT, onTurretRoll);

			// Upgrades //////////////////////
			var parent:DisplayObject = UIUtil.addGroupBox(this, "Upgrades", LIST_WIDTH + 15, top, UPGRADE_WIDTH, LIST_HEIGHT);
			_listTurretUpgrades = new GameList;
			_listTurretUpgrades.x = parent.x + 5;
			_listTurretUpgrades.y = parent.y + 15;
			
			addUpgrade(_listTurretUpgrades, TankPartData(TankPartData.turrets[0]).upgradeA, 0);
			addUpgrade(_listTurretUpgrades, TankPartData(TankPartData.turrets[0]).upgradeB, 1);
			
			_listTurretUpgrades.setBounds(UPGRADE_WIDTH, LIST_HEIGHT); 
			_listTurretUpgrades.renderVert();
			addChild(_listTurretUpgrades);
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
			var stats:DisplayObject = new StatList(new BaseStats(.5, .1, .2, .8, .3), LIST_HEIGHT);
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

			var fieldParent:DisplayObjectContainer = new CreditDisplay;
			
			fieldParent.x = purchase.x - fieldParent.width - 5;
			fieldParent.y = purchase.y;
			
			addChild(fieldParent);
			
		}
		
		private function onHullRoll(_unused:Event):void
		{
			const item:GameListItem = _listHulls.rolledOverItem as GameListItem;
			const hull:TankPartData = (item && TankPartData.hulls[item.cookie]) as TankPartData;
			if (hull)
			{
				trace("hull roll", hull);
			}
		}
		private function onHullSelection(_unused:Event):void
		{
			const item:GameListItem = _listHulls.rolledOverItem as GameListItem;
			const hull:TankPartData = (item && TankPartData.hulls[item.cookie]) as TankPartData;
			if (hull)
			{
				trace("hull select", hull);
			}
			
		}
		private function onTurretRoll(_unused:Event):void
		{
			const item:GameListItem = _listTurrets.rolledOverItem as GameListItem;
			const turret:TankPartData = (item && TankPartData.turrets[item.cookie]) as TankPartData;
			if (turret)
			{
				trace("turret roll", turret);
			}
		}
		private function onTurretSelection(_unused:Event):void
		{
			const item:GameListItem = _listHulls.rolledOverItem as GameListItem;
			const hull:TankPartData = (item && TankPartData.hulls[item.cookie]) as TankPartData;
			if (hull)
			{
				trace("hull select", hull);
			}
			
		}
		private function onDone(e:Event):void
		{
			UIUtil.closeDialog(parent, this);
		}
	}
}