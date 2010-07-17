package ui
{
	public class UpgradePlaneDialog extends GameDialog
	{
		public function UpgradePlaneDialog()
		{
			super(false);
			
			title = "PLANE HANGAR";
			
			addShipList();
			addBottomButtons();
			render();
		}
		static private const LEFT_MARGIN:Number = 10;
		static private const LIST_HEIGHT:Number = 125;
		static private const LIST_WIDTH:Number = 400;
		private function addShipList():void
		{
			UIUtil.addGroupBox(this, "Ships", LEFT_MARGIN, TOP_MARGIN, LIST_WIDTH, LIST_HEIGHT);

			var list:GameList = new GameList;
			list.addItem(ActorAssetManager.createShip(0));
			list.addItem(ActorAssetManager.createShip(1));
			list.addItem(ActorAssetManager.createShip(12));
			list.addItem(ActorAssetManager.createShip(2));
			list.addItem(ActorAssetManager.createShip(4));
			
			list.x = LEFT_MARGIN + 5;
			list.y = TOP_MARGIN + 20;
			list.setBounds(LIST_WIDTH-15, 70);
			list.render(0);
			
			addChild(list);
		}
		
		private function addBottomButtons():void
		{
			
		}
	}
}