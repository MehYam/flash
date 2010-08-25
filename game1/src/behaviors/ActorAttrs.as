package behaviors
{
	final public class ActorAttrs
	{
		static public const BULLET:ActorAttrs = new ActorAttrs(1, 8, 10, 0, 20, 0, false, 1500);
		static public const ROCKET:ActorAttrs = new ActorAttrs(1, 8, 0.2, 0, 20, 0, false, 4000);
		static public const LASER:ActorAttrs = new ActorAttrs(1, 6, 7, 0, 20, 0, false, 2000);
		static public const FUSIONBLAST:ActorAttrs = new ActorAttrs(1, 5, 10, 0, 20, 0, true, 4000);
		static public const EXPLOSION:ActorAttrs = new ActorAttrs(0, 100, 0, 0.1, 0, 0, false, 300);

		// Shield's value is partly determined by its max life....
		//KAI: this totally suxorz
		static public const SHIELDS:Array = 
			[	new ActorAttrs(50, 0, 0, 0, 50, 0, false),
				new ActorAttrs(200, 0, 0, 0, 50, 0, false),
				new ActorAttrs(500, 0, 0, 0, 50, 0, false)];
			
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
