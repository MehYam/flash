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
	import karnold.utils.FrameTimer;
	import karnold.utils.Util;
	
	import scripts.TankActor;

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
				_listHulls.addItem(item);
				if (UserData.instance.purchasedHulls[index])
				{
					UIUtil.addCheckmark(item);
				}
				if (index == UserData.instance.currentHull)
				{
					Util.ASSERT(UserData.instance.purchasedHulls[index]);
					_listHulls.selectItem(item);
					_lastSelectedHull = index;
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
			
			const iHull:uint = UserData.instance.currentHull;
			populateUpgrades(_listHullUpgrades, UserData.instance.purchasedHulls[iHull], TankPartData.hulls[iHull], UserData.instance.purchasedHullUpgrades[iHull]);
			addChild(_listHullUpgrades);

			Util.listen(_listHullUpgrades, Event.SELECT, onHullUpgradeSelection);
			Util.listen(_listHullUpgrades, MouseEvent.ROLL_OVER, onHullUpgradeRoll);
			Util.listen(_listHullUpgrades, MouseEvent.ROLL_OUT, onHullUpgradeRoll);
		}

		private function populateUpgrades(list:GameList, own:Boolean, tankPart:TankPartData, purchaseMatrix:Array):void
		{
			list.clearItems();
			if (own)
			{
				addUpgrade(list, tankPart.getUpgrade(0).name, purchaseMatrix[0], 0);
				addUpgrade(list, tankPart.getUpgrade(1).name, purchaseMatrix[1], 1);
			}
			else
			{
				list.addItem(UIUtil.createMysteryGameListItem(LIST_HEIGHT-25));
			}
			
			list.setBounds(UPGRADE_WIDTH, LIST_HEIGHT); 
			list.renderVert();
		}
		static private function addUpgrade(list:GameList, text:String, purchased:Boolean, cookie:uint):void
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
			if (purchased)
			{
				upgrade.mouseEnabled = false;
				upgrade.alpha = 0.5;
				UIUtil.addCheckmark(upgrade);
			}
			list.addItem(upgrade);
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
				_listTurrets.addItem(item);
				if (UserData.instance.purchasedHulls[index])
				{
					UIUtil.addCheckmark(item);
				}
				if (index == UserData.instance.currentTurret)
				{
					Util.ASSERT(UserData.instance.purchasedTurrets[index]);
					_listTurrets.selectItem(item);
					_lastSelectedTurret = index;
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

			const iTurret:uint = UserData.instance.currentTurret;
			populateUpgrades(_listTurretUpgrades, UserData.instance.purchasedTurrets[iTurret], TankPartData.turrets[iTurret], UserData.instance.purchasedTurretUpgrades[iTurret]);
			
			addChild(_listTurretUpgrades);

			Util.listen(_listTurretUpgrades, Event.SELECT, onTurretUpgradeSelection);
			Util.listen(_listTurretUpgrades, MouseEvent.ROLL_OVER, onTurretUpgradeRoll);
			Util.listen(_listTurretUpgrades, MouseEvent.ROLL_OUT, onTurretUpgradeRoll);
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
			_stats = new StatList(new BaseStats(0, 0, 0, 0, 0), LIST_HEIGHT);
			_stats.x = 470;
			_stats.y = LIST_HEIGHT + 50;
			
			addChild(_stats);
			
			updateStats();
		}
		private var _purchaseBtn:GameButton;
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
			
			var fieldParent:DisplayObjectContainer = new CreditDisplay;
			
			fieldParent.x = _purchaseBtn.x - fieldParent.width - 5;
			fieldParent.y = _purchaseBtn.y;
			
			addChild(fieldParent);
		}
		
		private function onHullSelection(_unused:Event):void
		{
			const item:GameListItem = _listHulls.selection as GameListItem;
			_lastSelectedHull = item.cookie;

			const hull:TankPartData = item ? TankPartData.getHull(_lastSelectedHull) : null;
			const own:Boolean = UserData.instance.purchasedHulls[_lastSelectedHull];
			populateUpgrades(_listHullUpgrades, own, TankPartData.hulls[_lastSelectedHull], UserData.instance.purchasedHullUpgrades[_lastSelectedHull]);

			if (own)
			{
				UserData.instance.currentHull = _lastSelectedHull;
			}
			_purchaseBtn.enabled = !own && UserData.instance.credits >= hull.baseStats.cost;;
			
			populatePreview();
			updateStats();
		}
		private function onTurretSelection(_unused:Event):void
		{
			const item:GameListItem = _listTurrets.selection as GameListItem;
			_lastSelectedTurret = item.cookie;
			
			const turret:TankPartData = item ? TankPartData.getHull(_lastSelectedTurret) : null;
			const own:Boolean = UserData.instance.purchasedTurrets[_lastSelectedTurret];
			populateUpgrades(_listTurretUpgrades, own, TankPartData.turrets[_lastSelectedTurret], UserData.instance.purchasedTurretUpgrades[_lastSelectedTurret]);
			
			if (own)
			{
				UserData.instance.currentTurret = _lastSelectedTurret;
			}
			_purchaseBtn.enabled = !own && UserData.instance.credits >= turret.baseStats.cost;;
			
			populatePreview();
			updateStats();
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
			_purchaseBtn.enabled = UserData.instance.credits >= upgrade.baseStats.cost;

			updateStats();
		}
		private function onTurretUpgradeSelection(_unused:Event):void
		{
			Util.ASSERT(UserData.instance.currentTurret == _lastSelectedTurret);

			const item:GameListItem = _listTurretUpgrades.selection as GameListItem;
			const upgrade:TankPartData = item ? TankPartData.getTurret(UserData.instance.currentTurret).getUpgrade(item.cookie) : null;
			
			_listTurrets.selectItem(null);
			_purchaseBtn.enabled = UserData.instance.credits >= upgrade.baseStats.cost;

			updateStats();
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
		static private var po_stats:BaseStats = new BaseStats(0, 0, 0, 0, 0);
		static private var po_compareStats:BaseStats = new BaseStats(0, 0, 0, 0, 0);
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
			accumulateUpgrade(_listHullUpgrades, UserData.instance.purchasedHullUpgrades, selectedHull, _lastSelectedHull, 0);
			accumulateUpgrade(_listHullUpgrades, UserData.instance.purchasedHullUpgrades, selectedHull, _lastSelectedHull, 1);
			accumulateUpgrade(_listTurretUpgrades, UserData.instance.purchasedTurretUpgrades, selectedTurret, _lastSelectedTurret, 0);
			accumulateUpgrade(_listTurretUpgrades, UserData.instance.purchasedTurretUpgrades, selectedTurret, _lastSelectedTurret, 1);
				
			// now perform the compare
			_stats.stats = po_stats;
			_stats.compare = po_compareStats;
		}
		static private function accumulateUpgrade(list:GameList, purchaseIndex:Array, tankPart:TankPartData, tankPartIndex:uint, upgradeIndex:uint):void
		{
			const upgrade:BaseStats = tankPart.getUpgrade(upgradeIndex).baseStats;
			const selectedItem:GameListItem = list.selection as GameListItem;
			const rolledItem:GameListItem = list.rolledOverItem as GameListItem;

			if ((purchaseIndex[tankPartIndex] && purchaseIndex[tankPartIndex][upgradeIndex]) || 
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
		private function onPurchase(e:Event):void
		{
			
		}
		private function onDone(e:Event):void
		{
			UIUtil.closeDialog(parent, this);
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