package behaviors
{
	import flash.geom.Point;

	final public class ActorAttrs
	{
		static public const EXTENT_WORLD:Point = new Point(0, 0);
		static public const EXTENT_FURTHER:Point = new Point(100, 100);
		static public const EXTENT_INFINITE:Point = new Point(int.MAX_VALUE, int.MAX_VALUE);

		static public const BULLET:ActorAttrs = new ActorAttrs(1, 8, 10, 0, 20, 0, EXTENT_INFINITE, 1500);
		static public const ROCKET:ActorAttrs = new ActorAttrs(1, 8, 0.2, 0, 20, 0, EXTENT_INFINITE, 4000);
		static public const CANNON:ActorAttrs = new ActorAttrs(1, 14, 10, 0, 20, 0, EXTENT_INFINITE, 700);
		static public const LASER:ActorAttrs = new ActorAttrs(1, 6, 7, 0, 20, 0, EXTENT_INFINITE, 2000);
		static public const FUSIONBLAST:ActorAttrs = new ActorAttrs(1, 5, 10, 0, 20, 0, EXTENT_WORLD, 4000);
		static public const EXPLOSION:ActorAttrs = new ActorAttrs(0, 100, 0, 0.1, 0, 0, EXTENT_INFINITE, 300);

		static public const INFINITE_LIFETIME:int = -1;

		static public const MAX_ROTATIONAL_DELTA:Number = 5;
		static public const DEFAULT_VALUE:uint = 10;

		public var MAX_HEALTH:Number;
		public var MAX_SPEED:Number;
		public var ACCELERATION:Number;
		public var SPEED_DECAY:Number;
		public var RADIUS:Number;
		public var DAMAGE:Number;
		public var BOUND_EXTENT:Point;  // to be kept within world coordinates
		public var VALUE:uint;
		public var LIFETIME:Number = -1;
		public function ActorAttrs(
								maxHealth:Number,
								maxSpeed:Number, 
								accel:Number, 
								speedDecay:Number = 0, 
								radius:Number = 20,
								dmg:Number = 100,
								boundExtent:Point = null,  // actionscript won't let EXTENT_WORLD be the default
							    lifetime:Number = INFINITE_LIFETIME)
		{
			MAX_HEALTH = maxHealth;
			MAX_SPEED = maxSpeed;
			ACCELERATION = accel;
			SPEED_DECAY = speedDecay;
			RADIUS = radius;
			DAMAGE = dmg;
			BOUND_EXTENT = boundExtent || EXTENT_WORLD;
			LIFETIME = lifetime;
		}
	};
}
