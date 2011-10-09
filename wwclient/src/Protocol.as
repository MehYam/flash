package
{
	public class Protocol
	{
		public function Protocol()
		{
		}
		private var _handler:IProtocolHandler;
		public function set handler(h:IProtocolHandler):void
		{
			_handler = h;
			if (_handler)
			{
				_handler.addPlayer("guest", 0);
			}
		}
		static private const WORD_SCORE:Array = [0, 0, 0, 10, 20, 40, 70];
		static private const LETTER_BONUS:uint = 40;
		public function submitWord(word:String):void
		{
			if (_handler && word.length > 2)
			{
				const score:int = word.length < WORD_SCORE.length ? (WORD_SCORE[word.length]) : (WORD_SCORE[WORD_SCORE.length-1] + LETTER_BONUS * (1 + word.length-WORD_SCORE.length));
				_handler.scoreWord("guest", word, score);
			}
		}
		public function submitChat(text:String):void
		{
			if (_handler)
			{
				_handler.chatText("guest", text);
			}
		}
	}
}