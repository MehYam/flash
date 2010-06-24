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
		public function Actor(dobj:DisplayObject)
		{
			displayObject = dobj;
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