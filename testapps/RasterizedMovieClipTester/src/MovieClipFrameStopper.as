package
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	
	public class MovieClipFrameStopper
	{
		public static const MC_STOP_MARKER:String = "mcffStopped";

		private var _mc:MovieClip;
		private var _original:Function;
		private var _frameIndex:int;
private static var s_instances:int;		
		public function MovieClipFrameStopper(mc:MovieClip, frame:Object = null)
		{
++s_instances;
if ((s_instances % 100) == 0)
{
	trace("MovieClipFrameStopper ", s_instances, " instances");
}
			//
			// First resolve the intended stop point based upon how it's indicated
			if (frame)
			{
				if (frame is String)
				{
					for each (var frameLabel:FrameLabel in mc.currentLabels)
					{
						if (frameLabel.name == frame)
						{
							_frameIndex = frameLabel.frame - 1;
							break;
						}
					}
				}
				else
				{
					_frameIndex = int(frame) - 1;
				}
			}
			else
			{
				_frameIndex = mc.currentFrame - 1;
			}

			const frameNumber:int = _frameIndex + 1;

			_mc = mc;
			_original = mc["frame" + frameNumber];
			if (_original != null)
			{
				_mc.addFrameScript(_frameIndex, frameScript);
			}
			
			_mc.gotoAndStop(frameNumber);
			_mc[MC_STOP_MARKER] = true;
		}
		
		private var _hasRun:Boolean = false;
		private function frameScript():void
		{
trace("MovieClipFrameStopper.frameScript!");

			//KAI: explain
			//KAI: in our playAllMovieClips, we can call the original method directly!
			if (!_hasRun)
			{
				_hasRun = true;
			}
			else
			{				
				_mc.addFrameScript(_frameIndex, _original);
				_original = null;
				_mc = null;
			}
		}
	}
}