package behaviors
{
	final public class CompositeBehavior implements IBehavior, IResettable
	{
		private var _behaviors:Array = [];
		public function CompositeBehavior(...args)
		{
			for each (var behavior:IBehavior in args)
			{
				_behaviors.push(behavior);
			}
		}
		public function push(b:IBehavior):void
		{
			_behaviors.push(b);
		}
		public function onFrame(game:IGame, actor:Actor):void
		{
			for each (var behavior:IBehavior in _behaviors)
			{
				behavior.onFrame(game, actor);
			}
		}
		public function onFrameAt(game:IGame, actor:Actor, index:uint):void
		{
			const behavior:IBehavior = _behaviors[index];
			if (behavior)
			{
				behavior.onFrame(game, actor);
			}
		}
		public function get numBehaviors():uint
		{
			return _behaviors.length;
		}
		public function reset():void
		{
			for each (var behavior:IBehavior in _behaviors)
			{
				var resettable:IResettable = behavior as IResettable;
				if (resettable)
				{
					resettable.reset();
				}
			}
		}
	}
}