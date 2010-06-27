package 
{
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
	import karnold.utils.FrameRate;
	import karnold.utils.FrameTimer;
	import karnold.utils.Input;
	import karnold.utils.Location;
	import karnold.utils.MathUtil;
	import karnold.utils.Util;

	public final class game extends Sprite implements IGameState
	{
		private var _tiles:TiledBackground;
		private var _worldBounds:Bounds;

		private var _input:Input;
		private var _player:Actor;
		private var _frameTimer:FrameTimer = new FrameTimer(onEnterFrame);
		private var _frameRate:FrameRate = new FrameRate;
		
		private var _actorLayer:DisplayObjectContainer = new Sprite;
		
		static private const VECTOR:Boolean = false;
		public function game()
		{
//			_actorLayer = parent;
			parent.addChild(_actorLayer);

//			stage.align = StageAlign.TOP_LEFT;
//			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = Consts.FRAMERATE;
			stage.focus = stage;
			FrameTimer.init(stage);
			_frameTimer.startPerFrame();

			_input = new Input(stage);

			var factory:ITileFactory = VECTOR ? new DebugVectorTileFactory : new BitmapTileFactory(AssetManager.instance);

			_tiles = new TiledBackground(this, factory, 40, 40, stage.stageWidth, stage.stageHeight);
			this.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			_actorLayer.scrollRect = this.scrollRect;

			_worldBounds =  new Bounds(0, 0, factory.tileSize * _tiles.tilesArray.width, factory.tileSize*_tiles.tilesArray.height);

			_player = new Actor(SimpleActorAsset.createBlueShip());//createSpaceship();
			_player.worldPos = _worldBounds.middle;
			_actorLayer.addChild(_player.displayObject);
			
addTestActors();
			if (VECTOR)
			{
				initVectorMap(_tiles, 0.2);
			}
			else
			{
				initRasterMap(_tiles);
			}
			trace("stage", stage.stageWidth, stage.stageHeight);
			
			graphics.lineStyle(0, 0xff0000);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			mouseChildren = false;
			mouseEnabled = false;
		}

		private function addTestActors():void
		{
			var testenemy:Actor = new Actor(SimpleActorAsset.createRedShip(), BehaviorConsts.RED_SHIP);
			testenemy.worldPos = _worldBounds.middle;
			testenemy.worldPos.offset(20, 20);
			testenemy.behavior = new AlternatingBehavior
				(
					new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward),
					new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward),
					new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.autofire)
				);
			addEnemy(testenemy);
			
			testenemy = new Actor(SimpleActorAsset.createGreenShip(), BehaviorConsts.GREEN_SHIP);
			testenemy.behavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
			addEnemy(testenemy);
		}

		private static const PLAYER_CONSTS:BehaviorConsts = new BehaviorConsts(6, 1, 0.1);
		private var _cast:Cast = new Cast;
		private var _lastPlayerPos:Point = new Point;
		private var _cameraPos:Point = new Point;
		private var _lastCameraPos:Point = new Point;
		private var _lastPurge:int;
		private function onEnterFrame():void
		{
			//
			// Toggle framerate panel
			if (_input.checkKeyHistoryAndClear(Input.KEY_TILDE))
			{
				if (_frameRate.parent)
				{
					_frameRate.enabled = false;
					_frameRate.parent.removeChild(_frameRate);
				}
				else
				{
					_frameRate.enabled = true;
					_actorLayer.addChild(_frameRate);
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
			MathUtil.constrain(_worldBounds, _player.worldPos, _player.displayObject.width, _player.displayObject.height, speed);
			
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

			if (_input.checkKeyHistoryAndClear(Input.KEY_SPACE))
			{
				addPlayerAmmo(BulletActor.createWithAngle(_player.displayObject.rotation, _player.worldPos));
			}
			else if (_input.checkKeyHistoryAndClear(Input.MOUSE_BUTTON))
			{
				const dest:Point = _input.lastMouseDownCoords;
				addPlayerAmmo(BulletActor.create(dest.x - _player.displayObject.x, dest.y - _player.displayObject.y, _player.worldPos));
			}

			applyVelocityToCast(_cast.enemies);
			applyVelocityToCast(_cast.enemyAmmo);
			applyVelocityToCast(_cast.playerAmmo);
			applyVelocityToCast(_cast.effects);
			collisionCheck();

			_cast.purgeDead();

			if (_frameRate.parent)
			{
				_frameRate.txt1 = this.numChildren;
				_frameRate.txt2 = _actorLayer.numChildren;
				_frameRate.txt3 = _cast.length;
			}
		}

		static private const COLLISION_DIST:Number = 20;
		private function collisionCheck():void
		{
			// enemy hits player
			var enemy:Actor;
//			for each (enemy in _cast.enemies)
//			{
//				if (enemy.alive && Physics.distanceBetweenPoints(_player.worldPos, enemy.worldPos) < COLLISION_DIST)
//				{
//					enemy.alive = false;
//				}
//			}
			
			// enemy ammo hits player
			var ammo:Actor;
			for each (ammo in _cast.enemyAmmo)
			{
				if (ammo.alive && MathUtil.distanceBetweenPoints(_player.worldPos, ammo.worldPos) < COLLISION_DIST)
				{
					ExplosionParticleActor.explosion(this, ammo.worldPos, 10);
					ammo.alive = false;
				}
			}
			
			// player ammo hits enemy
			for each (ammo in _cast.playerAmmo)
			{
				if (ammo.alive)
				{
					for each (enemy in _cast.enemies)
					{
						if (enemy.alive && MathUtil.distanceBetweenPoints(enemy.worldPos, ammo.worldPos) < COLLISION_DIST)
						{
							ExplosionParticleActor.explosion(this, ammo.worldPos, 5);
							ammo.alive = false;
						}
					}
				}
			}
		}
		private function applyVelocityToCast(cast:Array):void
		{
			for each (var a:Actor in cast)
			{
				if (a.alive)
				{
					a.onFrame(this);

					a.worldPos.offset(a.speed.x, a.speed.y);
					MathUtil.constrain(_worldBounds, a.worldPos, a.displayObject.width, a.displayObject.height, a.speed);
					
					a.displayObject.x = a.worldPos.x - _cameraPos.x;
					a.displayObject.y = a.worldPos.y - _cameraPos.y;
				}
			}
		}

		// IGameState implementation
		public function addEnemy(actor:Actor):void
		{
			_cast.enemies.push(actor);
			_actorLayer.addChild(actor.displayObject);
		}
		public function addEnemyAmmo(actor:Actor):void
		{
			_cast.enemyAmmo.push(actor);
			_actorLayer.addChild(actor.displayObject);
		}
		public function addPlayerAmmo(actor:Actor):void
		{
			_cast.playerAmmo.push(actor);
			_actorLayer.addChild(actor.displayObject);
		}
		public function addEffect(actor:Actor):void
		{
			_cast.effects.push(actor);
			_actorLayer.addChild(actor.displayObject);
		}
		public function get player():Actor
		{
			return _player;
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

/*
NEXT TASK:
	- put the scrolling 2D tiled background in a class
		- new tiled class will use/contain the map
		- it should act like an item renderer, NOT a diplayobject and able to render on your own surface
	- share it with the level editor
	- define level editor data (some custom xml format)
		<level>
			<tileset>ground</tileset>
			<tiles>0-0-0,0-1-2,0-2-0....</tiles>
		    <objects>234-212-0,....</objects>
		    <timeline>...</timeline>
		    ideally you'd have a script you could run... hmmm
				- script itself could be compiled actionscript
		</level>
		
*/
		
		private static function initRasterMap(bg:TiledBackground):void
		{
			bg.fromString(SampleData.level1);
		}
		private static function initVectorMap(bg:TiledBackground, densityPct:Number):void
		{
			const XSLOTS:uint = bg.tilesArray.width;
			const YSLOTS:uint = bg.tilesArray.height;
			const count:uint = densityPct * (XSLOTS * YSLOTS);
			for (var i:uint = 0; i < count; ++i)
			{
				var loc:Location = findBlank(bg.tilesArray, Math.random() * XSLOTS, Math.random() * YSLOTS);
				if (loc)
				{
					// [kja] we're using DisplayObjects in our actual map - the map instead should just be data,
					// and we instead simply pool DisplayObjects, reusing them as necessary.
					bg.putTile(DebugVectorTileFactory.TILE_SPIRO, loc.x, loc.y);
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
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.geom.Point;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import karnold.utils.ObjectPool;
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
		var actor:Actor = Actor(element);
		if (!actor.alive )
		{
			if (actor is BulletActor)
			{
				BulletActor.recycle(BulletActor(element));
			}
			else if (actor is ExplosionParticleActor)
			{
				ExplosionParticleActor.recycle(ExplosionParticleActor(element));
			}
		}
		return actor.alive;
	}
	
	private var _lastPurge:int;
	public function purgeDead():void
	{
		const now:int = getTimer();
		if ((now - _lastPurge) > 5000)
		{
			enemies = enemies.filter(actorIsAlive);
			enemyAmmo = enemyAmmo.filter(actorIsAlive);
			playerAmmo = playerAmmo.filter(actorIsAlive);
			effects = effects.filter(actorIsAlive);
			_lastPurge = now;
		}
	}
}

final class BehaviorFactory
{
	static private var _faceForward:IBehavior;
	static private var _facePlayer:IBehavior;
	static private var _gravityPush:IBehavior;
	static private var _gravityPull:IBehavior;
	static private var _strafe:IBehavior;
	static private var _follow:IBehavior;
	static private var _fade:IBehavior;
	static public function get faceForward():IBehavior
	{
		if (!_faceForward)
		{
			_faceForward = new FaceForwardBehavior;
		}
		return _faceForward;
	}
	static public function get facePlayer():IBehavior
	{
		if (!_facePlayer)
		{
			_facePlayer = new FacePlayerBehavior;
		}
		return _facePlayer;
	}
	static public function get gravityPush():IBehavior
	{
		if (!_gravityPush)
		{
			_gravityPush = new GravityPush;
		}
		return _gravityPush;
	}
	static public function get gravityPull():IBehavior
	{
		if (!_gravityPull)
		{
			_gravityPull = new GravityPullBehavior;
		}
		return _gravityPull;
	}
	static public function get strafe():IBehavior
	{
		if (!_strafe)
		{
			_strafe = new StrafeBehavior;
		}
		return _strafe;
	}
	static public function get follow():IBehavior
	{
		if (!_follow)
		{
			_follow = new FollowBehavior;
		}
		return _follow;
	}
	static public function get autofire():IBehavior
	{
		return new AutofireBehavior;
	}
	static public function get fade():IBehavior
	{
		if (!_fade)
		{
			_fade = new FadeBehavior;
		}
		return _fade;
	}
}
final class FaceForwardBehavior implements IBehavior
{
	public function onFrame(game:IGameState, actor:Actor):void
	{
		actor.displayObject.rotation = MathUtil.getDegreesRotation(actor.speed.x, actor.speed.y);
	}
}

final class FacePlayerBehavior implements IBehavior
{
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const deltaX:Number = game.player.worldPos.x - actor.worldPos.x;
		const deltaY:Number = game.player.worldPos.y - actor.worldPos.y;
		actor.displayObject.rotation = MathUtil.getDegreesRotation(deltaX, deltaY);
	}
}

final class GravityPush implements IBehavior
{
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = MathUtil.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * actor.consts.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * actor.consts.ACCELERATION;
		
		actor.speed.x += accelX;
		actor.speed.y += accelY;
		
		actor.speed.x = MathUtil.constrainAbsoluteValue(actor.speed.x, actor.consts.MAX_SPEED);
		actor.speed.y = MathUtil.constrainAbsoluteValue(actor.speed.y, actor.consts.MAX_SPEED);
	}
};

final class GravityPullBehavior implements IBehavior
{
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = MathUtil.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * actor.consts.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * actor.consts.ACCELERATION;
		
		actor.speed.x -= accelX;
		actor.speed.y -= accelY;
		
		actor.speed.x = MathUtil.constrainAbsoluteValue(actor.speed.x, actor.consts.MAX_SPEED);
		actor.speed.y = MathUtil.constrainAbsoluteValue(actor.speed.y, actor.consts.MAX_SPEED);
	}
};

final class FollowBehavior implements IBehavior
{
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = MathUtil.getRadiansRotation(deltaX, deltaY);

		actor.speed.x = actor.consts.MAX_SPEED * -Math.sin(radians);
		actor.speed.y = actor.consts.MAX_SPEED * Math.cos(radians);
	}
}

