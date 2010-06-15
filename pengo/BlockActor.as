package
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	public class BlockActor extends Actor
	{
		private static const s_frame:String = "brick";
		private static const s_frameDissolve:String = "brickDissolve";

		private var _xml:XML;
		public function BlockActor(imgdata:BitmapData, xml:XML)
		{
			_xml = xml;
			super(new FrameAnimator(imgdata, Utils.selectAnimatorNode(xml, s_frame), false), true);
		}

		public var streak:StreakEffect = null;

		private var _deathFrames:uint = Consts.BLOCK_DEATH_FRAMES;		
		override public function onEvent(e:uint):void
		{
			if (e == ActorEvent.DEATH)
			{
				state = ActorState.DYING;
				
				FrameAnimator(displayObject).node = Utils.selectAnimatorNode(_xml, s_frameDissolve);
			}
		}
		
		override public function onFrame(frame:uint):void
		{
			super.onFrame(frame);
			if (state == ActorState.DYING)
			{
				if (FrameAnimator(displayObject).done())
				{
					state = ActorState.DEAD;
				}
			}	
		}
	}
}