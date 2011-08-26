package karnold.utils
{
	import flash.utils.getTimer;

	final public class RateLimiter
	{
		private var _rateMin:uint;
		private var _rateMax:uint;
		private var _next:uint;
		public function RateLimiter(msRateMin:uint, msRateMax:uint)
		{
			_rateMin = msRateMin;
			_rateMax = msRateMax;

			reset();
		}
		private function calcNext(start:uint):uint
		{
			return start + _rateMin + (_rateMax - _rateMin)*Math.random();
		}
		/**
		 * Disposes of the current interval and calculates a new one
		 */
		public function reset():void
		{
			_next = calcNext(getTimer());
		}
		/**
		 *  <code>now</code> returns <code>true</code> when the interval has elapsed.  It automatically calculates the next interval when this occurs, so callers need only check <code>now</code> repeatedly to detect time slots.
		 * 
		 * @return <code>true</code> when the interval has elapsed   
		 */
		public function get now():Boolean
		{
			const now:int = getTimer();
			if (now > _next)
			{
				_next = calcNext(now);
				return true;
			}
			return false;
		}
		public function get remaining():uint
		{
			return Math.max(0, _next - getTimer());
		}
		public function get minRate():uint
		{
			return _rateMin;
		}
		public function get maxRate():uint
		{
			return _rateMax;
		}
		public function set maxRate(m:uint):void
		{
			_rateMax = m;
		}
	}
}