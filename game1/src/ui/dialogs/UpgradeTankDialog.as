package ui.dialogs
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import gameData.TankPartData;
	import gameData.UserData;
	import gameData.VehiclePartStats;
	
	import karnold.ui.ProgressMeter;
	import karnold.ui.ShadowTextField;
	import karnold.utils.FrameTimer;
	import karnold.utils.ToolTipMgr;
	import karnold.utils.Util;
	
	import scripts.TankActor;
	import ui.GameButton;
	import ui.GameList;
	import ui.GameListItem;
	import ui.GlobalUIEvent;
	import ui.KeyValueDisplay;
	import ui.StatList;
	import ui.UIUtil;

	public class UpgradeTankDialog extends GameDialog
	{
		public function UpgradeTankDialog()
		{
			super(false);

			title = "TANK GARAGE";
			
			addTankHullList();
			addTankTurretList();
			addPreview();
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
		private var _lastSelectedHull:uint;
		private function addTankHullList():void
		{
			const top:Number = TOP_MARGIN;
			UIUtil.addGroupBox(this, "Tank Hulls", LEFT_MARGIN, top, LIST_WIDTH, LIST_HEIGHT);

			_listHulls = new GameList;
			var index:uint = 0;
			for each (var hull:TankPartData in TankPartData.hulls)
			{
				var item:GameListItem = new GameListItem(ActorAssetManager.createHull(hull.assetIndex, false), ITEM_SIZE, ITEM_SIZE, index); 
				ToolTipMgr.instance.addToolTip(item, UIUtil.formatItemTooltip(hull));

				_listHulls.addItem(item);
				if (UserData.instance.owns(hull.id))
				{
					UIUtil.addCheckmark(item);
					if (index == UserData.instance.currentHull)
					{
						_listHulls.selectItem(item);
						_lastSelectedHull = index;
					}
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
			
			populateUpgrades(_listHullUpgrades, TankPartData.getHull(UserData.instance.currentHull));
			addChild(_listHullUpgrades);

			Util.listen(_listHullUpgrades, Event.SELECT, onHullUpgradeSelection);
			Util.listen(_listHullUpgrades, MouseEvent.ROLL_OVER, onHullUpgradeRoll);
			Util.listen(_listHullUpgrades, MouseEvent.ROLL_OUT, onHullUpgradeRoll);
		}
		private var _listTurrets:GameList;
		private var _listTurretUpgrades:GameList;
		private var _lastSelectedTurret:uint;
		private function addTankTurretList():void
		{
			const top:Number = TOP_MARGIN + (LIST_HEIGHT+10);
			UIUtil.addGroupBox(this, "Tank Turrets", LEFT_MARGIN, top, LIST_WIDTH, LIST_HEIGHT);

			_listTurrets = new GameList;
			var index:uint = 0;
			for each (var turret:TankPartData in TankPartData.turrets)
			{
				var item:GameListItem = new GameListItem(ActorAssetManager.createTurret(turret.assetIndex, false), ITEM_SIZE, ITEM_SIZE, index); 
				ToolTipMgr.instance.addToolTip(item, UIUtil.formatItemTooltip(turret));
				_listTurrets.addItem(item);
				if (UserData.instance.owns(turret.id))
				{
					UIUtil.addCheckmark(item);
					if (index == UserData.instance.currentTurret)
					{
						_listTurrets.selectItem(item);
						_lastSelectedTurret = index;
					}
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
			_listTurretUpgrades.setBounds(UPGRADE_WIDTH, LIST_HEIGHT); 

			populateUpgrades(_listTurretUpgrades, TankPartData.getTurret(UserData.instance.currentTurret));
			
			addChild(_listTurretUpgrades);

			Util.listen(_listTurretUpgrades, Event.SELECT, onTurretUpgradeSelection);
			Util.listen(_listTurretUpgrades, MouseEvent.ROLL_OVER, onTurretUpgradeRoll);
			Util.listen(_listTurretUpgrades, MouseEvent.ROLL_OUT, onTurretUpgradeRoll);
		}
		private function populateUpgrades(list:GameList, tankPart:TankPartData):void
		{
			list.clearItems();
			if (UserData.instance.owns(tankPart.id))
			{
				addUpgrade(list, tankPart.getUpgrade(0), 0);
				addUpgrade(list, tankPart.getUpgrade(1), 1);
			}
			else
			{
				list.addItem(UIUtil.createMysteryGameListItem(LIST_HEIGHT-25));
			}
			
			list.setBounds(UPGRADE_WIDTH, LIST_HEIGHT); 
			list.renderVert();
		}
		static private function addUpgrade(list:GameList, part:TankPartData, upgradeIndex:uint):void
		{
			const fmt:TextFormat = AssetManager.instance.createFont(AssetManager.FONT_ROBOT, 16);
			var tf:TextField = new TextField();
			tf.defaultTextFormat = fmt;
			tf.embedFonts = true;
			tf.autoSize = TextFieldAutoSize.CENTER;
			tf.wordWrap = true;
			tf.text = part.name;
			tf.mouseEnabled = false;
			tf.width = UPGRADE_WIDTH - 20;
			
			var upgrade:GameListItem = new GameListItem(tf, UPGRADE_WIDTH - 10, (LIST_HEIGHT-27)/2, upgradeIndex);
			ToolTipMgr.instance.addToolTip(upgrade, UIUtil.formatItemTooltip(part, false), ToolTipMgr.DEFAULT_DELAY*2);
			upgrade.border = true;
			if (UserData.instance.owns(part.id))
			{
				upgrade.mouseEnabled = false;
				upgrade.alpha = 0.5;
				var check:DisplayObject = UIUtil.addCheckmark(upgrade);
				
				check.x += 20;
				check.y -= 20;
				check.scaleX *= .5;
				check.scaleY *= .5;
			}
			list.addItem(upgrade);
		}
		
		private var _previewSkin:DisplayObject
		private function addPreview():void
		{
			_previewSkin = AssetManager.instance.innerFace();
			_previewSkin.width = 150;
			_previewSkin.height = LIST_HEIGHT;
			
			_previewSkin.y = TOP_MARGIN;
			_previewSkin.x = 470;
			
			addChild(_previewSkin);
			
			populatePreview();
		}
		private var _preview:PreviewStuff = new PreviewStuff;
		private function populatePreview():void
		{
			var dobj:DisplayObject;
			var prevRotation:Number = 0;
			var prevTurretRotation:Number = 0;
			if (_preview.tank)
			{
				Util.ASSERT(_preview.tank.displayObject.parent != null);
				dobj = _preview.tank.displayObject;
				dobj.parent.removeChild(dobj);

				prevRotation = dobj.rotation;
				prevTurretRotation = _preview.tank.turretRotation;
			}

			_preview.tank = TankActor.createTankActor(_lastSelectedHull, _lastSelectedTurret, null);
			dobj = _preview.tank.displayObject;
			dobj.x = _previewSkin.x + _previewSkin.width/2;
			dobj.y = _previewSkin.y + _previewSkin.height/2;
			dobj.rotation = prevRotation;
			_preview.tank.turretRotation = prevTurretRotation;
			addChild(dobj);

			_preview.start();
		}
		
		private var _stats:StatList;
		private function addStatDisplay():void
		{
			_stats = new StatList(new VehiclePartStats(0, 0, 0, 0, 0), LIST_HEIGHT);
			_stats.x = 470;
			_stats.y = LIST_HEIGHT + 50;
			
			addChild(_stats);
			
			updateStats();
		}
		private var _purchaseBtn:GameButton;
		private var _costField:KeyValueDisplay;
		private function addButtons():void
		{
			var btn:GameButton = GameButton.create("Done", true, 24, 1);
			btn.y = height + 10;
			btn.x = width - btn.width;
			
			addChild(btn);
			Util.listen(btn, MouseEvent.CLICK, onDone);
			
			_purchaseBtn = GameButton.create("Purchase", true, 24, 1);
			_purchaseBtn.y = btn.y;
			_purchaseBtn.x = btn.x - _purchaseBtn.width - 5;
			_purchaseBtn.enabled = false;
			addChild(_purchaseBtn);
			
			Util.listen(_purchaseBtn, MouseEvent.CLICK, onPurchase);
			
			var creditDisplay:KeyValueDisplay = new KeyValueDisplay("Credits:");
			creditDisplay.x = _purchaseBtn.x - creditDisplay.width - 5;
			creditDisplay.y = _purchaseBtn.y;
			creditDisplay.value = UserData.instance.credits;
			
			addChild(creditDisplay);
			
			_costField = new KeyValueDisplay("Cost:");
			_costField.x = LEFT_MARGIN;
			_costField.y = creditDisplay.y;
			
			addChild(_costField);
			
			updatePurchaseButton();
		}
		
		private function onHullSelection(_unused:Event):void
		{
			const item:GameListItem = _listHulls.selection as GameListItem;
			_lastSelectedHull = item.cookie;

			const hull:TankPartData = TankPartData.getHull(_lastSelectedHull);
			populateUpgrades(_listHullUpgrades, hull);

			if (UserData.instance.owns(hull.id))
			{
				UserData.instance.currentHull = _lastSelectedHull;
			}
			_purchaseBtn.enabled = !UserData.instance.owns(hull.id) && UserData.instance.credits >= hull.baseStats.cost;
			
			populatePreview();
			updateStats();
			updatePurchaseButton();
		}
		private function onTurretSelection(_unused:Event):void
		{
			const item:GameListItem = _listTurrets.selection as GameListItem;
			_lastSelectedTurret = item.cookie;
			
			const turret:TankPartData = TankPartData.getTurret(_lastSelectedTurret);
			populateUpgrades(_listTurretUpgrades, turret);
			
			if (UserData.instance.owns(turret.id))
			{
				UserData.instance.currentTurret = _lastSelectedTurret;
			}
			_purchaseBtn.enabled = !UserData.instance.owns(turret.id) && UserData.instance.credits >= turret.baseStats.cost;;
			
			populatePreview();
			updateStats();
			updatePurchaseButton();
		}
		// KAI: if you really wanted to eliminate this copy/paste, you need to start with the user
		// data - put all the array and lookup nonsense into a single class, add some methods, stamp out multiple
		// instances of that type for each type of merchandise, then let the changes trickle down to here.
		private function onHullUpgradeSelection(_unused:Event):void
		{
			Util.ASSERT(UserData.instance.currentHull == _lastSelectedHull);
			
			const item:GameListItem = _listHullUpgrades.selection as GameListItem;
			const upgrade:TankPartData = item ? TankPartData.getHull(UserData.instance.currentHull).getUpgrade(item.cookie) : null;

			_listHulls.selectItem(null);

			updateStats();
			updatePurchaseButton();
		}
		private function onTurretUpgradeSelection(_unused:Event):void
		{
			Util.ASSERT(UserData.instance.currentTurret == _lastSelectedTurret);

			const item:GameListItem = _listTurretUpgrades.selection as GameListItem;
			const upgrade:TankPartData = item ? TankPartData.getTurret(UserData.instance.currentTurret).getUpgrade(item.cookie) : null;
			
			_listTurrets.selectItem(null);
			_purchaseBtn.enabled = UserData.instance.credits >= upgrade.baseStats.cost;

			updateStats();
			updatePurchaseButton();
		}
		private function onHullRoll(_unused:Event):void
		{
			updateStats();
		}
		private function onTurretRoll(_unused:Event):void
		{
			updateStats();
		}
		private function onHullUpgradeRoll(_unused:Event):void
		{
			updateStats();
		}
		private function onTurretUpgradeRoll(_unused:Event):void
		{
			updateStats();
		}
		static private var po_stats:VehiclePartStats = new VehiclePartStats(0, 0, 0, 0, 0);
		static private var po_compareStats:VehiclePartStats = new VehiclePartStats(0, 0, 0, 0, 0);
		private function updateStats():void
		{
			po_stats.reset();
			po_compareStats.reset();

			// hull and turret
			const selectedHull:TankPartData = TankPartData.getHull(_lastSelectedHull);
			const selectedTurret:TankPartData = TankPartData.getTurret(_lastSelectedTurret);

			po_stats.add(selectedHull.baseStats);
			po_stats.add(selectedTurret.baseStats);

			var rolledItem:GameListItem = _listHulls.rolledOverItem as GameListItem;
			po_compareStats.add(rolledItem ? TankPartData.getHull(rolledItem.cookie).baseStats : selectedHull.baseStats);

			rolledItem = _listTurrets.rolledOverItem as GameListItem;
			po_compareStats.add (rolledItem ? TankPartData.getTurret(rolledItem.cookie).baseStats : selectedTurret.baseStats);

			// upgrades
			accumulateUpgrade(_listHullUpgrades, selectedHull, 0);
			accumulateUpgrade(_listHullUpgrades, selectedHull, 1);
			accumulateUpgrade(_listTurretUpgrades, selectedTurret, 0);
			accumulateUpgrade(_listTurretUpgrades, selectedTurret, 1);
				
			// now perform the compare
			po_stats.armor *= 0.75;
			po_compareStats.armor *= 0.75;  // fixing problem w/ the data
			
			_stats.stats = po_stats;
			_stats.compare = po_compareStats;
			_stats.title = "TANK"
		}
		static private function accumulateUpgrade(list:GameList, tankPart:TankPartData, upgradeIndex:uint):void
		{
			const upgrade:VehiclePartStats = tankPart.getUpgrade(upgradeIndex).baseStats;
			const selectedItem:GameListItem = list.selection as GameListItem;
			const rolledItem:GameListItem = list.rolledOverItem as GameListItem;

			if (UserData.instance.owns(tankPart.id) && UserData.instance.owns(tankPart.getUpgrade(upgradeIndex).id) ||
			    (selectedItem && selectedItem.cookie == upgradeIndex))
			{
				// if we've bought or selected it
				po_stats.add(upgrade);
				po_compareStats.add(upgrade);
			}
			else if (rolledItem && rolledItem.cookie == upgradeIndex)
			{
				// no, but we've just rolled over it
				po_compareStats.add(upgrade);
			}
		}
		private function updatePurchaseButton():void
		{
			const ud:UserData = UserData.instance;
			var cost:uint;
			
			var item:GameListItem = _listHulls.selection as GameListItem;
			const hull:TankPartData = item ? TankPartData.getHull(item.cookie) : null;
			if (hull && !UserData.instance.owns(hull.id))
			{
				cost += hull.baseStats.cost;
			}
			item = _listTurrets.selection as GameListItem;
			const turret:TankPartData = item ? TankPartData.getTurret(item.cookie) : null;
			if (turret && !UserData.instance.owns(turret.id))
			{
				cost += turret.baseStats.cost;
			}
			item = _listHullUpgrades.selection as GameListItem;
			var upgrade:TankPartData = item ? TankPartData.getHull(_lastSelectedHull).getUpgrade(item.cookie) : null;
			if (upgrade && !UserData.instance.owns(upgrade.id))
			{
				cost += upgrade.baseStats.cost;
			}
			item = _listTurretUpgrades.selection as GameListItem;
			upgrade = item ? TankPartData.getTurret(_lastSelectedTurret).getUpgrade(item.cookie) : null;
			if (upgrade && !UserData.instance.owns(upgrade.id))
			{
				cost += upgrade.baseStats.cost;
			}

			const afford:Boolean = ud.credits >= cost;
			_purchaseBtn.enabled = cost && afford;
			_costField.value = cost;
			
			_costField.valColor = afford ? Consts.CREDIT_FIELD_COLOR : 0xff0000;
		}
		private function onPurchase(e:Event):void
		{
			updatePurchaseButton();
			
			const ud:UserData = UserData.instance;
			var cost:uint;
			
			var item:GameListItem = _listHulls.selection as GameListItem;
			const hull:TankPartData = item ? TankPartData.getHull(item.cookie) : null;
			if (hull && !UserData.instance.owns(hull.id))
			{
				ud.purchasePart(hull, hull.baseStats.cost); 
				ud.currentHull = item.cookie;
			}
			item = _listTurrets.selection as GameListItem;
			const turret:TankPartData = item ? TankPartData.getTurret(item.cookie) : null;
			if (turret && !UserData.instance.owns(turret.id))
			{
				ud.purchasePart(turret, turret.baseStats.cost);
				ud.currentTurret = item.cookie;
			}
			item = _listHullUpgrades.selection as GameListItem;
			var upgrade:TankPartData = item ? TankPartData.getHull(_lastSelectedHull).getUpgrade(item.cookie) : null;
			if (upgrade && !UserData.instance.owns(upgrade.id))
			{
				ud.purchasePart(upgrade, upgrade.baseStats.cost);
			}
			item = _listTurretUpgrades.selection as GameListItem;
			upgrade = item ? TankPartData.getTurret(_lastSelectedTurret).getUpgrade(item.cookie) : null;
			if (upgrade && !UserData.instance.owns(upgrade.id))
			{
				ud.purchasePart(upgrade, upgrade.baseStats.cost);
			}

			//HAAAAACK /////////////////////////////
			//HAAAAACK /////////////////////////////
			//HAAAAACK /////////////////////////////
			// omg programmer hell
			var refresh:UpgradeTankDialog = new UpgradeTankDialog;
			refresh.x = x;
			refresh.y = y;
			refresh._listHulls.scrollPos = _listHulls.scrollPos;
			refresh._listTurrets.scrollPos = _listTurrets.scrollPos;
			
			dispatchEvent(new GlobalUIEvent(GlobalUIEvent.PURCHASE_MADE, refresh));

			parent.addChildAt(refresh, parent.getChildIndex(this) + 1);
			parent.removeChild(this);
		}
		private function onDone(e:Event):void
		{
			UIUtil.closeDialog(this);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
import karnold.utils.FrameTimer;
import karnold.utils.MathUtil;

import scripts.TankActor;

final internal class PreviewStuff
{
	public var tank:TankActor;
	public function start():void { _timer.startPerFrame(); }

	private var _rotationSpeed:Number = 0;
	private var _turretRotationSpeed:Number = 0;
	private var _timer:FrameTimer = new FrameTimer(onFrame);
	private function onFrame():void
	{
		tank.treadFrame();
		tank.displayObject.rotation += _rotationSpeed;
		tank.turretRotation += _turretRotationSpeed;
		
		//KAI: this effect is super awesome and needs to be a behavior
		//KAI: speaking of that - we should be able to do this with Actors and behaviors w/o hacking frames
		if (Math.abs(_turretRotationSpeed) < 0.1)
		{
			_turretRotationSpeed = MathUtil.random(-2, 2);
		}
		_turretRotationSpeed *= 0.99;
		if (Math.abs(_rotationSpeed) < 0.1)
		{
			_rotationSpeed = MathUtil.random(-2, 2);
		}
		_rotationSpeed *= 0.99;
	}
}