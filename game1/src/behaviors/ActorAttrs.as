package behaviors
{
	final public class ActorAttrs
	{
		static public const BULLET:ActorAttrs = new ActorAttrs(100, 8, 10, 0, 20, 100, false, 1500);
		static public const ROCKET:ActorAttrs = new ActorAttrs(100, 4, 0.01, 0, 20, 100, false, 4000);
		static public const LASER:ActorAttrs = new ActorAttrs(100, 6, 7, 0, 20, 100, false, 2000);
		static public const FUSIONBLAST:ActorAttrs = new ActorAttrs(100, 5, 10, 0, 20, 33);
		static public const EXPLOSION:ActorAttrs = new ActorAttrs(100, 100, 0, 0.1, 0, 0, false, 300);

		static public const INFINITE_LIFETIME:int = -1;
		
		// these semi-belong here
		static public const DEFAULT_VALUE:uint = 10;

		public var MAX_HEALTH:Number;
		public var MAX_SPEED:Number;
		public var ACCELERATION:Number;
		public var SPEED_DECAY:Number;
		public var RADIUS:Number;
		public var DAMAGE:Number;
		public var BOUNDED:Boolean;  // to be kept within world coordinates
		public var LIFETIME:Number = -1;
		public function ActorAttrs(
								maxHealth:Number,
								maxSpeed:Number, 
								accel:Number, 
								speedDecay:Number = 0, 
								radius:Number = 20,
								dmg:Number = 100,
								bounded:Boolean = true,
							    lifetime:Number = INFINITE_LIFETIME)
		{
			MAX_HEALTH = maxHealth;
			MAX_SPEED = maxSpeed;
			ACCELERATION = accel;
			SPEED_DECAY = speedDecay;
			RADIUS = radius;
			DAMAGE = dmg;
			BOUNDED = bounded;
			LIFETIME = lifetime;
		}
	};
}
