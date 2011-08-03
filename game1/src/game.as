package 
{
	import behaviors.BehaviorFactory;
	import behaviors.IBehavior;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import gameData.PlayedLevelStats;
	import gameData.UserData;
	
	import karnold.tile.BitmapTileFactory;
	import karnold.tile.ITileFactory;
	import karnold.tile.TiledBackground;
	import karnold.ui.ShadowTextField;
	import karnold.utils.Array2D;
	import karnold.utils.Bounds;
	import karnold.utils.FrameTimer;
	import karnold.utils.Input;
	import karnold.utils.Location;
	import karnold.utils.MathUtil;
	import karnold.utils.ToolTipMgr;
	import karnold.utils.Util;
	
	import scripts.GameScript;
	import scripts.IGameScript;
	import scripts.TankActor;
	
	import ui.GameToolTip;
	import ui.LevelCompleteDialog;
	import ui.LevelSelectionDialog;
	import ui.MessageBox;
	import ui.TestDialog;
	import ui.TextFieldTyper;
	import ui.TitleScreen;
	import ui.TitleScreenEvent;
	import ui.UIUtil;

	[SWF(backgroundColor="#0")]
	public final class game extends Sprite implements IGame
	{
		private var _input:Input;
		private var _player:Actor;
		private var _frameTimer:FrameTimer;
		private var _frameRate:GameFrameRatePanel;
		
		private var _hudLayer:DisplayObjectContainer;
		private var _actorLayer:DisplayObjectContainer;
		public function game()
		{
			trace("stage", stage.stageWidth, stage.stageHeight);
//			stage.align = StageAlign.TOP_LEFT;
//			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = Consts.FRAMERATE;
			stage.focus = stage;
			mouseChildren = false;
			mouseEnabled = false;

			FrameTimer.init(stage);
			_frameTimer = new FrameTimer(onFrame);

			_input = new Input(stage);
			_input.enableMouseMove(stage);
			
			_actorLayer = new Sprite;
			this.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			_actorLayer.scrollRect = this.scrollRect;
			parent.addChild(_actorLayer);
			
			_hudLayer = new Sprite;
			parent.addChild(_hudLayer);

			toTitleScreen();
		}
		private var _title:DisplayObjectContainer;
		private function toTitleScreen(fadeIn:Boolean = false):void
		{
			if (!_title)
			{
				ToolTipMgr.instance.tooltip = new GameToolTip;			
				_title = new TitleScreen;
			}
			if (fadeIn)
			{
				UIUtil.fadeIn(_title);
			}
			else
			{
				_title.alpha = 1;
			}
			parent.addChild(_title);
			
			Util.listen(_title, TitleScreenEvent.NEW_GAME, onNewGame);
			Util.listen(_title, TitleScreenEvent.CONTINUE, onContinue);
		}
		private function onNewGame(e:Event):void
		{
//			UIUtil.openDialog(this, new MessageBox("Confirm", "Are you sure you want to start a new game?  All previous saved data will be lost."));
			startLevel(0);
		}
		private function onContinue(e:Event):void
		{
			toLevelSelectionDialog();
		}
		private var _levelSelectionDialog:LevelSelectionDialog;
		private function toLevelSelectionDialog():void
		{
			if (!_levelSelectionDialog)
			{
				_levelSelectionDialog = new LevelSelectionDialog;
				UIUtil.openDialog(_title, _levelSelectionDialog);
				
				Util.listen(_levelSelectionDialog, Event.SELECT, onLevelSelected);
			}
		}
		private function onLevelSelected(e:Event):void
		{
			startLevel(_levelSelectionDialog.selection);
		}
		private var _currentScript:IGameScript;
		private var _lastStartedLevel:uint;
		private function startLevel(level:uint):void
		{
			_lastStartedLevel = level;
			_mobsStunned = false;
			unpause();

			if (_title && _title.parent)
			{
				UIUtil.fadeAndRemove(_title);
			}

			if (_radar)
			{
				_radar.clear();
			}
//			_currentScript = GameScript.testScript1;
//			_currentScript = GameScript.testScript2;
			_currentScript = GameScript.getLevel(level);
			_currentScript.begin(this);
			
			stage.focus = stage;
		}

		private var _tiles:TiledBackground;
		private var _worldBounds:Bounds;

		private var _cast:Cast = new Cast;
		private var _lastPlayerPos:Point = new Point;
		private var _cameraPos:Point = new Point;
		private var _lastCameraPos:Point = new Point;
		private var _lastPurge:int;
		private var _shooting:ShootState = ShootState.NONE;
		private var _debugFlag:Boolean = false;  // used for incidental things
		private function onFrame():void
		{
			if (_globalBehavior)
			{
				_globalBehavior.onFrame(this, null);
			}

			//
			// Toggle framerate panel
			if (_input.checkKeyHistoryAndClear(Input.KEY_TILDE))
			{
				_debugFlag = !_debugFlag;
				if (!_frameRate)
				{
					_frameRate = new GameFrameRatePanel(this);
				}
				if (_frameRate.parent)
				{
					_frameRate.enabled = false;
					_frameRate.parent.removeChild(_frameRate);
				}
				else
				{
					_frameRate.enabled = true;
					_frameRate.y = _sb.y + _sb.height;
					parent.addChild(_frameRate);
				}
			}
			
			//
			// Apply user input to the player object
			var speed:Point = _player.speed;
			var playerImpelled:Boolean = false;
			if (!_mobsStunned)
			{
				if (_input.isKeyDown(Input.KEY_RIGHT))
				{
					speed.x = Math.min(_player.attrs.MAX_SPEED, speed.x + _player.attrs.ACCELERATION);
					playerImpelled = true;
				}
				else if (_input.isKeyDown(Input.KEY_LEFT))
				{
					speed.x = Math.max(-_player.attrs.MAX_SPEED, speed.x - _player.attrs.ACCELERATION);
					playerImpelled = true;
				}
				else if (speed.x)
				{
					speed.x = MathUtil.speedDecay(speed.x, _player.attrs.SPEED_DECAY);
				}
				if (_input.isKeyDown(Input.KEY_DOWN))
				{
					speed.y = Math.min(_player.attrs.MAX_SPEED, speed.y + _player.attrs.ACCELERATION);
					playerImpelled = true;
				}
				else if (_input.isKeyDown(Input.KEY_UP))
				{
					speed.y = Math.max(-_player.attrs.MAX_SPEED, speed.y - _player.attrs.ACCELERATION);
					playerImpelled = true;
				}
				else if (speed.y)
				{
					speed.y = MathUtil.speedDecay(speed.y, _player.attrs.SPEED_DECAY);
				}
			}

			player.underForce = playerImpelled;

			//
			// Reposition the player and the background tiles as necessary
			_player.onFrame(this);

			if (!_lastPlayerPos.equals(_player.worldPos))
			{
				Util.setPoint(_lastPlayerPos, _player.worldPos);
				positionPlayerAndCamera();
				if (!_cameraPos.equals(_lastCameraPos))
				{
					Util.setPoint(_lastCameraPos, _cameraPos);
					_tiles.setCamera(_cameraPos);
				}
				_radar.plot(_player, 0x87DDFF);
			}

			if (!_mobsStunned)
			{
				if (_input.isKeyDown(Input.KEY_SPACE))
				{
					_shooting = ShootState.KEYBOARDSHOOTING;
					_currentScript.onPlayerShooting(this, false);
				}
				else if (_input.isKeyDown(Input.MOUSE_BUTTON))
				{
					_shooting = ShootState.MOUSESHOOTING;
					_currentScript.onPlayerShooting(this, true);
				}
				else if (_shooting != ShootState.NONE)
				{
					const mouse:Boolean = _shooting == ShootState.MOUSESHOOTING;
					_shooting = ShootState.NONE;
					_currentScript.onPlayerStopShooting(this, mouse);
				}

				runFrameOnCast(_cast.friendlies);
				runFrameOnCast(_cast.enemies);
				runFrameOnCast(_cast.enemyAmmo);
				runFrameOnCast(_cast.friendlyAmmo);
				collisionCheck();
			}
			runFrameOnCast(_cast.effects);

			if (_radar)
			{
				for each (var enemy:Actor in _cast.enemies)
				{
					if (enemy.alive)
					{
						_radar.plot(enemy);
					}
				}
			}

			_cast.purgeDead();
			
			if (_frameRate && _frameRate.parent)
			{
				_frameRate.txt1 = this.numChildren;
				_frameRate.txt2 = _actorLayer.numChildren;
				_frameRate.txt3 = _cast.length;
				_frameRate.pooled = ActorPool.instance.size;
			}
		}

		private function collisionCheck():void
		{
			collisionCheckFriendly(_player);
			for each (var friendly:Actor in _cast.friendlies)
			{
				if (friendly && friendly.alive)
				{
					collisionCheckFriendly(friendly);
				}
			}
			
			// player ammo hits enemy
			for each (var ammo:Actor in _cast.friendlyAmmo)
			{
				if (ammo && ammo.alive)
				{
					for each (var enemy:Actor in _cast.enemies)
					{
//KAI: here's a great example of the blurry line between the game script and the game engine;
// here we could check for IPenetratingAmmo and call it accordingly, but the game script does
// that instead.  Which is better?  Who really is in charge of what?
						if (enemy && enemy.alive && MathUtil.distanceBetweenPoints(enemy.worldPos, ammo.worldPos) < (ammo.attrs.RADIUS + enemy.attrs.RADIUS))
						{
							_currentScript.onEnemyStruckByAmmo(this, enemy, ammo);
							if (!ammo.alive)
							{
								// script has terminated the ammo
								break;
							}
						}
					}
				}
			}
		}
		private function collisionCheckFriendly(friendly:Actor):void
		{
			// enemy hits friendly
			for each (var enemy:Actor in _cast.enemies)
			{
				if (enemy && enemy.alive && 
					MathUtil.distanceBetweenPoints(friendly.worldPos, enemy.worldPos) < (friendly.attrs.RADIUS + enemy.attrs.RADIUS))
				{
					_currentScript.onOpposingCollision(this, friendly, enemy);
				}
			}
			
			// enemy ammo hits friendly
			for each (var ammo:Actor in _cast.enemyAmmo)
			{
				if (ammo && ammo.alive && 
					MathUtil.distanceBetweenPoints(friendly.worldPos, ammo.worldPos) < (friendly.attrs.RADIUS + ammo.attrs.RADIUS))
				{
					_currentScript.onFriendlyStruckByAmmo(this, friendly, ammo);
				}
			}
			
		}
		private function runFrameOnCast(cast:Array):void
		{
			var index:uint = 0;
			for each (var a:Actor in cast)
			{
				if (a && a.alive)
				{
					a.onFrame(this);

					if (a.alive)
					{
						var dobj:DisplayObject = a.displayObject;
						dobj.x = a.worldPos.x - _cameraPos.x;
						dobj.y = a.worldPos.y - _cameraPos.y;
						
						// assume that if the displayobject is a bitmap, it's aligned to top left.  Else,
						// it's centered
						var recenter:Boolean = dobj is Bitmap;
						if (recenter)
						{
							dobj.x -= dobj.width/2;
							dobj.y -= dobj.height/2;
						}
						
						if (MathUtil.radiusIntersects(dobj.x, dobj.y, a.attrs.RADIUS, 0, 0, stage.stageWidth, stage.stageHeight))
						{
							if (!dobj.parent)
							{
								_actorLayer.addChild(dobj);
							}
						}
						else
						{
							if (dobj.parent)
							{
								dobj.parent.removeChild(dobj);
							}
						}
					}
					else
					{
						if (_radar)
						{
							_radar.remove(a);
						}

						ActorPool.instance.recycle(a);
						cast[index] = null;
					}
				}
				++index;
			}
		}

		// IGame implementation
		public function addFriendly(actor:Actor):void
		{
			_cast.friendlies.push(actor);
		}
		public function addEnemy(actor:Actor):void
		{
			// up to the caller to ensure enemies aren't added twice
			_cast.enemies.push(actor);
		}
		public function addEnemyAmmo(actor:Actor):void
		{
			_cast.enemyAmmo.push(actor);
		}
		public function addFriendlyAmmo(actor:Actor):void
		{
			_cast.friendlyAmmo.push(actor);
		}
		public function addEffect(actor:Actor):void
		{
			_cast.effects.push(actor);
		}
		public function convertToFriendlyAmmo(actor:Actor):void
		{
			for (var i:uint = 0; i < _cast.enemyAmmo.length; ++i)
			{
				if (_cast.enemyAmmo[i] == actor)
				{
					_cast.enemyAmmo[i] = null;
					addFriendlyAmmo(actor);
					break;
				}
			}
			Util.ASSERT(i < _cast.enemyAmmo.length);
		}
		public function killActor(actor:Actor):void
		{
			actor.alive = false;
			if (_radar)
			{
				_radar.remove(actor);
			}
		}
		public function get player():Actor
		{
			return _player;
		}
		public function get playerShooting():Boolean
		{
			return _shooting != ShootState.NONE;
		}
		public function get scoreBoard():ScoreBoard
		{
			return _sb;
		}
		public function get script():IGameScript
		{
			return _currentScript;
		}
		private var _radar:Radar;
		private var _sb:ScoreBoard;
		private var _lastTilesString:String;
		public function set tiles(str:String):void
		{
			if (str == _lastTilesString)
			{
				return;
			}
			_lastTilesString = str;

			if (_tiles)
			{
				_tiles.deparent();
			}
			const factory:ITileFactory = new BitmapTileFactory(AssetManager.instance);
			_tiles = TiledBackground.createFromString(this, factory, stage.stageWidth, stage.stageHeight, str);
			_worldBounds =  new Bounds(0, 0, factory.tileSize * _tiles.tilesArray.width, factory.tileSize*_tiles.tilesArray.height);
			
			if (_radar && _radar.parent)
			{
				_radar.parent.removeChild(_radar);
			}
			_radar = new Radar;
			_radar.render(_worldBounds, 150, 100);
			_radar.alpha = 0.7;
			_radar.x = stage.stageWidth - _radar.width - 5;
			_radar.y = 5;

			_hudLayer.addChild(_radar);

			if (_sb && _sb.parent)
			{
				_sb.parent.removeChild(_sb);
			}
			_sb = new ScoreBoard;
			_sb.x = 5;
			_hudLayer.addChild(_sb);
		}
		private var _globalBehavior:IBehavior;
		public function set globalBehavior(b:IBehavior):void
		{
			_globalBehavior = b;
		}
		private var _centerPrint:ShadowTextField;
		private var _textFieldTyper:TextFieldTyper;
		public function centerPrint(text:String):void
		{
			if (!_textFieldTyper)
			{
				_centerPrint = new ShadowTextField;
				AssetManager.instance.assignFont(_centerPrint, AssetManager.FONT_COMPUTER, 36);
				_textFieldTyper = new TextFieldTyper(_centerPrint, false);
				_textFieldTyper.postDelay = 3000;
				Util.listen(_textFieldTyper, Event.COMPLETE, onCenterPrintDone);
			}
			_centerPrint.text = text;
			_centerPrint.x = (stage.stageWidth - _centerPrint.width) / 2;
			_centerPrint.y = stage.stageHeight/2 - 40;
			_centerPrint.text = "";
			_hudLayer.addChild(_centerPrint);

			_textFieldTyper.text = text;
			_textFieldTyper.timer.start(100);
		}
		private function onCenterPrintDone(e:Event):void
		{
			_hudLayer.removeChild(_centerPrint);

			_currentScript.onCenterPrintDone();
		}
		public function setPlayer(actor:Actor):void
		{
			if (_player && _player.displayObject && _player.displayObject.parent)
			{
				_player.displayObject.parent.removeChild(_player.displayObject);
			}
			_player = actor;
			_player.worldPos = _worldBounds.middle;
			_actorLayer.addChild(_player.displayObject);

			// KAI: for non-turrets, we could disable the mouse move while the mouse is not down.  Moot
			// if we add the reticle though
//			if (_player && (_player is TankActor))
//			{
//				_input.enableMouseMove(stage);
//			}
//			else
//			{
//				_input.disableMouseMove(stage);
//			}
		}
		public function unpause():void
		{
			_frameTimer.startPerFrame();
		}
		public function pause():void
		{
			_frameTimer.stop();
		}
		private var _mobsStunned:Boolean;
		public function stunMobs():void
		{
			_mobsStunned = true;
			_player.speed.x = 0;
			_player.speed.y = 0;
		}
		public function hidePlayer():void
		{
			var dobj:DisplayObject = _player.displayObject;
			if (dobj.parent)
			{
				dobj.parent.removeChild(dobj);
			}
		}
		public function endLevel(stats:PlayedLevelStats):void
		{
			pause();
			
			if (stats.victory)
			{
				UserData.instance.credits += stats.creditsEarned;
				UserData.instance.levelsBeaten = Math.min(_lastStartedLevel + 1, Consts.LEVELS - 1);
//KAI: null object reference here
				_levelSelectionDialog.unlockLevels(UserData.instance.levelsBeaten + 1);
			}
			else
			{
				stats.creditsEarned = 0;
			}
			_cast.removeAll();
			
			var endLvl:LevelCompleteDialog = new LevelCompleteDialog(stats, _lastStartedLevel);
			Util.listen(endLvl, Event.COMPLETE, onLevelCompleteDialogDismissed);

			UIUtil.openDialog(this.parent, endLvl);
			
			_currentScript = null;
		}
		private function onLevelCompleteDialogDismissed(e:Event):void
		{
			UIUtil.closeDialog(this.parent, DisplayObject(e.target));
			toTitleScreen(true);
		}
		public function get running():Boolean
		{
			return _frameTimer.running;
		}
		public function get worldBounds():Bounds
		{
			return _worldBounds;
		}
		public function get input():Input
		{
			return _input;
		}
		// END IGameState implementation

		private function positionPlayerAndCamera():void
		{
			const stageMiddleHorz:Number = stage.stageWidth/2;
			const stageMiddleVert:Number = stage.stageHeight/2;
			
			_cameraPos.x = _player.worldPos.x - stageMiddleHorz;
			_cameraPos.y = _player.worldPos.y - stageMiddleVert;
			
			_player.displayObject.x = stageMiddleHorz;
			_player.displayObject.y = stageMiddleVert;
			if (_cameraPos.x < _worldBounds.left)
			{
				_player.displayObject.x -= (_worldBounds.left - _cameraPos.x);
				_cameraPos.x = _worldBounds.left;
			}
			else 
			{
				const cameraRightBound:Number = _worldBounds.right - stage.stageWidth; 
				if (_cameraPos.x > cameraRightBound)
				{
					_player.displayObject.x += _cameraPos.x - cameraRightBound;
					_cameraPos.x = cameraRightBound;
				}
			}
			if (_cameraPos.y < _worldBounds.top)
			{
				_player.displayObject.y -= (_worldBounds.top - _cameraPos.y);
				_cameraPos.y = _worldBounds.top; 
			}
			else
			{
				const cameraBottomBound:Number = _worldBounds.bottom - stage.stageHeight;
				if (_cameraPos.y > cameraBottomBound)
				{
					_player.displayObject.y += _cameraPos.y - cameraBottomBound;
					_cameraPos.y = cameraBottomBound;
				}
			}
		}

		private static function findBlank(map:Array2D, startX:uint, startY:uint):Location
		{
			while (startY < map.height)
			{
				if (!map.lookup(startX, startY))
				{
					return new Location(startX, startY);
				}
				if (++startX >= map.width)
				{
					startX = 0;
					++startY;
				}
			}
			return null;
		}
	}
}
import behaviors.CompositeBehavior;

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.geom.Point;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import karnold.utils.MathUtil;
import karnold.utils.RateLimiter;
import karnold.utils.Util;

