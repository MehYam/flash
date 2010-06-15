package
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class EnemyActor extends Actor
	{
		private static const s_framesWalk:Array = ["enemyWalkDown", "enemyWalkLeft", "enemyWalkUp", "enemyWalkRight", "enemyWalkDown"];
		private static const s_framesSmash:Array = ["enemySmashDown", "enemySmashLeft", "enemySmashUp", "enemySmashRight", "enemySmashDown"];
		private static const s_frameTickled:String = "enemyCrush";

		private var _xml:XML;
		public function EnemyActor(imgdata:BitmapData, xml:XML)
		{
			_xml = xml;

			super(new FrameAnimator(imgdata, Utils.directionToAnimatorNode(xml, velocity, s_framesWalk)), false);
		}

		public var destination:Number = 0;
		public var bCrushing:Boolean = true;

		private var _crushingFramesBeforeSwap:int = 0;
		private var _deathFrames:uint = Consts.ENEMY_DEATH_FRAMES;
		private var _pausedFrames:uint = 0;
		private var _lastPosition:Point = new Point();
		private var _lastVelocity:Point = new Point(); 		
		override public function onFrame(frame:uint):void
		{
			super.onFrame(frame);
			if (state == ActorState.DYING)
			{
				if (--_deathFrames == 0)
				{
					state = ActorState.DEAD;
				}
			}
			else if (state == ActorState.PAUSED)
			{
				if (--_pausedFrames == 0)
				{
					state = ActorState.NORMAL;
				}
			}
			else if (state == ActorState.NORMAL) 
			{
				--_crushingFramesBeforeSwap;
				if (_crushingFramesBeforeSwap <= 0)
				{
					bCrushing = !bCrushing;
					
					_crushingFramesBeforeSwap = Utils.randomInt(Consts.ENEMY_MIN_CRUSHING_FRAMES, (bCrushing ? Consts.ENEMY_MAX_CRUSHING_FRAMES : Consts.ENEMY_MAX_NON_CRUSHING_FRAMES));
				}
				//
				// if velocity *and* position have changed, choose the new directional animation.  This lets the AI sit there
				// for a few frames trying to figure out the next direction (imitates the original game's behavior)
				if ((_lastPosition.x != displayObject.x || _lastPosition.y != displayObject.y) && !_lastVelocity.equals(velocity))
				{
					FrameAnimator(this.displayObject).node = Utils.directionToAnimatorNode(_xml, velocity, (bCrushing ? s_framesSmash : s_framesWalk));
				}
				
				if (_slowedFrames > 0)
				{
					--_slowedFrames;
				}
			}
		}
		
		private var _slowedFrames:int = 0;
		override public function onEvent(event:uint):void
		{
			super.onEvent(event);
			switch(event) {
				case ActorEvent.DEATH:
					state = ActorState.DYING;
					break;
				case ActorEvent.PAUSE:
					_pausedFrames = Consts.ENEMY_TICKLE_FRAMES;
					FrameAnimator(this.displayObject).node = Utils.selectAnimatorNode(_xml, s_frameTickled);
					break;
				case ActorEvent.PUSHING:
					_slowedFrames = Consts.ENEMY_SLOWED_FRAMES;
					break;
			}
		}
		
		public function get walkSpeed():Number
		{
			return (_slowedFrames > 0) ? Consts.ENEMY_WALK_SPEED_SLOWED : Consts.ENEMY_WALK_SPEED;
		}
	}
}