package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;

	public class TestBitmapMouse extends Sprite
	{
		public function TestBitmapMouse()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
				
			var sprite:Sprite = new Sprite;
			sprite.graphics.lineStyle(3, 0x00ff00);
			sprite.graphics.beginFill(0xff0000);
			sprite.graphics.drawCircle(0, 0, 100);
			sprite.graphics.endFill();
			
			sprite.x = 100;
			sprite.y = 100;
			
			sprite.addEventListener(MouseEvent.CLICK, onClick);
			addChild(sprite);
			
			var bmd:BitmapData = new BitmapData(sprite.width, sprite.height, true, 0);
			bmd.draw(sprite);
			
			var bmp:Bitmap = new Bitmap(bmd);
			
			var host:Sprite = new Sprite;
			host.addChild(bmp);
			 
			host.x = 300;
			host.y = 300;
			host.addEventListener(MouseEvent.CLICK, onClick);
			addChild(host);
		}
		
		private function onClick(evt:MouseEvent):void
		{
			trace("click!", evt);
		}
	}
}
