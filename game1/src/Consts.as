package
{
	public class Consts
	{
		static public const FRAMERATE:uint = 40;
		static public function millisecondsToFrames(ms:Number):Number
		{
			return ms * FRAMERATE / 1000;
		}
		static public function framesToMilliseconds(frames:Number):Number
		{
			return frames * 1000 / FRAMERATE;
		}
		static public function isTankLevel(level:uint):Boolean
		{
			return (level % 2) == 0;
		}
		static public const CREDIT_FIELD_COLOR:uint = 0xffcc33;
		
		static public const LEVELS:uint = 35;
		
		static public const TANK_SCALE:Number = 0.8;
		
		static public const SHIP_DROP_CHANCE:Number = 0.2;
	}
}