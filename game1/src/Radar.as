package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import karnold.utils.Bounds;
	import karnold.utils.Util;
	
	public class Radar extends Sprite
	{
		public function Radar()
		{
			super();
		}

		private var _background:Bitmap;
		private var _scaling:Point;
		public function render(bounds:Bounds, width:Number, height:Number):void
		{
			Util.removeAllChildren(this);
			
			var rect:Shape = new Shape;
			rect.graphics.lineStyle(2);
			rect.graphics.drawRect(0, 0, width, height);

			//http://polygeek.com/1780_flex_explorer-bitmapdata-perlin-noise
			var bmd:BitmapData = new BitmapData(width, height, true, 0);
			bmd.perlinNoise( 436, 441, 7, 45, true, true, 2, true);
			bmd.draw(rect);
			
			_background = new Bitmap(bmd);
			addChild(_background);
			
			_scaling = new Point(width / bounds.width, height / bounds.height);
		}

		private var _dots:Dictionary = new Dictionary(true);
		public function plot(actor:Actor, color:uint = 0xff0000):void
		{
			var dot:Shape = _dots[actor] as Shape;
			if (!dot)
			{
				dot = new Shape;
				dot.graphics.lineStyle(1);
				dot.graphics.beginFill(color);
				dot.graphics.drawCircle(-1, -1, 2);
				dot.graphics.endFill();
				
				_dots[actor] = dot;
				
				addChild(dot);
			}
			dot.x = actor.worldPos.x * _scaling.x;
			dot.y = actor.worldPos.y * _scaling.y;
		}
		public function remove(actor:Actor):void
		{
			var dot:Shape = _dots[actor] as Shape;
			if (dot)
			{
				removeChild(dot);
				delete _dots[actor];
			}
		}
	}
}