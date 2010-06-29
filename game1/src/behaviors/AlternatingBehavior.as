package behaviors
{
	import flash.utils.getTimer;

	public final class AlternatingBehavior implements IBehavior
	{
		private var _behaviors:CompositeBehavior = new CompositeBehavior;
		private var _lastChange:int;
		public function AlternatingBehavior(...args)
		{
			for each (var behavior:IBehavior in args)
			{
				_behaviors.push(behavior);
			}
		}
		private var _count:uint;
		public function onFrame(game:IGame, actor:Actor):void
		{
			_behaviors.onFrameAt(game, actor, _count % _behaviors.numBehaviors);
			
			const now:int = getTimer();
			if ((now - _lastChange) > 5000)
			{
				++_count;
				_lastChange = now;
			}
		}
	}
}