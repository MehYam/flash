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
			_next = calcNext(getTimer());
		}
		private function calcNext(start:uint):uint
		{
			return start + _rateMin + (_rateMax - _rateMin)*Math.random();
		}
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
	}
}