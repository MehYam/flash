package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import karnold.tile.TiledBackground;
	import karnold.utils.Location;
	import karnold.utils.Utils;
	
	public class game1editor2 extends Sprite
	{
		private var _map:TiledBackground;
		public function game1editor2()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			var imageSelect:DisplayObject = new ImageSelect;
			imageSelect.scaleX = 1.5;
			imageSelect.scaleY = 1.5;
			addChild(imageSelect);
			
			var playArea:Sprite = new Sprite;
			playArea.graphics.beginFill(0xaaaaaa);
			playArea.graphics.lineStyle(0, 0x0000ff);
			playArea.graphics.drawRect(0, 0, 400, 400);
			playArea.graphics.endFill();

			playArea.x = imageSelect.x + imageSelect.width + 5;
			playArea.y = imageSelect.y;
			addChild(playArea);
			Utils.listen(playArea, MouseEvent.CLICK, onPlayClick);
			
			_map = new TiledBackground(playArea, new BitmapTileFactory, 40, 40, playArea.width, playArea.height);
//			_map.putTile(0, 0, 0);
//			_map.putTile(1, 1, 1);
//			_map.putTile(2, 1, 2);
			_map.setCamera(new Point(0, 0));
		}
		
		public function onPlayClick(e:MouseEvent):void
		{
			trace(e);
			
			var loc:Location = new Location;
			_map.pointToLocation(new Point(e.localX, e.localY), loc);
			_map.putTile(0, loc.x, loc.y);
			
			_map.setCamera(new Point(0, 0));
		}
	}
}