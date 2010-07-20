package karnold.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import karnold.utils.MathUtil;
	
	public class ProgressMeter extends Sprite
	{
		private var _meter:Bitmap;
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
			const scale:Number = _width * MathUtil.constrainToRange(percent, 0, 1);
			_meter.scaleX = scale; 
		}
		public function set fgColor(color:uint):void
		{
			_meter.bitmapData.setPixel(0, 0, color);
		}
		
		private var _diff:Bitmap;
		public function set diff(d:Number):void
		{
			if (d != 0)
			{
				var bmd:BitmapData;
				if (_diff)
				{
					bmd = _diff.bitmapData;
				}
				else
				{
					bmd = new BitmapData(1, 1);
					_diff = new Bitmap(bmd);
					_diff.scaleY = height;
				}

				_diff.x = _meter.scaleX;
				_diff.scaleX = _width * d;
				bmd.setPixel(0, 0, (d > 0) ? 0x00ff00 : 0xff0000);
				if (!_diff.parent)
				{
					addChild(_diff);
				}
			}
			else if (_diff && _diff.parent)
			{
				_diff.parent.removeChild(_diff);
			}
		}
			
	}
}