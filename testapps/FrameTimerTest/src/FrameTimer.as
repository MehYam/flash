package
{
	import flash.display.Stage;
	
	//
	// This should be a drop-in replacement for Flash.util.Timer - it attempts to mimic its interface and semantics as closely as possible.
	// The main difference is that FrameTimer.init() needs to be called at some point in order to prime the static state with a stage
	// object
	public class FrameTimer
	{
		private static var s_impl:FrameTimerImpl;
		public static function init(stage:Stage):void
		{
			if (!s_impl)
			{
				s_impl = new FrameTimerImpl();  // because AS3 won't let you statically create an internal class
			}
			s_impl.init(stage);
		}

		private var _callback:Function;
		public function FrameTimer(callback:Function)
		{
			if (!s_impl)
			{
				s_impl = new FrameTimerImpl(); // because AS3 won't let you statically create an internal class 
			}

			_callback = callback;
		}

		public function start(delay:int, count:int = 0):void // count of 0 == infinity
		{
			_delay = delay;
			_repeatCount = count;

			s_impl.add(this);
		}
		public function startPerFrame(perFrame:int = 0, count:int = 0):void // count of 0 == infinity
		{
			if (perFrame > 0)
			{
				throw "frame skipping not yet implemented";
			}
			start(0, count);
		}
		public function stop():void
		{
			s_impl.remove(this);
		}

		private var _delay:int;
		private var _currentCount:int;
		private var _repeatCount:int;
		public function get delay():int
		{
			return _delay;
		}
		public function get currentCount():int
		{
			return _currentCount;
		}
		public function get repeatCount():int
		{
			return _repeatCount;
		}
		public function get running():Boolean
		{
			return s_impl ? s_impl.has(this) : false;
		}

		// unfortunately, not really meant to be public - don't call this.
		public function fire():void
		{
			if (_callback != null)
			{
				_callback();
				
				++_currentCount;
			}
		}
	}
}
	import flash.display.Stage;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import flash.utils.getTimer;
	

class FrameTimerImpl
{
	private var s_stage:Stage;
	public function init(stage:Stage):void
	{
		s_stage = stage;
		manageEnterFrameListener();
	}

	private var _timers:Dictionary = new Dictionary(true);  // map of FrameTimer => last fired timestamp
	private var _numTimersProbably:int = 0;
	public function add(timer:FrameTimer):void
	{
		_timers[timer] = getTimer();
		++_numTimersProbably; // Approximate because timers are weakly referenced... but good enough for how we use it

		manageEnterFrameListener();
	}
	
	public function remove(timer:FrameTimer):void
	{
		delete _timers[timer];
	}

	public function has(timer:FrameTimer):Boolean
	{
		return _timers[timer] != null;
	}
	private function onEnterFrame(e:Event):void
	{
		//
		// Loop all active timers, fire as necessary 
		var numTimersNow:int = 0;
		const now:int = getTimer();
		for (var key:Object in _timers)
		{
			var timer:FrameTimer = FrameTimer(key);
			var lastFired:int = _timers[key];
			
			if (now >= (lastFired + timer.delay))
			{
				timer.fire();
				_timers[key] = now;
			}
			if (timer.repeatCount && timer.currentCount >= timer.repeatCount)
			{
				timer.stop();  // coupling:  we're relying on timer to remove itself from us
			}
			else
			{
				++numTimersNow;
			}
		}
		_numTimersProbably = numTimersNow;
		manageEnterFrameListener();
	}
	private var _running:Boolean = false;
	private function manageEnterFrameListener():void
	{
		//
		// Toggle the enter frame listener, trying to do it a little intelligently to avoid redundant add/removeEventListener calls
		const shouldRun:Boolean = _numTimersProbably > 0; 
		if (s_stage && _running != shouldRun)
		{
			if (shouldRun)
			{
				s_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			}
			else
			{
				s_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			_running = shouldRun;
		}
	}
}