final class StrafeBehavior implements IBehavior
{
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = MathUtil.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * actor.consts.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * actor.consts.ACCELERATION;
		
		actor.speed.x -= accelX;
		actor.speed.y -= accelY;
		
		actor.speed.x = MathUtil.constrainAbsoluteValue(actor.speed.x, actor.consts.MAX_SPEED);
		actor.speed.y = MathUtil.constrainAbsoluteValue(actor.speed.y, actor.consts.MAX_SPEED);
		
		actor.displayObject.rotation = MathUtil.getDegreesRotation(-accelX, -accelY);
	}
}

final class FadeBehavior implements IBehavior
{
	public function onFrame(game:IGameState, actor:Actor):void
	{
		actor.displayObject.alpha -= 0.01;
	}
}

final class ExplosionParticleActor extends Actor // this type exists only so that we know we can pool it
{
	public function ExplosionParticleActor(dobj:DisplayObject):void
	{
		super(dobj, BehaviorConsts.EXPLOSION);
	}
	static private var s_pool:ObjectPool = new ObjectPool;
	static private const SIZE:Number = 2;
	static private const HALFSIZE:Number = SIZE/2;
	static public function explosion(game:IGameState, worldPos:Point, numParticles:uint):void
	{
		for (var i:uint = 0; i < numParticles; ++i)
		{
			var actor:Actor = s_pool.get() as ExplosionParticleActor;
			if (actor)
			{
				actor.reset();
			}
			else 
			{
				var particle:Shape = new Shape;
				particle.graphics.lineStyle(0, 0xffff00);
				particle.graphics.beginFill(0xffff00);
				particle.graphics.drawRect(-HALFSIZE, -HALFSIZE, SIZE, SIZE);
				particle.graphics.endFill();
	
				actor = new ExplosionParticleActor(particle);
			}
			actor.displayObject.alpha = Math.random();

			Util.setPoint(actor.worldPos, worldPos);
			actor.speed.x = Util.random(-10, 10);
			actor.speed.y = Util.random(-10, 10);
			actor.behavior = new CompositeBehavior(new ExpireBehavior(BehaviorConsts.EXPLOSION_LIFETIME), BehaviorFactory.fade);
			
			game.addEffect(actor);
		}
	}
	static public function recycle(actor:ExplosionParticleActor):void
	{
		Util.assert(!actor.alive && !actor.displayObject.parent);
		s_pool.put(actor);
	}
}

