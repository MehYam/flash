package behaviors
{
	import flash.utils.getTimer;
	
	import karnold.utils.RateLimiter;

	public final class AlternatingBehavior implements IBehavior
	{
		private var _behaviors:CompositeBehavior = new CompositeBehavior;
		private var _rate:RateLimiter;
		public function AlternatingBehavior(msRate:uint, ...args)
		{
			for each (var behavior:IBehavior in args)
			{
				_behaviors.push(behavior);
			}

			_rate = new RateLimiter(msRate / 2, msRate*3 / 2);
			_count = Math.random() * _behaviors.numBehaviors;
		}
		private var _count:uint;
		public function onFrame(game:IGame, actor:Actor):void
		{
			_behaviors.onFrameAt(game, actor, _count % _behaviors.numBehaviors);
			if (_rate.now)
			{
				++_count;
			}
		}
	}
}