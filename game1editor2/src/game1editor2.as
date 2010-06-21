package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import karnold.tile.TiledBackground;
	import karnold.utils.Input;
	import karnold.utils.Location;
	import karnold.utils.Utils;
	
	public class game1editor2 extends Sprite
	{
		private var _map:TiledBackground;
		private var _imageSelect:ImageSelect;
		private var _playArea:Sprite;
		private var _input:Input;
		private var _camera:Point = new Point(0, 0);
		public function game1editor2()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			Utils.listen(stage, KeyboardEvent.KEY_DOWN, onKeyDown);

			_imageSelect = new ImageSelect;
			_imageSelect.scaleX = 1.5;
			_imageSelect.scaleY = 1.5;
			addChild(_imageSelect);
			
			_playArea = new Sprite;
			_playArea.graphics.beginFill(0xaaaaaa);
			_playArea.graphics.lineStyle(0, 0x0000ff);
			_playArea.graphics.drawRect(0, 0, 800, 800);
			_playArea.graphics.endFill();

			_playArea.x = _imageSelect.x + _imageSelect.width + 5;
			_playArea.y = _imageSelect.y;
			addChild(_playArea);

			Utils.listen(_playArea, MouseEvent.MOUSE_DOWN, onSetTile);
			
			_map = new TiledBackground(_playArea, new BitmapTileFactory, 200, 200, _playArea.width, _playArea.height);
		}
		
		private function onSetTile(e:MouseEvent):void
		{
			Utils.listen(_playArea, MouseEvent.MOUSE_MOVE, onSetTile);
			Utils.listen(stage, MouseEvent.MOUSE_UP, onStopDragging);
			Utils.listen(stage, Event.MOUSE_LEAVE, onStopDragging);

			var loc:Location = new Location;
			_map.pointToLocation(new Point(e.localX, e.localY), loc);

			const obj:DisplayObject = DisplayObject(_map.tilesArray.lookup(loc.x, loc.y));

			if (_imageSelect.selection == ImageSelect.NULL_SELECTION)
			{
				_map.clearTile(loc.x, loc.y);
			}
			else if (!obj || BitmapTileFactory.tileToID(obj) != _imageSelect.selection)
			{
				_map.putTile(_imageSelect.selection, loc.x, loc.y);
			}
			
			_map.setCamera(_camera);
		}
		private function onStopDragging(e:Event):void
		{
			_playArea.removeEventListener(MouseEvent.MOUSE_MOVE, onSetTile);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStopDragging);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStopDragging);
		}
		
		static private const DELTA:uint = 10;
		private function onKeyDown(e:KeyboardEvent):void
		{
			var diffX:int;
			var diffY:int;
			switch(e.keyCode){
			case Input.KEY_DOWN:
				diffY = DELTA;
				break;
			case Input.KEY_LEFT:
				diffX = -DELTA;
				break;
			case Input.KEY_UP:
				diffY = -DELTA;
				break;
			case Input.KEY_RIGHT:
				diffX = DELTA;
				break;
			}
			_camera.offset(diffX, diffY);
			_map.setCamera(_camera);
		}
	}
}