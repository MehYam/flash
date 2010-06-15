package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class RasterizedMovieClip extends Sprite
	{
		public function RasterizedMovieClip(type:Class, scaledWidth:Number, scaledHeight:Number):void
		{
			super();
			
			var instance:MovieClip = new type() as MovieClip;
			if (instance)
			{
				instance.width = scaledWidth;
				instance.height = scaledHeight;
				rasterize(instance);
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}

		private var _frame:uint = 0;
		private var _totalFrames:uint = 0;
		private var _bmd:BitmapData;
		private var _child:Bitmap;
		private var _rect:Rectangle = new Rectangle;
		private function rasterize(mc:MovieClip):void
		{
			var mcParent:MovieClip = new MovieClip();
			mcParent.addChild(mc);

			var widthMax:Number = 0;
			var heightMax:Number = 0;
			var frame:uint = 0;
			for (frame = 0; frame < mc.totalFrames; ++frame)
			{
				mc.gotoAndPlay(frame + 1);

				trace("frame " + mc.currentFrame + " size: " + mcParent.width + ", " + mcParent.height);
				if (mc.width > widthMax)
				{
					widthMax = mc.width;
				}
				if (mc.height > heightMax)
				{
					heightMax = mc.height;
				}
			}
			
			_totalFrames = mc.totalFrames;

			_bmd = new BitmapData(widthMax * _totalFrames, heightMax);
			for (frame = 0; frame < _totalFrames; ++frame)
			{
				mc.gotoAndPlay(frame + 1);

				var bound:Rectangle = mc.getBounds(mc);

				var mat:Matrix = new Matrix();
				mat.scale(mc.scaleX, mc.scaleY);
				mat.translate((frame * widthMax) - (mc.scaleX * bound.left), -(mc.scaleY * bound.top));

				_bmd.draw(mc, mat);
			}

			_rect.width = widthMax;
			_rect.height = heightMax;

			_child = new Bitmap(new BitmapData(_rect.width, _rect.height));
			addChild(_child);
		}
		
		private var _currentFrame:int = 0;
		private function onEnterFrame(e:Event):void
		{
			if (_child)
			{
				_rect.x = _currentFrame * _rect.width;
				_child.bitmapData.copyPixels(_bmd, _rect, new Point(0, 0));

				if (++_currentFrame >= _totalFrames)
				{
					_currentFrame = 0;
				}
			}
		} 
	}
}