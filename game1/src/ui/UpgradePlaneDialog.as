package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Video;
	
	import gameData.BaseStats;
	import gameData.PlaneData;
	import gameData.UserData;
	
	import karnold.utils.ToolTipMgr;
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
			addBottomButtons(UserData.instance);

			render();

			populateShipList(UserData.instance);

			//KAI: THIS IS SO HORRIBLE
			if (PlaneData.getEntry(UserData.instance.currentPlane).upgrades)
			{
				onTopListSelection(null);
			}
			else
			{
				var parentPlane:uint = UserData.instance.currentPlane-1;
				if (!PlaneData.getEntry(parentPlane).upgrades)
				{
					--parentPlane;
				}
				populateUpgradeList(parentPlane);
				shipSelectedCommon(UserData.instance.currentPlane);
			}
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
			
			Util.listen(_list, Event.SELECT, onTopListSelection);
			Util.listen(_list, MouseEvent.ROLL_OVER, onItemRoll);
			Util.listen(_list, MouseEvent.ROLL_OUT, onItemRoll);
		}
		private function populateShipList(userData:UserData):void
		{
			var upgrades:uint;
			for (var i:uint = 0; i < PlaneData.entries.length; ++i)
			{
				if (upgrades)
				{
					// lameness
					--upgrades;
					continue;
				}
				const entry:PlaneData = PlaneData.entries[i];
				upgrades = entry.upgrades;
		
				var item:GameListItem = new GameListItem(ActorAssetManager.createShipRaw(entry.assetIndex), LIST_HEIGHT, LIST_HEIGHT, i);
				ToolTipMgr.instance.addToolTip(item, UIUtil.formatItemTooltip(entry.name, entry.baseStats.cost, UserData.instance.credits >= entry.baseStats.cost, null));
				if (userData.purchasedPlanes[i])
				{
					UIUtil.addCheckmark(item);
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
			Util.listen(_upgradeList, MouseEvent.ROLL_OVER, onItemRoll);
			Util.listen(_upgradeList, MouseEvent.ROLL_OUT, onItemRoll);

			if (!_mysteryItems)
			{
				_mysteryItems = [];
				_mysteryItems.push(UIUtil.createMysteryGameListItem(LIST_HEIGHT));
				_mysteryItems.push(UIUtil.createMysteryGameListItem(LIST_HEIGHT));
			}
			_upgradeList.setBounds(_upgradeGroup.width, _upgradeGroup.height);
			_upgradeList.render();

			var arrow:DisplayObject = AssetManager.instance.arrow();
			arrow.x = LIST_HEIGHT;
			arrow.y = LIST_HEIGHT/2;

			_upgradeList.addChild(arrow);
			
			_upgradeArrow = arrow;
		}
		
		private var _statList:StatList;
		private function addStats():void
		{
			_statList = new StatList(new BaseStats(.5, .1, .2, .8, .3), _upgradeGroup.height);
			_statList.x = _upgradeGroup.x + _upgradeGroup.width + 10;
			_statList.y = _upgradeGroup.y;
			
			addChild(_statList);
		}
		private var _purchaseBtn:GameButton;
		private function addBottomButtons(userData:UserData):void
		{
			var credit:KeyValueDisplay = new KeyValueDisplay("Credits:");
			credit.value = userData.credits;
			credit.x = width - credit.width;
			credit.y = _upgradeGroup.y;
			
			addChild(credit);
			
			var done:DisplayObject = GameButton.create("Done", true, 24, 1);
			done.y = height - done.height - 3;
			Util.listen(done, MouseEvent.CLICK, onDone);

			_purchaseBtn = GameButton.create("Purchase", true, 24, 1);
			_purchaseBtn.y = done.y - _purchaseBtn.height - 3;
			_purchaseBtn.x = width - _purchaseBtn.width;
			_purchaseBtn.enabled = false;
			Util.listen(_purchaseBtn, MouseEvent.CLICK, onPurchase);

			done.x = _purchaseBtn.x;
			done.width = _purchaseBtn.width;
			
			addChild(_purchaseBtn);
			addChild(done);
		}
		
		private function onPurchase(_unused:Event):void
		{
			Util.ASSERT(UserData.instance.currentPlane != _currentSelected);

			const plane:PlaneData = PlaneData.getEntry(_currentSelected);
			const canAfford:Boolean = plane.baseStats.cost <= UserData.instance.credits; 

			Util.ASSERT(canAfford);
			
			if (canAfford)
			{
				UserData.instance.purchasePlane(_currentSelected, plane.baseStats.cost);
				UserData.instance.currentPlane = _currentSelected;
			}
			
			//HAAAAACK /////////////////////////////
			//HAAAAACK /////////////////////////////
			//HAAAAACK /////////////////////////////
			// omg programmer hell
			var refresh:UpgradePlaneDialog = new UpgradePlaneDialog;
			refresh.x = x;
			refresh.y = y;
			refresh._list.scrollPos = _list.scrollPos;

			parent.addChildAt(refresh, parent.getChildIndex(this) + 1);
			parent.removeChild(this);
		}

		private function addUpgradeItem(forItem:uint, slot:uint):void
		{
			if (UserData.instance.purchasedPlanes[forItem])
			{
				const targetItem:uint = forItem + 1;
				var upgradeItem:GameListItem = new GameListItem(ActorAssetManager.createShipRaw(PlaneData(PlaneData.entries[targetItem]).assetIndex), LIST_HEIGHT, LIST_HEIGHT, targetItem);
				if (UserData.instance.purchasedPlanes[forItem+1])
				{
					UIUtil.addCheckmark(upgradeItem);
				}
				_upgradeList.addItem(upgradeItem);
				if (targetItem == UserData.instance.currentPlane)
				{
					_upgradeList.selectItem(upgradeItem);
				}
			}
			else
			{
				_upgradeList.addItem(_mysteryItems[slot]);
			}
		}
		private function onTopListSelection(_unused:Event):void
		{
			const item:GameListItem = _list.selection as GameListItem;
			populateUpgradeList(item.cookie);
			shipSelectedCommon(item.cookie);
			
			_upgradeList.selectItem(null);
		}
		private function populateUpgradeList(forPlane:uint):void
		{
			// repopulate the upgrade list
			_upgradeList.clearItems();
			
			const planeData:PlaneData = PlaneData.entries[forPlane];
			if (planeData.upgrades)
			{
				Util.ASSERT(planeData.upgrades == 2);
				
				addUpgradeItem(forPlane, 0);
				addUpgradeItem(forPlane+1, 1);
				_upgradeArrow.visible = true;
			}
			else
			{
				_upgradeArrow.visible = false;
			}
			_upgradeList.render();
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

			const planeData:PlaneData = PlaneData.entries[selection];
			if (UserData.instance.purchasedPlanes[selection])
			{
				UserData.instance.currentPlane = selection;
			}
			else if (planeData.baseStats.cost <= UserData.instance.credits)
			{
				_purchaseBtn.enabled = true;
			}
			
			_statList.stats = planeData.baseStats;
			_statList.compare = null;
		}
		private function onItemRoll(e:Event):void
		{
			const item:GameListItem = (_list.rolledOverItem || _upgradeList.rolledOverItem) as GameListItem;
			const stats:BaseStats = item ? PlaneData.getEntry(item.cookie).baseStats : null;
			
			_statList.compare = stats;
		}
		private function onDone(e:Event):void
		{
			UIUtil.closeDialog(parent, this);
		}
	}
}
import gameData.BaseStats;
