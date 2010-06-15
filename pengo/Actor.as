package
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	// KAI: consider interface
	public class Actor
	{
		private var _animator:FrameAnimator;
		public function Actor(animator:FrameAnimator, bCanImmobilize:Boolean)
		{
			super();
			_animator = animator;
			_canImmobilize = bCanImmobilize;
		}

		public var state:uint;
		public var velocity:Point = new Point;
		public var force:Point = new Point;

		private var _canImmobilize:Boolean;		
		public function get canImmobilize():Boolean
		{
			return _canImmobilize;
		}
		public function get displayObject():DisplayObject
		{
			return _animator;
		}
		public function get bounds():Rectangle
		{
			return new Rectangle(_animator.x, _animator.y, Consts.TILE_SIZE, Consts.TILE_SIZE);
		}
		public function get leadingEdgeX():Number
		{
			const offset:int = (velocity.x > 0) ? (Consts.TILE_SIZE - 1) : 0;
			return _animator.x + offset; 
		}		
		public function get leadingEdgeY():Number
		{
			const offset:int = (velocity.y > 0) ? (Consts.TILE_SIZE - 1) : 0;
			return _animator.y + offset;
		}
		public function applyVelocity():void
		{
			_animator.x += velocity.x;
			_animator.y += velocity.y;
		}
		public function onFrame(frame:uint):void
		{
			_animator.onFrame(frame);
		}
		public function onEvent(event:uint):void
		{
			switch(event) {
			case ActorEvent.PAUSE:
				state = ActorState.PAUSED;
				velocity.x = 0;
				velocity.y = 0;
				break;
			}
		}
	}
}