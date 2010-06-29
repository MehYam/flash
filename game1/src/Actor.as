package
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;

	public class Actor implements IResettable
	{
		private var _alive:Boolean = true;

		public var name:String;
		public var displayObject:DisplayObject;
		public var speed:Point = new Point();
		public var worldPos:Point = new Point();
		public var consts:BehaviorConsts;
		public var health:Number;
		public function Actor(dobj:DisplayObject, consts:BehaviorConsts = null)
		{
			displayObject = dobj;
			this.consts = consts;
			
			health = BehaviorConsts.PLAYER_HEALTH;
		}
		
		private var _behavior:IBehavior;
		public function set behavior(b:IBehavior):void
		{
			_behavior = b;
		}
		public function reset():void  // IResettable
		{
			var resettableBehavior:IResettable = _behavior as IResettable;
			if (resettableBehavior)
			{
				resettableBehavior.reset();
			}
			displayObject.alpha = 1;
			_alive = true;
		}
		public function get alive():Boolean
		{
			return _alive;
		}
		public function set alive(b:Boolean):void
		{
			if (_alive != b && !b)
			{
				Util.stopAllMovieClips(displayObject);

				if (displayObject.parent)
				{
					displayObject.parent.removeChild(displayObject);
				}
			}
			_alive = b;
		}
		public function onFrame(gameState:IGame):void
		{
			if (_behavior)
			{
				_behavior.onFrame(gameState, this);
			}
		}
		private function launchHelper(start:Point, radians:Number):void
		{
			Util.setPoint(worldPos, start);
			speed.x = Math.sin(radians) * consts.MAX_SPEED;
			speed.y = -Math.cos(radians) * consts.MAX_SPEED;
		}
		public function launchDegrees(start:Point, degrees:Number):void
		{
			launchHelper(start, MathUtil.degreesToRadians(degrees));
		}
		public function launch(start:Point, deltaX:Number, deltaY:Number):void
		{
			launchHelper(start, MathUtil.getRadiansRotation(deltaX, deltaY));
		}
	}
}