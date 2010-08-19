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
		
		static public const CREDIT_FIELD_COLOR:uint = 0xffcc33;
		
		static public const LEVELS:uint = 35;
	}
}