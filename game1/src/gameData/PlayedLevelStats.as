package gameData
{
	import flash.utils.getTimer;

	final public class PlayedLevelStats
	{
		public var creditsEarned:uint;
		public var enemiesKilled:uint;
		public var enemiesTotal:uint;
		public var maxCombo:uint;
		public var damageDealt:Number = 0;
		public var damageReceived:Number = 0;
		public var victory:Boolean;

		private var _combo:uint;
		
		public function set combo(c:uint):void
		{
			_combo = c;
			if (_combo > maxCombo)
			{
				maxCombo = _combo;
			}
		}
		public function get combo():uint
		{
			return _combo;
		}
		private var _start:uint;
		private var _end:uint;
		public function begin():void
		{
			_start = getTimer();
		}
		public function end():void
		{
			_end = getTimer();
		}
		public function get elapsed():uint
		{
			return _end - _start;
		}
	}
}