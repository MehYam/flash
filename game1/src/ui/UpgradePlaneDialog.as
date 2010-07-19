package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
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
			_list.setBounds(LIST_WIDTH-15, LIST_HEIGHT);
			
			addChild(_list);
		}
		private function populateShipList():void
		{
			for (var i:uint = 0; i < 37; ++i)
			{
				if ((i % 3) == 0)
				{
					var item:GameListItem = new GameListItem(ActorAssetManager.createShip(i), LIST_HEIGHT, LIST_HEIGHT);
					if (i == 0)
					{
						var check:DisplayObject = AssetManager.instance.checkmark();
						check.x = item.width - check.width/2;
						check.y = check.height/2;
						item.addChild(check);
						
						item.selected = true;
					}
					_list.addItem(item);
				}
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
			lock.x = item.width - 20;
			lock.y = item.height - 20;
			item.addChild(lock);
			
			return item;
		}
		private var _upgradeGroup:DisplayObject;
		private function addUpgradeList():void
		{
			_upgradeGroup = UIUtil.addGroupBox(this, "Upgrades", LEFT_MARGIN, TOP_MARGIN + LIST_HEIGHT + LIST_PADDING + 10, 225, LIST_HEIGHT + LIST_PADDING);

			var item:DisplayObject = createMysteryItem();			
			item.y = _upgradeGroup.y + 25;
			item.x = _upgradeGroup.x + 3;
			
			var item2:DisplayObject = createMysteryItem();
			item2.y = item.y;
			item2.x = item.x + item.width + 3;
			
			var arrow:DisplayObject = AssetManager.instance.arrow();
			arrow.x = item2.x;
			arrow.y = item2.y + item2.height/2;

			addChild(item);
			addChild(item2);
			addChild(arrow);
		}
		private function addStats():void
		{
			var stats:DisplayObject = new StatList(_upgradeGroup.height);
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
		
		private function onDone(e:Event):void
		{
			UIUtil.closeDialog(parent, this);
		}
	}
}