package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Video;
	
	import gameData.BaseStats;
	
	import karnold.utils.Util;

	public class UpgradePlaneDialog extends GameDialog
	{
private var _sampleUserData:UserData = new UserData;
		public function UpgradePlaneDialog()
		{
_sampleUserData.credits = 10000;
_sampleUserData.currentPlane = 3;
_sampleUserData.purchasedPlanes[0] = true;
_sampleUserData.purchasedPlanes[1] = true;
_sampleUserData.purchasedPlanes[3] = true;
_sampleUserData.purchasedPlanes[9] = true;
_sampleUserData.purchasedPlanes[10] = true;
_sampleUserData.purchasedPlanes[11] = true;
			super(false);
			
			title = "PLANE HANGAR";
			
			addShipList();
			addUpgradeList();
			addStats();
			addBottomButtons(_sampleUserData);

			render();

			populateShipList(_sampleUserData);
			
			onShipSelected(null);
		}
		static private const LEFT_MARGIN:Number = 10;
		static private const LIST_HEIGHT:Number = 100;
		static private const LIST_WIDTH:Number = 530;
		static private const LIST_PADDING:Number = 25;
		private var _list:GameList;
		private function addShipList():void
		{
			UIUtil.addGroupBox(this, "Ships", LEFT_MARGIN, TOP_MARGIN, LIST_WIDTH, LIST_HEIGHT + LIST_PADDING);

			_list = new GameList;
			
			_list.x = LEFT_MARGIN + 5;
			_list.y = TOP_MARGIN + 20;
			_list.setBounds(LIST_WIDTH-20, LIST_HEIGHT);
			
			addChild(_list);
			
			Util.listen(_list, Event.SELECT, onShipSelected);
		}
		static private function addCheck(item:GameListItem):void
		{
			var check:DisplayObject = AssetManager.instance.checkmark();
			check.x = item.width - check.width/2;
			check.y = check.height/2 + 5;
			item.addChild(check);
		}
		private function populateShipList(userData:UserData):void
		{
			var upgrades:uint;
			for (var i:uint = 0; i < PlaneEntry.entries.length; ++i)
			{
				if (upgrades)
				{
					// lameness
					--upgrades;
					continue;
				}
				const entry:PlaneEntry = PlaneEntry.entries[i];
				upgrades = entry.upgrades;
		
				var item:GameListItem = new GameListItem(ActorAssetManager.createShipRaw(entry.assetIndex), LIST_HEIGHT, LIST_HEIGHT, i);

				if (userData.purchasedPlanes[i])
				{
					addCheck(item);
				}
				if (i == userData.currentPlane)
				{
					Util.ASSERT(userData.purchasedPlanes[i]);
					_list.selectItem(item);
				}
				_list.addItem(item);
				
			}
			_list.render();
		}
		static private function createMysteryItem():DisplayObject
		{
			var question:DisplayObject = AssetManager.instance.question();
			question.scaleX = 1.3;
			question.scaleY = 1.3;
			
			var item:GameListItem = new GameListItem(question, LIST_HEIGHT, LIST_HEIGHT);
			var lock:DisplayObject = AssetManager.instance.lock();
			lock.x = item.width - 15;
			lock.y = item.height - 15;
			item.addChild(lock);

			item.mouseChildren = false;
			item.mouseEnabled = false;
			return item;
		}
		private var _upgradeGroup:DisplayObject;
		private var _upgradeList:GameList;
		private var _upgradeArrow:DisplayObject;
		private var _mysteryItems:Array;
		private function addUpgradeList():void
		{
			_upgradeGroup = UIUtil.addGroupBox(this, "Upgrades", LEFT_MARGIN, TOP_MARGIN + LIST_HEIGHT + LIST_PADDING + 10, 220, LIST_HEIGHT + LIST_PADDING);

			_upgradeList = new GameList(false);
			
			_upgradeList.x = _upgradeGroup.x + 5;
			_upgradeList.y = _upgradeGroup.y + 20;
			addChild(_upgradeList);
			
			Util.listen(_upgradeList, Event.SELECT, onUpgradeSelected);

			if (!_mysteryItems)
			{
				_mysteryItems = [createMysteryItem(), createMysteryItem()];
			}
			_upgradeList.setBounds(_upgradeGroup.width, _upgradeGroup.height);
			_upgradeList.render();

			var arrow:DisplayObject = AssetManager.instance.arrow();
			arrow.x = LIST_HEIGHT;
			arrow.y = LIST_HEIGHT/2;

			_upgradeList.addChild(arrow);
			
			_upgradeArrow = arrow;
		}
		private function addStats():void
		{
			var stats:DisplayObject = new StatList(new BaseStats(.5, .1, .2, .8, .3), _upgradeGroup.height);
			stats.x = _upgradeGroup.x + _upgradeGroup.width + 10;
			stats.y = _upgradeGroup.y;
			
			addChild(stats);
		}
		private var _purchaseBtn:GameButton;
		private var _creditDisplay:CreditDisplay;
		private function addBottomButtons(userData:UserData):void
		{
			_creditDisplay = new CreditDisplay;
			_creditDisplay.credits = userData.credits;
			_creditDisplay.x = width - _creditDisplay.width;
			_creditDisplay.y = _upgradeGroup.y;
			
			addChild(_creditDisplay);
			
			var done:DisplayObject = GameButton.create("Done", true, 24, 1);
			done.y = height - done.height - 3;
			Util.listen(done, MouseEvent.CLICK, onDone);

			_purchaseBtn = GameButton.create("Purchase", true, 24, 1);
			_purchaseBtn.y = done.y - _purchaseBtn.height - 3;
			_purchaseBtn.x = width - _purchaseBtn.width;
			_purchaseBtn.enabled = false;

			done.x = _purchaseBtn.x;
			done.width = _purchaseBtn.width;
			
			addChild(_purchaseBtn);
			addChild(done);
		}
		
		private function addUpgradeItem(forItem:uint, slot:uint):void
		{
			if (_sampleUserData.purchasedPlanes[forItem])
			{
				var upgradeItem:GameListItem = new GameListItem(ActorAssetManager.createShipRaw(PlaneEntry(PlaneEntry.entries[forItem+1]).assetIndex), LIST_HEIGHT, LIST_HEIGHT, forItem+1);
				if (_sampleUserData.purchasedPlanes[forItem+1])
				{
					addCheck(upgradeItem);
				}
				_upgradeList.addItem(upgradeItem);
			}
			else
			{
				_upgradeList.addItem(_mysteryItems[slot]);
			}
		}
		private function onShipSelected(_unused:Event):void
		{
			// repopulate the upgrade list
			const item:GameListItem = _list.selection as GameListItem;
			_upgradeList.clearItems();
			
			const planeEntry:PlaneEntry = PlaneEntry.entries[item.cookie];
			if (planeEntry.upgrades)
			{
				Util.ASSERT(planeEntry.upgrades == 2);
				
				addUpgradeItem(item.cookie, 0);
				addUpgradeItem(item.cookie+1, 1);
				_upgradeArrow.visible = true;
			}
			else
			{
				_upgradeArrow.visible = false;
			}
			_upgradeList.render();
			
			shipSelectedCommon(item.cookie);
		}
		private function onUpgradeSelected(e:Event):void
		{
			const item:GameListItem = _upgradeList.selection as GameListItem;
			_list.selectItem(null);
			
			shipSelectedCommon(item.cookie);
		}
		private var _currentSelected:uint;
		private function shipSelectedCommon(selection:uint):void
		{
			_currentSelected = selection;
			_purchaseBtn.enabled = false;

			var planeEntry:PlaneEntry = PlaneEntry.entries[selection];
			if (_sampleUserData.purchasedPlanes[selection])
			{
				_sampleUserData.currentPlane = selection;
			}
			else if (planeEntry.baseStats.cost <= _sampleUserData.credits)
			{
				_purchaseBtn.enabled = true;
			}
		}
		private function onDone(e:Event):void
		{
			UIUtil.closeDialog(parent, this);
		}
	}
}
import gameData.BaseStats;

