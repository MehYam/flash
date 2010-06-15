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
				_handler.addPlayer("kai", 0);
			}
		}

		public function submitWord(word:String):void
		{
			if (_handler)
			{
				_handler.scoreWord("player" + Math.random()*10, word, word.length * 10);
			}
		}
		public function submitChat(text:String):void
		{
			
		}
	}
}