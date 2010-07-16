package ui
{
	import flash.events.Event;
	
	public class TitleScreenEvent extends Event
	{
		static public const NEW_GAME:String = "TitleScreenEvent.newgame";
		static public const CONTINUE:String = "TitleScreenEvent.continue";
		public function TitleScreenEvent(type:String)
		{
			super(type, false, false);
		}
	}
}