final class Cast
{
	public var friendlies:Array = [];
	public var enemies:Array = [];
	public var enemyAmmo:Array = [];
	public var friendlyAmmo:Array = [];
	public var effects:Array = [];
	
	public function get length():uint
	{
		return enemies.length + enemyAmmo.length + friendlyAmmo.length + effects.length + friendlies.length;
	}
	static private function actorIsAlive(element:*, index:int, arr:Array):Boolean
	{
		var actor:Actor = element as Actor;
		if (actor && !actor.alive )
		{
			ActorPool.instance.recycle(actor);
		}
		return actor && actor.alive;
	}
	
	private var _purgeRate:RateLimiter = new RateLimiter(5000, 5000);
	public function purgeDead():void
	{
		if (length > 800 || _purgeRate.now)
		{
			//KAI: could create a utility "collapse" function for arrays
			friendlies = friendlies.filter(actorIsAlive);
			enemies = enemies.filter(actorIsAlive);
			enemyAmmo = enemyAmmo.filter(actorIsAlive);
			friendlyAmmo = friendlyAmmo.filter(actorIsAlive);
			effects = effects.filter(actorIsAlive);
		}
	}
	
	public function removeAll():void
	{
		remove(friendlies);
		remove(enemies);
		remove(enemyAmmo);
		remove(friendlyAmmo);
		remove(effects);
	}
	private function remove(cast:Array):void
	{
		for each (var actor:Actor in cast)
		{
			if (actor && actor.displayObject.parent)
			{
				actor.displayObject.parent.removeChild(actor.displayObject);
			}
		}
		cast.length = 0;

		// we may losing some pooled actors here - no matter 
	}
}

final class ShootState
{
	public static const NONE:ShootState = new ShootState;
	public static const MOUSESHOOTING:ShootState = new ShootState;
	public static const KEYBOARDSHOOTING:ShootState = new ShootState;
}