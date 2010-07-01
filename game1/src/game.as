package 
{
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

	public final class game extends Sprite implements IGame
	{
		private var _tiles:TiledBackground;
		private var _worldBounds:Bounds;

		private var _input:Input;
		private var _player:Actor;
		private var _frameTimer:FrameTimer;
		private var _frameRate:GameFrameRatePanel;
		
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

			_actorLayer = new Sprite;
			this.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			_actorLayer.scrollRect = this.scrollRect;
			parent.addChild(_actorLayer);

//			_currentScript = GameScriptFactory.testScript2;
			_currentScript = GameScriptFactory.level1;
			_currentScript.begin(this);
		}

		private static const PLAYER_CONSTS:BehaviorConsts = new BehaviorConsts(6, 1, 0.1);
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
					parent.addChild(_frameRate);
				}
			}
			
			//
			// Apply user input to the player object
			var speed:Point = _player.speed;
			if (_input.isKeyDown(Input.KEY_RIGHT))
			{
				speed.x = Math.min(PLAYER_CONSTS.MAX_SPEED, speed.x + PLAYER_CONSTS.ACCELERATION);
			}
			else if (_input.isKeyDown(Input.KEY_LEFT))
			{
				speed.x = Math.max(-PLAYER_CONSTS.MAX_SPEED, speed.x - PLAYER_CONSTS.ACCELERATION);
			}
			else if (speed.x)
			{
				speed.x = MathUtil.speedDecay(speed.x, PLAYER_CONSTS.SPEED_DECAY);
			}
			
			if (_input.isKeyDown(Input.KEY_DOWN))
			{
				speed.y = Math.min(PLAYER_CONSTS.MAX_SPEED, speed.y + PLAYER_CONSTS.ACCELERATION);
			}
			else if (_input.isKeyDown(Input.KEY_UP))
			{
				speed.y = Math.max(-PLAYER_CONSTS.MAX_SPEED, speed.y - PLAYER_CONSTS.ACCELERATION);
			}
			else if (speed.y)
			{
				speed.y = MathUtil.speedDecay(speed.y, PLAYER_CONSTS.SPEED_DECAY);
			}

			//
			// Reposition the player and the background tiles as necessary
			_player.worldPos.offset(speed.x, speed.y);
			MathUtil.constrain(_worldBounds, _player.worldPos, 0, 0, speed);
			
			if (!_lastPlayerPos.equals(_player.worldPos))
			{
				Util.setPoint(_lastPlayerPos, _player.worldPos);
				positionPlayerAndCamera();
				if (!_cameraPos.equals(_lastCameraPos))
				{
					Util.setPoint(_lastCameraPos, _cameraPos);
					_tiles.setCamera(_cameraPos);
				}
			}

			var bullet:Actor;
			if (_input.checkKeyHistoryAndClear(Input.KEY_SPACE))
			{
				bullet = Actor.createBullet();
				bullet.launchDegrees(_player.worldPos, _player.displayObject.rotation);
				addPlayerAmmo(bullet);
			}
			else if (_input.checkKeyHistoryAndClear(Input.MOUSE_BUTTON))
			{
				const dest:Point = _input.lastMouseDownCoords;

				bullet = Actor.createBullet();
				bullet.launch(_player.worldPos, dest.x - _player.displayObject.x, dest.y - _player.displayObject.y);
				addPlayerAmmo(bullet);
			}

			applyVelocityToCast(_cast.enemies);
			applyVelocityToCast(_cast.enemyAmmo);
			applyVelocityToCast(_cast.playerAmmo);
			applyVelocityToCast(_cast.effects);
			collisionCheck();

			_cast.purgeDead();

			if (_frameRate && _frameRate.parent)
			{
				_frameRate.txt1 = this.numChildren;
				_frameRate.txt2 = _actorLayer.numChildren;
				_frameRate.txt3 = _cast.length;
				_frameRate.pooled = ActorPool.instance.size;
			}
		}

		private function damageActor(actor:Actor, damage:Number):void
		{
			actor.health -= damage;
			if (actor.health < 0)
			{
				Actor.createExplosion(this, actor.worldPos, 20);
				actor.alive = false;
				
				_currentScript.onActorDeath(actor);
			}
		}

		static private const COLLISION_DIST:Number = 20;
		private function collisionCheck():void
		{
			// enemy hits player
			var enemy:Actor;
			for each (enemy in _cast.enemies)
			{
				if (enemy && enemy.alive && MathUtil.distanceBetweenPoints(_player.worldPos, enemy.worldPos) < COLLISION_DIST)
				{
					Actor.createExplosion(this, enemy.worldPos, 5);
					damageActor(enemy, BehaviorConsts.PLAYER_HEALTH);
				}
			}
			
			// enemy ammo hits player
			var ammo:Actor;
			for each (ammo in _cast.enemyAmmo)
			{
				if (ammo && ammo.alive && MathUtil.distanceBetweenPoints(_player.worldPos, ammo.worldPos) < COLLISION_DIST)
				{
					Actor.createExplosion(this, ammo.worldPos, 5);
					ammo.alive = false;
				}
			}
			
			// player ammo hits enemy
			for each (ammo in _cast.playerAmmo)
			{
				if (ammo && ammo.alive)
				{
					for each (enemy in _cast.enemies)
					{
						if (enemy && enemy.alive && MathUtil.distanceBetweenPoints(enemy.worldPos, ammo.worldPos) < COLLISION_DIST)
						{
							Actor.createExplosion(this, ammo.worldPos, 5);
							damageActor(enemy, 20);
						}
					}
				}
			}
		}
		private function applyVelocityToCast(cast:Array):void
		{
			var index:uint = 0;
			for each (var a:Actor in cast)
			{
				if (a && a.alive)
				{
					a.onFrame(this);

					if (a.alive)
					{
						a.worldPos.offset(a.speed.x, a.speed.y);
						MathUtil.constrain(_worldBounds, a.worldPos, 0, 0, a.speed);

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
		public function get player():Actor
		{
			return _player;
		}
		public function set tiles(str:String):void
		{
			const factory:ITileFactory = new BitmapTileFactory(AssetManager.instance);
			_tiles = TiledBackground.createFromString(this, factory, stage.stageWidth, stage.stageHeight, str);
			_worldBounds =  new Bounds(0, 0, factory.tileSize * _tiles.tilesArray.width, factory.tileSize*_tiles.tilesArray.height);
			
			_tiles.fromString(str);
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
		public function get numEnemies():uint
		{
			return _cast.enemies.length;
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
			
			BehaviorFactory.faceForward.onFrame(this, _player);
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
	
	private var _lastPurge:int;
	public function purgeDead():void
	{
		const now:int = getTimer();
		if (length > 800 || (now - _lastPurge) > 5000)
		{
			enemies = enemies.filter(actorIsAlive);
			enemyAmmo = enemyAmmo.filter(actorIsAlive);
			playerAmmo = playerAmmo.filter(actorIsAlive);
			effects = effects.filter(actorIsAlive);
			_lastPurge = now;
		}
	}
}
