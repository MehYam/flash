package
{
	final public class BehaviorConsts
	{
		static public const GREEN_SHIP:BehaviorConsts = new BehaviorConsts(1.5, 0.1);
		static public const RED_SHIP:BehaviorConsts = new BehaviorConsts(3, 0.1);
		static public const GREY_SHIP:BehaviorConsts = new BehaviorConsts(2, 0.15);
		static public const BULLET:BehaviorConsts = new BehaviorConsts(10, 10);
		static public const EXPLOSION:BehaviorConsts = new BehaviorConsts(100, 0, 0.1);

		// these semi-belong here
		static public const BULLET_LIFETIME:uint = 2000;
		static public const EXPLOSION_LIFETIME:uint = 1000;

		// these DON'T belong here
		static public const PLAYER_HEALTH:Number = 100;
		static public const PLAYER_ENERGY:Number = 100;
		
		
		public var MAX_SPEED:Number;
		public var ACCELERATION:Number;
		public var SPEED_DECAY:Number;
		public function BehaviorConsts(speed:Number, accel:Number, decay:Number = 0)
		{
			MAX_SPEED = speed;
			ACCELERATION = accel;
			SPEED_DECAY = decay;
		}
	};
}