final class BulletActor extends Actor // this type exists only so that we know we can pool it
{
	public function BulletActor(dobj:DisplayObject)
	{
		super(dobj, BehaviorConsts.BULLET);
	}
	static public function createWithAngle(degrees:Number, pos:Point):Actor
	{
		return createBulletHelper(MathUtil.degreesToRadians(degrees), pos);
	}
	static public function create(deltaX:Number, deltaY:Number, pos:Point):Actor
	{
		return createBulletHelper(MathUtil.getRadiansRotation(deltaX, deltaY), pos);
	}
	static public function recycle(actor:BulletActor):void
	{
		Util.assert(!actor.alive && !actor.displayObject.parent);
		s_pool.put(actor);
	}
	static private var s_pool:ObjectPool = new ObjectPool;
	static private function createBulletHelper(radians:Number, pos:Point):Actor
	{
		var bullet:Actor = s_pool.get() as BulletActor;
		if (bullet)
		{
			bullet.reset(); // should objectpool do this?
		}
		else
		{
			//KAI: I really really don't like this.  There was something nice about making Actor final,
			// see if there's an alternative to using type this way.  Think about object pooling some more,
			// there are a variety of choices to be made about who does the pooling, who implements the
			// interfaces, etc.  Instead of giving the class a type, it could be given a reference to
			// a memory manager, so that it recycles itself.  Then, when you want the instance of some
			// object "type", you go to the right provider to get it.  IObjectPoolable, etc.
			bullet = new BulletActor(SimpleActorAsset.createCircle(0xff0000, 5, 5));
			bullet.behavior = new CompositeBehavior(BehaviorFactory.fade, new ExpireBehavior(BehaviorConsts.BULLET_LIFETIME));
		}
		Util.setPoint(bullet.worldPos, pos);
		bullet.speed.x = Math.sin(radians) * BehaviorConsts.BULLET.MAX_SPEED;
		bullet.speed.y = -Math.cos(radians) * BehaviorConsts.BULLET.MAX_SPEED;
		bullet.displayObject.alpha = 1;
		return bullet;
	}
}

