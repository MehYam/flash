package {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class fun extends Sprite
	{
		private var _sprite:Sprite = new Sprite;
		public function fun()
		{
			_sprite.x = 50;
			_sprite.y = 50;

			_sprite.graphics.lineStyle(1, 0x0000ff);
			_sprite.graphics.beginFill(0xff0000);
			_sprite.graphics.drawCircle(0, 0, 30);
			_sprite.graphics.endFill();
			addChild(_sprite);
			
			_sprite.addEventListener(MouseEvent.CLICK, onStageClick, false, 0, true);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}
		
		private function onStageClick(evt:MouseEvent):void
		{
			_speed.y = 0;
			_sprite.y = evt.stageY;
		}

		private var _speed:Point = new Point(0, 1);		
		private function onEnterFrame(evt:Event):void
		{
			_sprite.x += _speed.x;
			_sprite.y += _speed.y;
			
			_speed.y += 1;
			
			if (_sprite.y > (stage.stageHeight - _sprite.height))
			{
				_speed.y = -_speed.y;
			}
		}
	}
}
