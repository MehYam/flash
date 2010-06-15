package
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.geom.Point;

//WOULD be cooler if the streak showed up slightly after the block was slid, accompanied with a crackling sound.
// while it was visible, it would be a debuf for enemies walking over it	
	public class StreakEffect extends Actor
	{
		public function StreakEffect(a:FrameAnimator)
		{
			super(a, false);
		}
//
//		private var _cache:CachedStuff = null; 
//		private var _fadeRemaining:uint = Consts.STREAK_FADE_FRAMES;
//		private function createCache():CachedStuff
//		{
//			var cache:CachedStuff = new CachedStuff;
//			cache.start.x = x;
//			cache.start.y = y;
//			if (velocity.x < 0)
//			{
//				cache.rotation = 0;
//				cache.height = Consts.STREAK_BREADTH;
//			}
//			else if (velocity.x > 0)
//			{
//				cache.rotation = Math.PI;
//				cache.height = Consts.STREAK_BREADTH;
//			}
//			else if (velocity.y < 0)
//			{
//				cache.rotation = Math.PI / 2;
//				cache.width = Consts.STREAK_BREADTH;
//			}
//			else if (velocity.y > 0)
//			{
//				cache.rotation = Math.PI * 3 / 2;
//				cache.width = Consts.STREAK_BREADTH;
//			}
//			return cache;
//		}
//		public override function onFrame(frame:uint):void
//		{
//			if (!_cache)
//			{
//				_cache = createCache();
//			}
//
//			if (velocity.x == 0 && velocity.y == 0)
//			{
//				//
//				// we've stopped, and need to fade and die
//				_cache.alpha = --_fadeRemaining / Consts.STREAK_FADE_FRAMES;
//				if (_fadeRemaining == 0)
//				{
//					state = ActorState.DEAD;					
//				}
//			}
//			else if (velocity.x > 0)
//			{
//				if (_cache.width < Consts.STREAK_LENGTH)
//				{
//					x -= velocity.x;
//					_cache.width = Math.min(_cache.width + velocity.x, Consts.STREAK_LENGTH);
//				}
//			}
//			else if (velocity.x < 0)
//			{
//				_cache.width = Math.min(_cache.start.x - x, Consts.STREAK_LENGTH);
//			}
//			else if (velocity.y > 0)
//			{
//				if (_cache.height < Consts.STREAK_LENGTH)
//				{
//					y -= velocity.y;
//					_cache.height = Math.min(_cache.height + velocity.y, Consts.STREAK_LENGTH);
//				}
//			}
//			else if (velocity.y < 0)
//			{
//				_cache.height = Math.min(_cache.start.y - y, Consts.STREAK_LENGTH);
//			}
//
//			//efficiency:  we don't really need to draw every frame
//			draw(_cache.width, _cache.height, _cache.rotation, _cache.alpha);
//		}		
//
//		private function draw(w:Number, h:Number, rotation:Number, alpha:Number):void
//		{
//			var matrix:Matrix = new Matrix;
//			matrix.createGradientBox(w, h, rotation, 0, 0);	
//
//			graphics.clear();
//			//graphics.beginGradientFill(GradientType.LINEAR, [Consts.STREAK_COLOR, Consts.BLOCK_COLOR, Consts.STREAK_COLOR], [0, alpha, 0], [0, 227, 255], matrix);
//			graphics.beginGradientFill(GradientType.LINEAR, [Consts.STREAK_COLOR, Consts.BLOCK_COLOR, Consts.BLOCK_COLOR], [0, alpha, 0], [0, 200, 255], matrix);
//
//			graphics.drawRect(0, 0, w, h);
//		}

	}
}
import flash.geom.Point;

internal class CachedStuff
{
	public var rotation:Number = NaN;
	public var start:Point = new Point;
	public var width:Number = 0;
	public var height:Number = 0;
	public var alpha:Number = 1.0;
}