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
				onShipSelected(null);
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
			
			//HAAAAACK
			var refresh:UpgradePlaneDialog = new UpgradePlaneDialog;
			refresh.x = x;
			refresh.y = y;
			
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
					addCheck(upgradeItem);
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
		private function onShipSelected(_unused:Event):void
		{
			const item:GameListItem = _list.selection as GameListItem;
			populateUpgradeList(item.cookie);
			shipSelectedCommon(item.cookie);
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
		}
		private function onDone(e:Event):void
		{
			UIUtil.closeDialog(parent, this);
		}
	}
}
import gameData.BaseStats;
