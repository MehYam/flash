package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;

	public class TestRendering extends Sprite
	{
		private var _sprite:Sprite;
		private var _keyboard:Keyboard;
		public function TestRendering()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 2000;
			var tmd:TotalMemoryDisplay = new TotalMemoryDisplay;
			tmd.activate(true, stage);
			addChild(tmd);

			_sprite = new Sprite;
			
			_sprite.graphics.lineStyle(4, 0xffffff);
			_sprite.graphics.beginFill(0x0000ff);
			_sprite.graphics.drawEllipse(0, 0, 100, 200);
			
			addChildAt(_sprite, 0);
			
			_keyboard = new Keyboard(stage);

			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			stage.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}

private var _offStageParent:Sprite = new Sprite;
		private function fillStage():void
		{
			if (numChildren < 10)
			{
				for (var i:int = 0; i < 750; ++i)
				{
					var sp:Sprite = new Sprite;
					sp.graphics.lineStyle(1, 0xffffff * Math.random());
					sp.graphics.beginFill(0xffffff * Math.random());
					sp.graphics.drawEllipse(0, 0, 100 * Math.random(), 200 * Math.random());
					
					sp.x = 600 * Math.random();
					sp.y = 600 * Math.random();

//sp.x = 0;
//sp.y = 0;					
//					_offStageParent.addChildAt(sp, 0);
					addChildAt(sp, 0);
				}
			}
		}

		private var _destination:Point = null;
		private function onClick(evt:MouseEvent):void
		{
			if (_destination)
			{
				_destination = null;
			}
			else
			{
				_destination = new Point(evt.stageX, evt.stageY);
			}
		}

		static private const SPEED:Number = 1;
		private var _lastUpdate:uint = getTimer();
		private function onEnterFrame(e:Event):void
		{
			var now:uint = getTimer();

			if (_keyboard.keys[39]) {
				_sprite.x += SPEED;
				_destination = null;
			} else if (_keyboard.keys[37]) {
				_sprite.x -= SPEED;
				_destination = null;
			}
			
			if (_keyboard.keys[40]) {
				_sprite.y += SPEED;
				_destination = null;
			} else if (_keyboard.keys[38]) {
				_sprite.y -= SPEED;
				_destination = null;
			}
			
			if (_keyboard.keys[32]) {
				fillStage();
			}
			
			if (_destination)
			{
				var here:Point = new Point(_sprite.x, _sprite.y);

				const dist:Number = Point.distance(here, _destination);
				var newPoint:Point = Point.interpolate(_destination, here, 0.003);
				
				_sprite.x = newPoint.x;
				_sprite.y = newPoint.y;
			}
		}
	}
}
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	

class Keyboard
{
	public var keys:Array = [];
	public function Keyboard(source:DisplayObject)
	{
		source.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		source.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
	}
	private function onKeyDown(e:KeyboardEvent):void
	{
		keys[e.keyCode] = true;
	}
	private function onKeyUp(e:KeyboardEvent):void
	{
		keys[e.keyCode] = false;
	}
}