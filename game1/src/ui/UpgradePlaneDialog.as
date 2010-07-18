package ui
{
	import flash.display.DisplayObject;

	public class UpgradePlaneDialog extends GameDialog
	{
		public function UpgradePlaneDialog()
		{
			super(false);
			
			title = "PLANE HANGAR";
			
			addShipList();
			addBottomButtons();
			
			var foo:DisplayObject = AssetManager.instance.arrow();
			foo.x = 100;
			foo.y = 200;
			foo.scaleX = .5;
			foo.scaleY = .5;
			addChild(foo);
			
			foo = AssetManager.instance.checkmark();
			foo.x = 150;
			foo.y = 200;
			addChild(foo);
			
			foo = AssetManager.instance.lock();
			foo.x = 200;
			foo.y = 200;
			addChild(foo);

			foo = AssetManager.instance.question();
			foo.x = 250;
			foo.y = 200;
			addChild(foo);

			render();
		}
		static private const LEFT_MARGIN:Number = 10;
		static private const LIST_HEIGHT:Number = 100;
		static private const LIST_WIDTH:Number = 400;
		private function addShipList():void
		{
			UIUtil.addGroupBox(this, "Ships", LEFT_MARGIN, TOP_MARGIN, LIST_WIDTH, LIST_HEIGHT + 25);

			var list:GameList = new GameList;
			for (var i:uint = 0; i < 20; ++i)
			{
				list.addItem(new GameListItem(ActorAssetManager.createShip(i), LIST_HEIGHT, LIST_HEIGHT));
			}
			
			list.x = LEFT_MARGIN + 5;
			list.y = TOP_MARGIN + 20;
			list.setBounds(LIST_WIDTH-15, LIST_HEIGHT);
			list.render(0);
			
			addChild(list);
		}
		
		private function addBottomButtons():void
		{
			
		}
	}
}