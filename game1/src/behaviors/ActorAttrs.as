package behaviors
{
	final public class ActorAttrs
	{
		static public const BLUE_SHIP:ActorAttrs = new ActorAttrs(6, 1, 0.1);
		static public const GREEN_SHIP:ActorAttrs = new ActorAttrs(1.5, 0.1, 0, 10, 10);
		static public const RED_SHIP:ActorAttrs = new ActorAttrs(3, 0.1, 0, 15, 15);
		static public const GRAY_SHIP:ActorAttrs = new ActorAttrs(2, 0.15, 20);

		static public const TEST_TANK:ActorAttrs = new ActorAttrs(1.5, 1, 0.5);

		static public const BULLET:ActorAttrs = new ActorAttrs(8, 10);
		static public const LASER:ActorAttrs = new ActorAttrs(6, 7);
		static public const EXPLOSION:ActorAttrs = new ActorAttrs(100, 0, 0.1);

		// these semi-belong here
		static public const LASER_LIFETIME:uint = 3000;
		static public const BULLET_LIFETIME:uint = 1200;
		static public const EXPLOSION_LIFETIME:uint = 700;
		
		static public const MAX_HEALTH:uint = 100;
		static public const DEFAULT_VALUE:uint = 10;

		public var MAX_SPEED:Number;
		public var ACCELERATION:Number;
		public var SPEED_DECAY:Number;
		public var RADIUS:Number;
		public var COLLISION_DMG:Number;
		public function ActorAttrs(speed:Number, 
									   accel:Number, 
									   decay:Number = 0, 
									   radius:Number = 20,
									   collisionDmg:Number = 100)
		{
			MAX_SPEED = speed;
			ACCELERATION = accel;
			SPEED_DECAY = decay;
			RADIUS = radius;
			COLLISION_DMG = collisionDmg;
		}
	};
}
