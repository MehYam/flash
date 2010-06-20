package
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Utils3D;
	
	import karnold.utils.Utils;

	public class ImageSelect extends Sprite
	{
		public function ImageSelect()
		{
			const COLUMNS:uint = 2;
			for (var i:int = 0; i < AssetManager.TILES; ++i)
			{
				var bmp:Bitmap = AssetManager.instance.getBitmap(i);
				var sprite:Sprite = new Sprite;
				
				sprite.addChild(bmp);
				
				var col:uint = i % (AssetManager.TILES / COLUMNS);
				var row:uint = i % COLUMNS;
				sprite.x = (AssetManager.TILES_SIZE + 5) * row;
				sprite.y = (AssetManager.TILES_SIZE + 5) * col;

				Utils.listen(sprite, MouseEvent.CLICK, onClick);
				Utils.listen(sprite, MouseEvent.ROLL_OVER, onRollOver);
				Utils.listen(sprite, MouseEvent.ROLL_OUT, onRollOut);

				sprite.name = String(i);
				addChild(sprite);
			}
		}

		private var _selected:DisplayObject = null;
		private function onClick(e:Event):void
		{
			var newSelected:DisplayObject = DisplayObject(e.target);
			if (_selected && newSelected != _selected)
			{
				_selected.alpha = 1;
			}
			_selected = newSelected;
		}
		private function onRollOver(e:Event):void
		{
			DisplayObject(e.target).alpha = 0.5;
		}
		private function onRollOut(e:Event):void
		{
			var dobj:DisplayObject = DisplayObject(e.target);
			if (dobj != _selected)
			{
				dobj.alpha = 1;
			}
		}
		public function get selection():int
		{
			return _selected ? parseInt(_selected.name) : -1;
		}
	}
}