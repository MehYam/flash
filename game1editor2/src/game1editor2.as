package
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
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
		private var _text:TextField;
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
			_playArea.graphics.drawRect(0, 0, 800, 600);
			_playArea.graphics.endFill();

			_playArea.x = _imageSelect.x + _imageSelect.width + 5;
			_playArea.y = _imageSelect.y;
			addChild(_playArea);

			Utils.listen(_playArea, MouseEvent.MOUSE_DOWN, onSetTile);
			
			_map = new TiledBackground(_playArea, new BitmapTileFactory, 200, 200, _playArea.width, _playArea.height);
			
			var button:DisplayObject = createButton("Save", onSerialize);
			button.x = _playArea.x + _playArea.width;
			button.y = _playArea.y;
			addChild(button);
			
			var button2:DisplayObject = createButton("Load", onDeserialize);
			button2.x = button.x + button.width;
			button2.y = button.y;
			addChild(button2);

			_text = new TextField;
			_text.border = true;
			_text.type = TextFieldType.INPUT;
			_text.multiline = true;
			_text.wordWrap = true;
			_text.height = _playArea.height;
			_text.x = button.x;
			_text.y = button.y + button.height;
			_text.width = 150;
			addChild(_text);
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
			if (e.target != _text)
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

		private function onSerialize(e:Event):void
		{
			_text.text = _map.toString();
		}
		private function onDeserialize(e:Event):void
		{
			_map.fromString(_text.text);
			_map.setCamera(_camera);
		}

		static private var _fmt:TextFormat;
		static private function createButton(label:String, listener:Function):InteractiveObject
		{
			if (!_fmt)
			{
				_fmt = new TextFormat("Arial", 20, 0xff);
			}
			var btn:TextField = new TextField();
			btn.text = label;
			btn.selectable = false;
			btn.background = true;
			btn.border = true;
			btn.backgroundColor = 0xffffff;
			btn.setTextFormat(_fmt);
			btn.autoSize = TextFieldAutoSize.LEFT;
			
			var parent:Sprite = new Sprite();
			parent.useHandCursor = true;
			parent.buttonMode = true;
			parent.mouseChildren = false;
			parent.addChild(btn);
			parent.addEventListener(MouseEvent.CLICK, listener);
			parent.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			parent.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);

			return parent;
		}
		static private function onButtonOver(e:MouseEvent):void
		{
			TextField(Sprite(e.currentTarget).getChildAt(0)).backgroundColor = 0xBCC8FF;
		}
		static private function onButtonOut(e:MouseEvent):void
		{
			TextField(Sprite(e.currentTarget).getChildAt(0)).backgroundColor = 0xffffff;
		}
	}
}