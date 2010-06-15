package
{
	import flash.events.EventDispatcher;

	public class SomeClass extends EventDispatcher
	{
		public function SomeClass(source:EventDispatcher)
		{
			super();
			
			source.addEventListener(SomeEvent.EVENT1, event1, false, 0, true);
			source.addEventListener(SomeEvent.EVENT2, event2, false, 0, true);
		}

		private function event1(e:SomeEvent):void
		{
			trace("SomeClass received event1");
			dispatchEvent(new SomeEvent(e.type));
		}
		
		private function event2(e:SomeEvent):void
		{
			trace("SomeClass received event2");
			dispatchEvent(new SomeEvent(e.type));	
		}
	}
}