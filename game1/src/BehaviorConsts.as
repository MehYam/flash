package
{
	final public class BehaviorConsts
	{
		static public const BLUE_SHIP:BehaviorConsts = new BehaviorConsts(6, 1, 0.1);
		static public const GREEN_SHIP:BehaviorConsts = new BehaviorConsts(1.5, 0.1);
		static public const RED_SHIP:BehaviorConsts = new BehaviorConsts(3, 0.1);
		static public const GRAY_SHIP:BehaviorConsts = new BehaviorConsts(2, 0.15);

		static public const TEST_TANK:BehaviorConsts = new BehaviorConsts(1.5, 1, 1);
		static public const BULLET:BehaviorConsts = new BehaviorConsts(10, 10);
		static public const LASER:BehaviorConsts = new BehaviorConsts(7, 7);
		static public const EXPLOSION:BehaviorConsts = new BehaviorConsts(100, 0, 0.1);

		//KAI: the real inflexibility problem starts here.  trace this all the way to SimpleActorAsset.  There's got to be a way
		// to make this easier so that we can have different colored assets all pooled accordingly
		static public const TYPE_BULLET:uint = 0;
		static public const TYPE_LASER:uint = 1;

		// these semi-belong here
		static public const LASER_LIFETIME:uint = 3000;
		static public const BULLET_LIFETIME:uint = 1200;
		static public const EXPLOSION_LIFETIME:uint = 700;

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