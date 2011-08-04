package karnold.utils
{
	import flash.display.Stage;
	
	//
	// This is a near drop-in replacement for Flash.util.Timer that saves some gc burden by not creating
	// Event objects.  FrameTimers are lightweight and incur no cost until they're started.
	//
	// FrameTimer attempts to mimic the flash.util.Timer interface and semantics, with some minor changes. 
	// The big difference is that FrameTimer.init() MUST BE CALLED at some point to make the events work at all.
	//
	// [kja] One key to this implementation is that it stores a hard reference back to the callback
	// Function object that you pass in.  Consequently, it causes the same ownership lifetime
	// that a hard event listener would.  But this usually doesn't matter, since the object with the
	// callback is the one that owns the FrameTimer - if that object is ready for gc, the FrameTimer
	// won't prevent it.
	public class FrameTimer
	{
		private static var s_engine:FrameTimerEngine;
		public static function init(stage:Stage):void
		{
			if (!stage) {
				throw new Error("FrameTimer is being initialized with a null Stage value!");
			}
			if (!s_engine)
			{
				s_engine = new FrameTimerEngine();  // because AS3 won't let you statically create an internal class
			}
			s_engine.init(stage);
		}
		// [kja] useful for debugging what frame you're on.  This number doesn't increment when no FrameTimer instances are running.
		public static function get frames():uint
		{
			return FrameTimerEngine.s_frames;
		}
		private var _callback:Function;
		public function FrameTimer(callback:Function)
		{
			_callback = callback;
		}
		
		// Calling start on an already running timer will reset its start time and count
		public function start(delay:int, count:int = 0):void // count of 0 == infinity
		{
			start_impl(delay, count, false);
		}
		// Calling start on an already running timer will reset its start frame and count.  For timers that are set to fire every frame,
		// this will not postpone the upcoming frame callback
		public function startPerFrame(intervalInFrames:int = 0, count:int = 0):void // count of 0 == infinity
		{
			start_impl(intervalInFrames, count, true);
		}
		private var _checkpoint:ICheckpoint;
		private function start_impl(delay:int, count:int, perFrame:Boolean):void
		{
			if (!s_engine)
			{
				throw "FrameTimer started without FrameTimer.init() first being called"; 
			}
			
			_delay = delay;
			_repeatCount = count;
			_currentCount = 0;

			// [kja] recycle existing checkpoints to reduce gc burden as timers are stopped/restarted
			if (perFrame)
			{
				if (_checkpoint as FrameCheckpoint)
				{
					_checkpoint.reset();
				}
				else
				{
					_checkpoint = new FrameCheckpoint;
				}
			}
			else
			{
				if (_checkpoint as TimeCheckpoint)
				{
					_checkpoint.reset();
				}
				else
				{
					_checkpoint = new TimeCheckpoint;
				}
			}
			s_engine.add(this);
		}

		public function stop():void
		{
			s_engine.remove(this);
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
			return s_engine ? s_engine.has(this) : false;
		}
				
		//
		// [kja] for test purposes only - if you use this, expect that your build may break. 
		public static function _debug_die():void
		{
			s_engine.die();
		}
		
		// DO NOT CALL THIS.  Actionscript doesn't support the notion of private interfaces, if it did, we'd pass
		// one to the engine so that only it can call this.  A private interface can be accomplished via a proxy object,
		// but meh.
		public function z_internal_fire():void
		{
			if (_checkpoint.tryToFire(_delay))
			{
				if (_callback != null)
				{
					_callback();
						
					++_currentCount;
				}
			}
			if (repeatCount && _currentCount >= _repeatCount)
			{
				stop();
			}
		}
	}
}
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import karnold.utils.FrameTimer;

final class FrameTimerEngine
{
	private var s_stage:Stage;
	public function init(stage:Stage):void
	{
		s_stage = stage;
		manageEnterFrameListener();
	}

	private var _timers:Dictionary = new Dictionary(true);  // map of FrameTimer => checkpoint
	private var _numTimersProbably:int = 0;
	public function add(timer:FrameTimer):void
	{
		_timers[timer] = true;
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
	static public var s_frames:uint;
	private function onEnterFrame(e:Event):void
	{
		++s_frames;

		//
		// Loop all active timers, fire as necessary 
		var numTimersNow:int = 0;
		const now:int = getTimer();
		for (var key:Object in _timers)
		{
			var timer:FrameTimer = FrameTimer(key);
			timer.z_internal_fire();

			if (timer.running)			
			{
				++numTimersNow;
			}
		}
		_numTimersProbably = numTimersNow;
		manageEnterFrameListener();
	}

	private var _debug_dead:Boolean = false;
	public function die():void { _debug_dead = true; s_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);}	
	
	private var _running:Boolean = false;
	private function manageEnterFrameListener():void
	{
		if (_debug_dead)
		{
			trace("FrameTimer debug dead");
			return;
		}

		//
		// Toggle the enter frame listener, trying to do it a little intelligently to avoid redundant add/removeEventListener calls
		const shouldRun:Boolean = _numTimersProbably > 0; 
		if (s_stage && _running != shouldRun)
		{
			if (shouldRun)
			{
				trace("FrameTimer adding enter frame for", _numTimersProbably, "timers");
				s_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			}
			else
			{
				trace("FrameTimer killing enter frame");
				s_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			_running = shouldRun;
		}
	}
}
interface ICheckpoint
{
	function reset():void;
	function tryToFire(delay:int):Boolean;  // return true if fired
}
final class TimeCheckpoint implements ICheckpoint
{
	private var _lastFire:int = getTimer();
	public function tryToFire(delay:int):Boolean
	{
		const now:int = getTimer();
		if (now >= (delay + _lastFire))
		{
			_lastFire = now;
			return true;
		} 
		return false;
	}
	public function reset():void
	{
		_lastFire = getTimer();
	}
}
final class FrameCheckpoint implements ICheckpoint
{
	private var _frames:int = 0;
	public function tryToFire(delay:int):Boolean
	{
		++_frames;
		if (_frames >= delay)
		{
			_frames = 0;
			return true;
		}
		return false;
	}
	public function reset():void
	{
		_frames = 0;
	}
}