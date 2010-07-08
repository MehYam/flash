package 
{
	import behaviors.BehaviorFactory;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import flashx.textLayout.debug.assert;
	
	import karnold.tile.BitmapTileFactory;
	import karnold.tile.ITileFactory;
	import karnold.tile.TiledBackground;
	import karnold.utils.Array2D;
	import karnold.utils.Bounds;
	import karnold.utils.FrameTimer;
	import karnold.utils.Input;
	import karnold.utils.Location;
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	
	import scripts.GameScriptFactory;
	import scripts.IGameScript;
	import scripts.TankActor;

	public final class game extends Sprite implements IGame
	{
		private var _tiles:TiledBackground;
		private var _worldBounds:Bounds;

		private var _input:Input;
		private var _player:Actor;
		private var _frameTimer:FrameTimer;
		private var _frameRate:GameFrameRatePanel;

		private var _hudLayer:DisplayObjectContainer;
		private var _actorLayer:DisplayObjectContainer;
		private var _currentScript:IGameScript;
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

//			_currentScript = GameScriptFactory.testScript1;
//			_currentScript = GameScriptFactory.testScript2;
			_currentScript = GameScriptFactory.level1;
			_currentScript.begin(this);
		}

		private var _cast:Cast = new Cast;
		private var _lastPlayerPos:Point = new Point;
		private var _cameraPos:Point = new Point;
		private var _lastCameraPos:Point = new Point;
		private var _lastPurge:int;
		private function onFrame():void
		{
			//
			// Toggle framerate panel
			if (_input.checkKeyHistoryAndClear(Input.KEY_TILDE))
			{
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
			if (_input.isKeyDown(Input.KEY_RIGHT))
			{
				speed.x = Math.min(_player.consts.MAX_SPEED, speed.x + _player.consts.ACCELERATION);
			}
			else if (_input.isKeyDown(Input.KEY_LEFT))
			{
				speed.x = Math.max(-_player.consts.MAX_SPEED, speed.x - _player.consts.ACCELERATION);
			}
			else if (speed.x)
			{
				speed.x = MathUtil.speedDecay(speed.x, _player.consts.SPEED_DECAY);
			}
			
			if (_input.isKeyDown(Input.KEY_DOWN))
			{
				speed.y = Math.min(_player.consts.MAX_SPEED, speed.y + _player.consts.ACCELERATION);
			}
			else if (_input.isKeyDown(Input.KEY_UP))
			{
				speed.y = Math.max(-_player.consts.MAX_SPEED, speed.y - _player.consts.ACCELERATION);
			}
			else if (speed.y)
			{
				speed.y = MathUtil.speedDecay(speed.y, _player.consts.SPEED_DECAY);
			}

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
				_radar.plot(_player, 0x0000ff);
			}

			if (_input.isKeyDown(Input.KEY_SPACE))
			{
				_currentScript.onPlayerShootForward(this);
			}
			else if (_input.isKeyDown(Input.MOUSE_BUTTON))
			{
				_currentScript.onPlayerShootTo(this, _input.lastMousePos);
			}

			runFrameOnCast(_cast.enemies);
			runFrameOnCast(_cast.enemyAmmo);
			runFrameOnCast(_cast.playerAmmo);
			runFrameOnCast(_cast.effects);
			collisionCheck();

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
			// enemy hits player
			var enemy:Actor;
			for each (enemy in _cast.enemies)
			{
				if (enemy && enemy.alive && 
					MathUtil.distanceBetweenPoints(_player.worldPos, enemy.worldPos) < (_player.consts.RADIUS + enemy.consts.RADIUS))
				{
					_currentScript.onPlayerStruckByEnemy(this, enemy);
				}
			}
			
			// enemy ammo hits player
			var ammo:Actor;
			for each (ammo in _cast.enemyAmmo)
			{
				if (ammo && ammo.alive && 
					MathUtil.distanceBetweenPoints(_player.worldPos, ammo.worldPos) < (_player.consts.RADIUS + ammo.consts.RADIUS))
				{
					_currentScript.onPlayerStruckByAmmo(this, ammo);
				}
			}
			
			// player ammo hits enemy
			for each (ammo in _cast.playerAmmo)
			{
				if (ammo && ammo.alive)
				{
					for each (enemy in _cast.enemies)
					{
						if (enemy && enemy.alive && MathUtil.distanceBetweenPoints(enemy.worldPos, ammo.worldPos) < (ammo.consts.RADIUS + enemy.consts.RADIUS))
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
						a.displayObject.x = a.worldPos.x - _cameraPos.x;
						a.displayObject.y = a.worldPos.y - _cameraPos.y;
						
						// assume that if the displayobject is a bitmap, it's aligned to top left.  Else,
						// it's centered
						var recenter:Boolean = a.displayObject is Bitmap;
						if (recenter)
						{
							a.displayObject.x -= a.displayObject.width/2;
							a.displayObject.y -= a.displayObject.height/2;
						}
						
						if (MathUtil.objectIntersects(a.displayObject, 0, 0, stage.stageWidth, stage.stageHeight))
						{
							if (!a.displayObject.parent)
							{
								_actorLayer.addChild(a.displayObject);
							}
						}
						else
						{
							if (a.displayObject.parent)
							{
								a.displayObject.parent.removeChild(a.displayObject);
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
		public function addEnemy(actor:Actor):void
		{
			// up to the caller to ensure enemies aren't added twice
			_cast.enemies.push(actor);
		}
		public function addEnemyAmmo(actor:Actor):void
		{
			_cast.enemyAmmo.push(actor);
		}
		public function addPlayerAmmo(actor:Actor):void
		{
			_cast.playerAmmo.push(actor);
		}
		public function addEffect(actor:Actor):void
		{
			_cast.effects.push(actor);
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
		public function get scoreBoard():ScoreBoard
		{
			return _sb;
		}
		private var _radar:Radar;
		private var _sb:ScoreBoard;
		public function set tiles(str:String):void
		{
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
			
			_sb = new ScoreBoard;
			_sb.x = 5;
			_hudLayer.addChild(_sb);
		}
		public function centerPrint(text:String):void
		{
			trace("would centerprint", text);
			_currentScript.onCenterPrintDone(text);
		}
		public function showPlayer(actor:Actor):void
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
		public function start():void
		{
			_frameTimer.startPerFrame();
		}
		public function stop():void
		{
			_frameTimer.stop();
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
	public var enemies:Array = [];
	public var enemyAmmo:Array = [];
	public var playerAmmo:Array = [];
	public var effects:Array = [];
	
	public function get length():uint
	{
		return enemies.length + enemyAmmo.length + playerAmmo.length + effects.length;
	}
	static private function actorIsAlive(element:*, index:int, arr:Array):Boolean
	{
		var actor:Actor = element as Actor
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
			enemies = enemies.filter(actorIsAlive);
			enemyAmmo = enemyAmmo.filter(actorIsAlive);
			playerAmmo = playerAmmo.filter(actorIsAlive);
			effects = effects.filter(actorIsAlive);
		}
	}
}
