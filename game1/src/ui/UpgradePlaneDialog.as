package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gameData.BaseStats;
	
	import karnold.utils.Util;

	public class UpgradePlaneDialog extends GameDialog
	{
		public function UpgradePlaneDialog()
		{
			super(false);
			
			title = "PLANE HANGAR";
			
			addShipList();
			addUpgradeList();
			addStats();
			addBottomButtons();

			render();

			populateShipList();
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
		private function populateShipList():void
		{
			for (var i:uint = 0; i < PlaneEntry.entries.length; ++i)
			{
				const entry:PlaneEntry = PlaneEntry.entries[i];
				
				var item:GameListItem = new GameListItem(ActorAssetManager.createShipRaw(entry.assetIndex), LIST_HEIGHT, LIST_HEIGHT, i);
				if (entry.assetIndex == 0)
				{
					var check:DisplayObject = AssetManager.instance.checkmark();
					check.x = item.width - check.width/2;
					check.y = check.height/2 + 5;
					item.addChild(check);
					
					_list.selectItem(item);
				}
				_list.addItem(item);
				
			}
			_list.render();
		}
		private function createMysteryItem():DisplayObject
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
			_upgradeList.addItem(_mysteryItems[0]);
			_upgradeList.addItem(_mysteryItems[1]);
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
		
		private function addBottomButtons():void
		{
			var credit:DisplayObjectContainer = UIUtil.createCreditDisplay();
			
			credit.x = width - credit.width;
			credit.y = _upgradeGroup.y;
			
			addChild(credit);
			
			var done:DisplayObject = GameButton.create("Done", true, 24, 1);
			done.y = height - done.height - 3;
			Util.listen(done, MouseEvent.CLICK, onDone);

			var purchase:GameButton = GameButton.create("Purchase", true, 24, 1);
			purchase.y = done.y - purchase.height - 3;
			purchase.x = width - purchase.width;
			purchase.enabled = false;

			done.x = purchase.x;
			done.width = purchase.width;
			
			addChild(purchase);
			addChild(done);
		}
		
		private function onShipSelected(e:Event):void
		{
			const item:GameListItem = _list.selection as GameListItem;
			_upgradeList.clearItems();
			
			const planeEntry:PlaneEntry = PlaneEntry.entries[item.cookie];
			if (planeEntry.upgrades)
			{
				_upgradeList.addItem(new GameListItem(ActorAssetManager.createShipRaw(PlaneEntry(planeEntry.upgrades[0]).assetIndex), LIST_HEIGHT, LIST_HEIGHT, 0));
				_upgradeList.addItem(new GameListItem(ActorAssetManager.createShipRaw(PlaneEntry(planeEntry.upgrades[1]).assetIndex), LIST_HEIGHT, LIST_HEIGHT, 1));
			}
			else
			{
				_upgradeList.addItem(_mysteryItems[0]);
				_upgradeList.addItem(_mysteryItems[1]);
			}
			_upgradeList.render();
		}
		private function onUpgradeSelected(e:Event):void
		{
			const item:GameListItem = _upgradeList.selection as GameListItem;
			_list.selectItem(null);
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
	public var upgrades:Array;

	public function PlaneEntry(name:String, index:uint, baseStats:BaseStats)
	{
		this.name = name;
		this.assetIndex = index;
		this.baseStats = baseStats;
	}
	static private var s_entries:Array;
	static private function pushUpgrade(entry:PlaneEntry):void
	{
		var parent:PlaneEntry = s_entries[s_entries.length-1];
		if (!parent.upgrades)
		{
			parent.upgrades = [];
		}
		parent.upgrades.push(entry);
	}
	static public function get entries():Array
	{
		if (!s_entries)
		{
			s_entries = [];
			s_entries.push(new PlaneEntry("Hornet", 0, 	new BaseStats(0.2, 0.4, 0.3, 0.8, 1000)));
			pushUpgrade(new PlaneEntry(null, 1, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 2, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Jem", 3, 		new BaseStats(0.2, 0, 0, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 4, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 5, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Yango", 6, 		new BaseStats(0.3, 0.4, 0.3, 0.2, 3000)));
			pushUpgrade(new PlaneEntry(null, 7, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 8, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Osprey", 9, 	new BaseStats(0.4, 0.4, 0.3, 0.8, 4000)));
			pushUpgrade(new PlaneEntry(null, 10, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 11, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Diptera", 12, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 5000)));
			pushUpgrade(new PlaneEntry(null, 13, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 14, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Cygnus X-1", 15, new BaseStats(0.3, 0.4, 0.3, 0.8, 6000)));
			pushUpgrade(new PlaneEntry(null, 16, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 17, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Ghost", 18, 		new BaseStats(0.6, 0.4, 0.3, 0.8, 7000)));
			pushUpgrade(new PlaneEntry(null, 19, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 20, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Attacus", 21, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 8000)));
			pushUpgrade(new PlaneEntry(null, 22, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 23, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("???", 24, 		new BaseStats(0.1, 0.4, 0.3, 0.8, 9000)));
			s_entries.push(new PlaneEntry("Stealth", 25, 	new BaseStats(0.02, 0.4, 0.3, 0.8, 10000)));
			pushUpgrade(new PlaneEntry(null, 26, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 27, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Rocinante", 28, 	new BaseStats(0.2, 0.4, 0.3, 0.8, 11000)));
			pushUpgrade(new PlaneEntry(null, 29, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 30, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Esox", 31, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 12000)));
			pushUpgrade(new PlaneEntry(null, 32, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 33, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			s_entries.push(new PlaneEntry("Corvid", 34, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 12000)));
			pushUpgrade(new PlaneEntry(null, 35, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
			pushUpgrade(new PlaneEntry(null, 36, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)));
		}

		return s_entries;
	}
}


final internal class TEMPDATA
{
	
}