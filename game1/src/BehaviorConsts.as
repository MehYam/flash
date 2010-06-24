package
{
	final public class BehaviorConsts
	{
		static public const GREEN_SHIP:BehaviorConsts = new BehaviorConsts(1.5, 0.1);
		static public const RED_SHIP:BehaviorConsts = new BehaviorConsts(3, 0.1);
		static public const BULLET:BehaviorConsts = new BehaviorConsts(10, 10);

		public var MAX_SPEED:Number;
		public var ACCELERATION:Number;
		public function BehaviorConsts(speed:Number, accel:Number)
		{
			MAX_SPEED = speed;
			ACCELERATION = accel;
		}
	};
}