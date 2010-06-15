package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.utils.Dictionary;

	public class FrameTimerTest extends Sprite
	{
		private var _timer:FrameTimer;

		public function FrameTimerTest()
		{
//			doWeakReferenceTest();
			doFrameTimerTest();
//			doExternalFrameTimerTest();

			FrameTimer.init(stage);
		}
		
		private function doFrameTimerTest():void
		{
			_timer = new FrameTimer(onFrameTimer);
//			_timer.start(3000);
			_timer.startPerFrame(0, 1);
		}
		
		private function doExternalFrameTimerTest():void
		{
			addChild(new SampleFrameTimerConsumer);
		}

		private function onFrameTimer():void
		{
			trace("frame timer");
			
			_timer = null;
		}

////// Weak reference test - the ability for our custom timer implementation to work without leaks hinges on this behavior
		private var _dict:Dictionary = new Dictionary(true);
		private function doWeakReferenceTest():void
		{
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			addOne();
			addOne();
			addOne();
			addOne();
			addOne();
			addOne();
			addOne();
			
			reportSize();
		}		
		private var _storeUsers:Array = [];
		private function addOne():void
		{
			var user:TimerUser = new TimerUser;
//			_storeUsers.push(user);

			var timer:TimerObject = new TimerObject(user); 

			user.timer = timer;

			_dict[timer] = new TimerObjectData;
		}
		
		private var _count:int = 0;
		private function onEnterFrame(e:Event):void
		{
			reportSize();
			
			if (++_count == 100)
			{
				System.gc();
			}
		}

		private function reportSize():void
		{
			var size:int = 0;
//			for each (var tod:TimerObjectData in _dict)
			for (var timerObject:Object in _dict)
			{
				if (!(timerObject is TimerObject))
				{
					throw 'whut?';
				}
				++size;

				TimerObject(timerObject).fire();
			}
			trace("We have", size, "timers");
		}
	}
}

class TimerUser
{
	public function func():void
	{
		trace("TimerUser.func");
	}

	private var _tobj:TimerObject;	
	public function set timer(tobj:TimerObject):void
	{
		_tobj = tobj;
	}
}

class TimerObject
{
	private var _timerUserFunction:Function;
	public function TimerObject(user:TimerUser)
	{
		_timerUserFunction = user.func;
	}
	
	public function fire():void
	{
		_timerUserFunction();
	}
}

class TimerObjectData
{
	
}