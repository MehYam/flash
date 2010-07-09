package karnold.utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	public class SoundController
	{
		private var _loader:Loader = new Loader;
		public function SoundController()
		{
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
			_loader.load(new URLRequest("assets/sound.swf"));
		}
		private var _ready:Boolean = false;
		private function onComplete(e:Event):void
		{
			_ready = true;
			if (_currentMusicTrack)
			{
				playMusic(_currentMusicTrack);
			}
		}
		
		private var _channels:Object = {};
		public function playSound(sound:String, loop:Boolean = false):void
		{
			if (_ready)
			{
				if (!_channels[sound])
				{
					var clss:Object = _loader.contentLoaderInfo.applicationDomain.getDefinition(sound);
					var instance:Sound = new clss;
					_channels[sound] = new SoundAndChannel(instance);
				}
				SoundAndChannel(_channels[sound]).play(loop);
			}
		}
		
		private var _currentMusicTrack:String;
		public function playMusic(music:String):void
		{
			_currentMusicTrack = music;
			playSound(music, true);
		}
		public function stopMusic():void
		{
			if (_channels[_currentMusicTrack])
			{
				SoundAndChannel(_channels[_currentMusicTrack]).stop();
			}
		}
	}
}
import flash.media.Sound;
import flash.media.SoundChannel;

internal class SoundAndChannel
{
	private var _sound:Sound;
	private var _channel:SoundChannel;
	
	public function SoundAndChannel(s:Sound)
	{
		_sound = s;
	}
	public function play(loop:Boolean):void
	{
		_channel = _sound.play(0, loop ? 1000 : 0);
	}
	public function stop():void
	{
		if (_channel)
		{
			_channel.stop();
		}
	}
}