final internal class PlaneEntry
{
	public var name:String;
	public var assetIndex:uint;
	public var baseStats:BaseStats;
	public var upgrades:uint;

	public function PlaneEntry(name:String, index:uint, baseStats:BaseStats, upgrades:uint = 0)
	{
		this.name = name;
		this.assetIndex = index;
		this.baseStats = baseStats;
		this.upgrades = upgrades;
	}
	static private var s_entries:Array;
	static public function get entries():Array
	{
		if (!s_entries)
		{
			s_entries = [];
			s_entries.push(new PlaneEntry("Hornet", 0,	new BaseStats(0.2, 0.4, 0.3, 0.8, 1000), 2));
			s_entries.push(new PlaneEntry(null, 1,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 2,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Jem", 3,		new BaseStats(0.2, 0, 0, 0.8, 2000), 2));
			s_entries.push(new PlaneEntry(null, 4,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 5,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Yango", 6,	new BaseStats(0.3, 0.4, 0.3, 0.2, 3000), 2));
			s_entries.push(new PlaneEntry(null, 7,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 8,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Osprey", 9,	new BaseStats(0.4, 0.4, 0.3, 0.8, 4000), 2));
			s_entries.push(new PlaneEntry(null, 10, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 11, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Diptera", 12, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 5000), 2));
			s_entries.push(new PlaneEntry(null, 13, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 14, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Cygnus X-1", 15, new BaseStats(0.3, 0.4, 0.3, 0.8, 6000), 2));
			s_entries.push(new PlaneEntry(null, 16, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 17, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Ghost", 18, 		new BaseStats(0.6, 0.4, 0.3, 0.8, 7000), 2));
			s_entries.push(new PlaneEntry(null, 19, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 20, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Attacus", 21, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 8000), 2));
			s_entries.push(new PlaneEntry(null, 22, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 23, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("???", 24, 		new BaseStats(0.1, 0.4, 0.3, 0.8, 9000)));
			s_entries.push(new PlaneEntry("Stealth", 25, 	new BaseStats(0.02, 0.4, 0.3, 0.8, 10000), 2));
			s_entries.push(new PlaneEntry(null, 26, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 27, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Rocinante", 28, 	new BaseStats(0.2, 0.4, 0.3, 0.8, 11000), 2));
			s_entries.push(new PlaneEntry(null, 29, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 30, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Esox", 31, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 12000), 2));
			s_entries.push(new PlaneEntry(null, 32, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 33, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Corvid", 34, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 12000), 2));
			s_entries.push(new PlaneEntry(null, 35, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry(null, 36, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
		}
		return s_entries;
	}
}

final internal class UserData
{
	public var purchasedPlanes:Array = [];
	public var credits:uint;
	public var levelReached:uint;
	public var currentPlane:uint;
}