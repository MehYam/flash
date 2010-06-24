package
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public final class Actor
	{
		public var displayObject:DisplayObject;
		public var speed:Point = new Point();
		public var worldPos:Point = new Point();
		public var alive:Boolean = true;
		public var consts:BehaviorConsts;
		public function Actor(dobj:DisplayObject, consts:BehaviorConsts = null)
		{
			displayObject = dobj;
			this.consts = consts;
		}
		
		private var _behavior:IBehavior;
		public function set behavior(b:IBehavior):void
		{
			_behavior = b;
		}
		public function onFrame(gameState:IGameState):void
		{
			if (_behavior)
			{
				_behavior.onFrame(gameState, this);
			}
		}
	}
}