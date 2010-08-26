package behaviors
{
	import flash.utils.getTimer;
	
	import karnold.utils.RateLimiter;

	public final class AlternatingBehavior implements IBehavior
	{
		private var _behaviors:CompositeBehavior = new CompositeBehavior;
		private var _rate:RateLimiter;
		public function AlternatingBehavior(msRateMin:uint, msRateMax:uint, ...args)
		{
			for each (var behavior:IBehavior in args)
			{
				_behaviors.push(behavior);
			}

			_rate = new RateLimiter(msRateMin, msRateMax);
			_count = Math.random() * _behaviors.numBehaviors;
		}
		private var _count:uint;
		public function onFrame(game:IGame, actor:Actor):void
		{
			if (_rate.now)
			{
				++_count;
			}
			_behaviors.onFrameAt(game, actor, _count % _behaviors.numBehaviors);
		}
		public function zero():IBehavior
		{
			_count = 0;
			return this;
		}
	}
}