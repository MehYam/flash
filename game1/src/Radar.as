package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import karnold.utils.Bounds;
	import karnold.utils.Util;
	
	public class Radar extends Sprite
	{
		public function Radar()
		{
			super();
			mouseEnabled = false;
			mouseChildren = false;
		}

		private var _background:Bitmap;
		private var _scaling:Point;
		public function render(bounds:Bounds, width:Number, height:Number):void
		{
			Util.removeAllChildren(this);
			
			var rect:Shape = new Shape;
			rect.graphics.lineStyle(4);
			rect.graphics.drawRect(0, 0, width, height);

			scrollRect = new Rectangle(0, 0, width, height);

			//http://polygeek.com/1780_flex_explorer-bitmapdata-perlin-noise	
			var bmd:BitmapData = new BitmapData(width, height, true, 0);
			bmd.perlinNoise( 436, 441, 7, 45, false, true, BitmapDataChannel.GREEN, true);
//			bmd.perlinNoise( 400, 300, 2, 53, true, true, 2, false);
			bmd.draw(rect);
			
			_background = new Bitmap(bmd);
			addChild(_background);
			
			_scaling = new Point(width / bounds.width, height / bounds.height);
		}

		static private var s_rasterizationStore:Dictionary = new Dictionary;

		//KAI: prolly need to pool here too
		static private const DOT_RADIUS:Number = 1.5;
		private var _dots:Dictionary = new Dictionary(true);
		public function plot(actor:Actor, color:uint = 0xff2222):void
		{
			var dot:DisplayObject = _dots[actor] as DisplayObject;
			if (!dot)
			{
				var bmd:BitmapData = s_rasterizationStore[color];
				if (!bmd)
				{
					var canvas:Shape = new Shape;
					canvas.graphics.lineStyle(1);
					canvas.graphics.beginFill(color);
					canvas.graphics.drawCircle(-DOT_RADIUS, -DOT_RADIUS, DOT_RADIUS*2);
					canvas.graphics.endFill();
					
					bmd = ActorAssetManager.rasterize(canvas);
					s_rasterizationStore[color] = bmd;
				}
				dot = new Bitmap(bmd);
				_dots[actor] = dot;
				
				addChild(dot);
			}
			dot.x = actor.worldPos.x * _scaling.x - dot.width/2;
			dot.y = actor.worldPos.y * _scaling.y - dot.height/2;
		}
		public function remove(actor:Actor):void
		{
			var dot:DisplayObject = _dots[actor] as DisplayObject;
			if (dot)
			{
				removeChild(dot);
				delete _dots[actor];
			}
		}
		public function clear():void
		{
			for each (var dot:DisplayObject in _dots)
			{
				if (dot && dot.parent)
				{
					removeChild(dot);
				}
			}
			_dots = new Dictionary(true);
		}
	}
}