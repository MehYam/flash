package
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import karnold.utils.Utils;

	public final class Actor
	{
		private var _alive:Boolean = true;

		public var displayObject:DisplayObject;
		public var speed:Point = new Point();
		public var worldPos:Point = new Point();
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
		public function get alive():Boolean
		{
			return _alive;
		}
		public function set alive(b:Boolean):void
		{
			if (_alive != b && !b)
			{
				Utils.stopAllMovieClips(displayObject);

				if (displayObject.parent)
				{
					displayObject.parent.removeChild(displayObject);
				}
			}
			_alive = b;
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