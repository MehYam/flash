package
{
	import flash.display.BitmapData;
	
	public class TestActor extends Actor
	{
		private static const s_frames:Array = ["pengoWait", "pengoWalkLeft", "pengoWalkUp", "pengoWalkRight", "pengoWalkDown"];
		
		private var _xml:XML;
		public function TestActor(imgdata:BitmapData, xml:XML):void
		{
			_xml = xml;

			super(new FrameAnimator(imgdata, Utils.directionToAnimatorNode(xml, velocity, s_frames)), false);
		}		

		private var _eventJiggles:uint = 0;
		private const _jiggleSize:uint = 6;
		private var _pausedFrames:uint = 0;
		override public function onEvent(event:uint):void
		{
			super.onEvent(event);
			switch(event) {
			case ActorEvent.BUMP:
				_eventJiggles = 4;
				break;
			case ActorEvent.HALT:
				_eventJiggles = 2;
				break;
			case ActorEvent.PUSHING:
			case ActorEvent.PAUSE:
				_pausedFrames = Consts.POST_PUSH_PAUSE_FRAMES;
				state = ActorState.PAUSED;
				
				velocity.x = 0;
				velocity.y = 0;
				break;
			case ActorEvent.CHANGE_VELOCITY:
				if (Utils.directionToFourWayIndex(velocity) != 0)
				{
					FrameAnimator(this.displayObject).node = Utils.directionToAnimatorNode(_xml, velocity, s_frames);
				} 
				break;
			}	
		}

		override public function onFrame(frame:uint):void
		{
			if (velocity.x != 0 || velocity.y != 0)
			{
				super.onFrame(frame);
			}
			if (_eventJiggles > 0)
			{
				const mod:uint = frame % _jiggleSize;
				const delta:uint = (Math.abs(mod - (_jiggleSize/2)));

				if (!delta)
				{
					--_eventJiggles;
				}
			}
			if (state == ActorState.PAUSED)
			{
				if (!--_pausedFrames)
				{
					state = ActorState.NORMAL;
				}
			} 
		}
		
	}
}