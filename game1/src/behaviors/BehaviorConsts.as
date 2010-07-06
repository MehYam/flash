package behaviors
{
	final public class BehaviorConsts
	{
		static public const BLUE_SHIP:BehaviorConsts = new BehaviorConsts(6, 1, 0.1);
		static public const GREEN_SHIP:BehaviorConsts = new BehaviorConsts(1.5, 0.1, 0, 10, 10);
		static public const RED_SHIP:BehaviorConsts = new BehaviorConsts(3, 0.1, 0, 15, 15);
		static public const GRAY_SHIP:BehaviorConsts = new BehaviorConsts(2, 0.15, 20);

		static public const TEST_TANK:BehaviorConsts = new BehaviorConsts(1.5, 1, 1);

		static public const BULLET:BehaviorConsts = new BehaviorConsts(8, 10);
		static public const LASER:BehaviorConsts = new BehaviorConsts(6, 7);
		static public const EXPLOSION:BehaviorConsts = new BehaviorConsts(100, 0, 0.1);

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
		public var RADIUS:Number;
		public var COLLISION_DMG:Number;
		public function BehaviorConsts(speed:Number, 
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
import flash.geom.Point;

final class BounceType {}
final class FirePoint
{
	public var offset:Point;
	public var angle:Number;
}

final class AmmoClassAttributes
{
	public var type:*;
	public var duration:Number;
	public var damage:Number;
	public var pierce:Number; // pct chance, from 0-1.0, that ammo will pierce the opponent and continue travelling
};

final class ClassAttributes
{
	public var maxHealth:Number;
	public var maxSpeed:Number;
	public var acceleration:Number;
	public var inertia:Number;
	public var hitRadius:Number;
	public var bounceType:BounceType;  // none, stop, die, fullbounce, halfbounce.....
	public var rotationalFirePoints:Array;
	public var bodyFirePoints:Array;

	public var ammo:AmmoClassAttributes;

	public var value:uint; // i.e. gold
}
