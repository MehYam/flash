package ui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	
	import flash.display.DisplayObject;
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
	
	import gameData.UserData;
	
	import karnold.ui.ShadowTextField;
	import karnold.utils.FrameTimer;
	import karnold.utils.Util;
	
	public class TitleScreen extends Sprite
	{
		static private const LEFT:Number = 20;
		static private const PREAMBLES:Array =
		[
			"Prepare yourself for...",
			"Lookout, it's...",
			"It's about to get real...",
			"Whatcha gonna do, when they come for you...",
			"Get your shooting skills on, it's...",
			"Now your ships are burned, it's...",
			"Hungry for killage?  It's..."
		];
		private var _typer:TextFieldTyper;
		public function TitleScreen()
		{
			super();
			
			var textField:TextField = new TextField();
			textField.selectable = false;
			textField.x = LEFT;
			textField.y = 80;
			textField.autoSize = TextFieldAutoSize.LEFT;

			var format:TextFormat = AssetManager.instance.createFont(AssetManager.FONT_COMPUTER, 24, 0x00ff00);
			textField.defaultTextFormat = format;
			textField.embedFonts = true;

			var textFieldTyper:TextFieldTyper = new TextFieldTyper(textField, true);
			textFieldTyper.text = PREAMBLES[uint(Math.random() * PREAMBLES.length)];

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
			
			var textField:ShadowTextField = new ShadowTextField(0xffffff, 0x666688, 5);
			AssetManager.instance.assignFont(textField, AssetManager.FONT_ROBOT, 96); 
			textField.x = LEFT;
			textField.y = 150;
			addChild(textField);
			
			textFieldTyper.textField = textField;
			textFieldTyper.words = ["Plane", "Vs.", "Tank"];
			textFieldTyper.timer.start(1000);
			textFieldTyper.addEventListener(Event.COMPLETE, onTitleComplete);
		}

		private var _titleComplete:Boolean = false;
		private var _continueButton:GameButton;
		static private const BUTTON_MARGIN:Number = 8;
		private function onTitleComplete(e:Event):void
		{
			var textFieldTyper:TextFieldTyper = TextFieldTyper(e.target);
			textFieldTyper.removeEventListener(e.type, arguments.callee);

			var instructions:GameButton = GameButton.create("Instructions");
			var continueButton:GameButton = GameButton.create("Continue");
			var newGameButton:GameButton = GameButton.create("New Game");
			
			const btnWidth:Number = Math.max(instructions.width, continueButton.width, newGameButton.width);

			Util.centerChild(continueButton, this);
			continueButton.y = 325;
			continueButton.width = btnWidth;
			continueButton.enabled = UserData.instance.levelsBeaten > 0;
			addChild(continueButton);
			
			_continueButton = continueButton;
			
			newGameButton.x = continueButton.x;
			newGameButton.y = continueButton.y + continueButton.height + BUTTON_MARGIN;
			newGameButton.width = btnWidth;
			addChild(newGameButton);

			instructions.width = btnWidth;
			instructions.x = newGameButton.x;
			instructions.y = newGameButton.y + newGameButton.height + BUTTON_MARGIN;
			addChild(instructions);
			
			Util.listen(newGameButton, MouseEvent.CLICK, onNewGame);
			Util.listen(continueButton, MouseEvent.CLICK, onContinue);
			Util.listen(instructions, MouseEvent.CLICK, onInstructions);
			_titleComplete = true;
		}

		private function onAddedToStage(e:Event):void
		{
			Util.listen(stage, KeyboardEvent.KEY_DOWN, onUserImpatient);
			Util.listen(stage, MouseEvent.MOUSE_DOWN, onUserImpatient);

			enabled = true;
			if (_continueButton)
			{
				_continueButton.enabled = UserData.instance.levelsBeaten > 0;
			}
			graphics.beginFill(0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}
		private function onUserImpatient(e:Event):void
		{
			if (!_titleComplete)
			{
				_typer.skip();
			}
		}
		private function onNewGame(e:Event):void
		{
			enabled = false;
			dispatchEvent(new TitleScreenEvent(TitleScreenEvent.NEW_GAME));
		}
		private function onContinue(e:Event):void
		{
			enabled = false;
			dispatchEvent(new TitleScreenEvent(TitleScreenEvent.CONTINUE));
		}
		private function onInstructions(e:Event):void
		{
			enabled = false;
			dispatchEvent(new TitleScreenEvent(TitleScreenEvent.INSTRUCTIONS));
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
		public function set enabled(b:Boolean):void
		{
			// lame - TitleScreen ends up being the parent for the other dialogs, so for now manually enable the controls
			for (var i:uint = 0; i < numChildren; ++i)
			{
				var btn:GameButton = getChildAt(i) as GameButton;
				if (btn)
				{
					btn.enabled = b;
				}
			}
		}
	}
}