//KAI: keep everything frame-based or time-based but not both
final class AutofireBehavior implements IBehavior
{
	private var _lastShot:int;

	public function onFrame(game:IGameState, actor:Actor):void
	{
		const now:int = getTimer();
		if ((now - _lastShot) > 300)
		{
			_lastShot = now;

			const deltaX:Number = game.player.worldPos.x - actor.worldPos.x;
			const deltaY:Number = game.player.worldPos.y - actor.worldPos.y;
			
			game.addEnemyAmmo(BulletActor.create(deltaX, deltaY, actor.worldPos));
		}
	}
}

final class SpeedDecayBehavior implements IBehavior
{
	static private var _instance:SpeedDecayBehavior;
	static public function get instance():SpeedDecayBehavior
	{
		if (!_instance)
		{
			_instance = new SpeedDecayBehavior;
		}
		return _instance;
	}
	public function onFrame(game:IGameState, actor:Actor):void
	{
		actor.speed.x = MathUtil.speedDecay(actor.speed.x, actor.consts.SPEED_DECAY);
		actor.speed.y = MathUtil.speedDecay(actor.speed.y, actor.consts.SPEED_DECAY);
	}
}
final class CompositeBehavior implements IBehavior, IResettable
{
	private var _behaviors:Array = [];
	public function CompositeBehavior(...args)
	{
		for each (var behavior:IBehavior in args)
		{
			_behaviors.push(behavior);
		}
	}
	public function push(b:IBehavior):void
	{
		_behaviors.push(b);
	}
	public function onFrame(game:IGameState, actor:Actor):void
	{
		for each (var behavior:IBehavior in _behaviors)
		{
			behavior.onFrame(game, actor);
		}
	}
	public function onFrameAt(game:IGameState, actor:Actor, index:uint):void
	{
		IBehavior(_behaviors[index]).onFrame(game, actor);
	}
	public function get numBehaviors():uint
	{
		return _behaviors.length;
	}
	public function reset():void
	{
		for each (var behavior:IBehavior in _behaviors)
		{
			var resettable:IResettable = behavior as IResettable;
			if (resettable)
			{
				resettable.reset();
			}
		}
	}
};
final class AlternatingBehavior implements IBehavior
{
	private var _behaviors:CompositeBehavior = new CompositeBehavior;
	private var _lastChange:int;
	public function AlternatingBehavior(...args)
	{
		for each (var behavior:IBehavior in args)
		{
			_behaviors.push(behavior);
		}
	}
	private var _count:uint;
	public function onFrame(game:IGameState, actor:Actor):void
	{
		_behaviors.onFrameAt(game, actor, _count % _behaviors.numBehaviors);

		const now:int = getTimer();
		if ((now - _lastChange) > 5000)
		{
			++_count;
			_lastChange = now;
		}
	}
}
final class ExpireBehavior implements IBehavior, IResettable
{
	private var start:int = getTimer();
	private var lifetime:int;
	public function ExpireBehavior(msLifeTime:int):void
	{
		lifetime = msLifeTime;
	}
	public function onFrame(game:IGameState, actor:Actor):void
	{
		if ((getTimer() - start) > lifetime)
		{
			actor.alive = false;
		}
	}
	public function reset():void
	{
		start = getTimer();
	}
}
final class SampleData
{
	[Embed(source="assets/level1.txt", mimeType="application/octet-stream")]
	static private const Level1Data:Class;

	static public function get level1():String
	{
		return (new Level1Data).toString();
	}
}