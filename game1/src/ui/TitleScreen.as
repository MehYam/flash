package ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import karnold.utils.FrameTimer;
	import karnold.utils.Util;
	
	public class TitleScreen extends Sprite
	{
		static private const LEFT:Number = 20;
		private var _typer:TextFieldTyper;
		public function TitleScreen()
		{
			super();
			
			var textField:TextField = new TextField();
			textField.x = LEFT;
			textField.y = 80;
			textField.autoSize = TextFieldAutoSize.LEFT;

			var format:TextFormat = new TextFormat("Computerfont", 24, 0x00ff00);
			textField.defaultTextFormat = format;

			var textFieldTyper:TextFieldTyper = new TextFieldTyper(textField, true);
			textFieldTyper.text = "Prepare Yourself For...";

			addChild(textField);
			
			textFieldTyper.timer.start(200);
			textFieldTyper.addEventListener(Event.COMPLETE, onPreambleComplete);
			_typer = textFieldTyper;  // mystery - shouldn't the event listener be putting a hard reference on this?   It gc's w/o this line

			Util.listen(this, Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onPreambleComplete(e:Event):void
		{
			var textFieldTyper:TextFieldTyper = TextFieldTyper(e.target);
			textFieldTyper.removeEventListener(e.type, arguments.callee);
			
			var textField:TextField = new TextField();
			textField.x = LEFT;
			textField.y = 150;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = new TextFormat("SF Transrobotics", 96, 0xffffff);
			addChild(textField);
			
			textFieldTyper.textField = textField;
			textFieldTyper.words = ["Plane", "Vs.", "Tank"];
			textFieldTyper.timer.start(1000);
			textFieldTyper.addEventListener(Event.COMPLETE, onTitleComplete);
		}

		private function onTitleComplete(e:Event):void
		{
			var textFieldTyper:TextFieldTyper = TextFieldTyper(e.target);
			textFieldTyper.removeEventListener(e.type, arguments.callee);

			var textField:TextField = new TextField();
			textField.x = LEFT;
			textField.y = stage.stageHeight - 30;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = new TextFormat("Computerfont", 24, 0x00ff00);
			
			addChild(textField);
			
			textFieldTyper.textField = textField;
			textFieldTyper.sounds = false;
			textFieldTyper.text = "Press Any Key to Start";
			textFieldTyper.timer.start(100);
		}

		private function onAddedToStage(e:Event):void
		{
			Util.listen(stage, KeyboardEvent.KEY_DOWN, onUserDismissed);
			Util.listen(stage, MouseEvent.MOUSE_DOWN, onUserDismissed);
			
			graphics.beginFill(0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}
		private function onUserDismissed(e:Event):void
		{
			_typer.timer.stop();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private var _fade:FrameTimer = new FrameTimer(tweenAlpha);
		public function fadeAndRemoveSelf():void
		{
			_fade.startPerFrame();
		}
		private function tweenAlpha():void
		{
			this.alpha -= 0.01;
			if (this.alpha < 0.05)
			{
				parent.removeChild(this);
				_fade.stop();
			}
		}
	}
}