package
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Utils3D;
	
	import karnold.utils.Util;

	public class ImageSelect extends Sprite
	{
		static public const NULL_SELECTION:int = -1;
		public function ImageSelect()
		{
			var s:Sprite = createEraseSprite();
			addTile(s, -1);

			for (var i:int = 0; i < AssetManager.TILES; ++i)
			{
				var bmp:Bitmap = AssetManager.instance.getBitmap(i);
				var sprite:Sprite = new Sprite;
				sprite.addChild(bmp);

				addTile(sprite, i);
			}
		}

		static private const COLUMNS:uint = 2;
		private function addTile(obj:InteractiveObject, i:int):void
		{
			const row:uint = (i+1) % COLUMNS;
			const col:uint = (i+1) / COLUMNS;
			obj.x = (AssetManager.TILES_SIZE + 5) * row;
			obj.y = (AssetManager.TILES_SIZE + 5) * col;

			Util.listen(obj, MouseEvent.CLICK, onClick);
			Util.listen(obj, MouseEvent.ROLL_OVER, onRollOver);
			Util.listen(obj, MouseEvent.ROLL_OUT, onRollOut);
			
			obj.name = String(i);
			addChild(obj);
		}
		private static function createEraseSprite():Sprite
		{
			var sprite:Sprite = new Sprite;
			sprite.graphics.lineStyle(0, 0xff0000);
			sprite.graphics.beginFill(0);
			sprite.graphics.drawRect(0, 0, AssetManager.TILES_SIZE, AssetManager.TILES_SIZE);
			sprite.graphics.endFill();

			sprite.graphics.lineStyle(3, 0xff0000);
			sprite.graphics.moveTo(0, 0);
			sprite.graphics.lineTo(AssetManager.TILES_SIZE, AssetManager.TILES_SIZE);
			sprite.graphics.moveTo(AssetManager.TILES_SIZE, 0);
			sprite.graphics.lineTo(0, AssetManager.TILES_SIZE);
			return sprite;
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