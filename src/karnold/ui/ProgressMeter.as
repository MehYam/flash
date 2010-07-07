package karnold.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class ProgressMeter extends Sprite
	{
		private var _meter:DisplayObject;
		private var _width:Number;
		public function ProgressMeter(width:Number, height:Number, bgColor:uint, fgColor:uint)
		{
			_width = width;

//			var bmd:BitmapData = new BitmapData(width, height);
//			bmd.perlinNoise( bmd.width/5, bmd.height/5, 8, 69, true, true, 1, false)
			var bmd:BitmapData = new BitmapData(1, 1);
			bmd.setPixel(0, 0, bgColor);
			
			var bmp:Bitmap = new Bitmap(bmd);
			bmp.scaleX = width;
			bmp.scaleY = height;
			addChild(bmp);
			
			bmd = new BitmapData(1, 1);
			bmd.setPixel(0, 0, fgColor);
			_meter = new Bitmap(bmd);
			_meter.scaleY = height;
			addChild(_meter);
		}
		
		public function set pct(percent:Number):void
		{
			_meter.scaleX = _width * percent; 
		}
	}
}