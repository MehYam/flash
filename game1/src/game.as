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
	import karnold.utils.Physics;
	import karnold.utils.Utils;

	public final class game extends Sprite implements IGameState
	{
		private var _bg:TiledBackground;
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

			_bg = new TiledBackground(this, factory, 40, 40, stage.stageWidth, stage.stageHeight);
			this.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			_actorLayer.scrollRect = this.scrollRect;

			_worldBounds =  new Bounds(0, 0, factory.tileSize * _bg.tilesArray.width, factory.tileSize*_bg.tilesArray.height);

			_player = new Actor(DebugVectorObject.createBlueShip());//createSpaceship();
			_player.worldPos = _worldBounds.middle;
			
var testenemy:Actor = new Actor(DebugVectorObject.createRedShip());
testenemy.worldPos = _worldBounds.middle;
testenemy.worldPos.offset(20, 20);
testenemy.behavior = 
	new CompositeBehavior(
		new AlternatingBehavior(BehaviorFactory.avoid, BehaviorFactory.follow, BehaviorFactory.strafe), 
		BehaviorFactory.faceMyDirection
	);
testenemy.behavior = BehaviorFactory.follow; 
testenemy.behavior = new CompositeBehavior(BehaviorFactory.strafe, new AutofireBehavior); 
testenemy.behavior = new AlternatingBehavior
	(
		new CompositeBehavior(BehaviorFactory.avoid, BehaviorFactory.faceMyDirection),
		new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.faceMyDirection),
		new CompositeBehavior(BehaviorFactory.strafe, new AutofireBehavior)
	);
addActor(testenemy);

			_actorLayer.addChild(_player.displayObject);

			if (VECTOR)
			{
				initVectorMap(_bg, 0.2);
			}
			else
			{
				initRasterMap(_bg);
			}
			trace("stage", stage.stageWidth, stage.stageHeight);
			
			graphics.lineStyle(0, 0xff0000);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			mouseChildren = false;
			mouseEnabled = false;
		}

		private static const ACCELERATION:Number = 1;
		private static const MAX_SPEED:Number = 6;
		private static const SPEED_DECAY:Number = 0.1;  // percentage
		private var _cast:Array = [];
		private var _lastPlayerPos:Point = new Point;
		private var _cameraPos:Point = new Point;
		private var _lastCameraPos:Point = new Point;
		private var _lastPurge:int;
		private function onEnterFrame():void
		{
			//
			// Check input
			var speed:Point = _player.speed;
			if (_input.isKeyDown(Input.KEY_RIGHT))
			{
				speed.x = Math.min(MAX_SPEED, speed.x + ACCELERATION);
			}
			else if (_input.isKeyDown(Input.KEY_LEFT))
			{
				speed.x = Math.max(-MAX_SPEED, speed.x - ACCELERATION);
			}
			else if (speed.x)
			{
				speed.x = Physics.speedDecay(speed.x, SPEED_DECAY);
			}
			
			if (_input.isKeyDown(Input.KEY_DOWN))
			{
				speed.y = Math.min(MAX_SPEED, speed.y + ACCELERATION);
			}
			else if (_input.isKeyDown(Input.KEY_UP))
			{
				speed.y = Math.max(-MAX_SPEED, speed.y - ACCELERATION);
			}
			else if (speed.y)
			{
				speed.y = Physics.speedDecay(speed.y, SPEED_DECAY);
			}

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
			// Render the background
			_player.worldPos.offset(speed.x, speed.y);

			Physics.constrain(_worldBounds, _player.worldPos, _player.displayObject.width, _player.displayObject.height, speed);
			
			if (!_lastPlayerPos.equals(_player.worldPos))
			{
				Utils.setPoint(_lastPlayerPos, _player.worldPos);
				positionPlayerAndCamera();
				if (!_cameraPos.equals(_lastCameraPos))
				{
					Utils.setPoint(_lastCameraPos, _cameraPos);
					_bg.setCamera(_cameraPos);
				}
			}

			//TEST CODE
			if (_input.checkKeyHistoryAndClear(Input.KEY_SPACE))
			{
				AutofireBehavior.createBullet(this, _player.speed.x, _player.speed.y, _player.worldPos.clone());
			}
			else if (_input.checkKeyHistoryAndClear(Input.MOUSE_BUTTON))
			{
				const dest:Point = _input.lastMouseDownCoords;
				AutofireBehavior.createBullet(this, dest.x - _player.displayObject.x, dest.y - _player.displayObject.y, _player.worldPos.clone());
			}
			
			for each (var a:Actor in _cast)
			{
				a.onFrame(this);
				if (a.alive)
				{
					a.worldPos.offset(a.speed.x, a.speed.y);
					Physics.constrain(_worldBounds, a.worldPos, a.displayObject.width, a.displayObject.height, a.speed);
	
					a.displayObject.x = a.worldPos.x - _cameraPos.x;
					a.displayObject.y = a.worldPos.y - _cameraPos.y;
				}
				else
				{
					if (a.displayObject.parent)
					{
						a.displayObject.parent.removeChild(a.displayObject);
					}
				}
			}
			const now:int = getTimer();
			if ((now - _lastPurge) > 5000)
			{
trace("pre filter", _cast.length);
				_cast = _cast.filter(removeDead);
trace("post filter", _cast.length);
				_lastPurge = now;
			}
			//TEST CODE END
			
			_frameRate.txt1 = this.numChildren;
			_frameRate.txt2 = _actorLayer.numChildren;
		}

		// IGameState implementation
		public function addActor(actor:Actor):void
		{
			_cast.push(actor);
			_actorLayer.addChild(actor.displayObject);
		}
		public function get player():Actor
		{
			return _player;
		}
		// END IGameState implementation

		static private function removeDead(element:*, index:int, arr:Array):Boolean
		{
			return Actor(element).alive;
		}
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
			
			BehaviorFactory.faceMyDirection.onFrame(this, _player);
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
import flash.geom.Point;
import flash.utils.getTimer;

import karnold.utils.Physics;
import karnold.utils.Utils;

class DumbConsts
{
	static public const MAX_SPEED:Number = 3;
	static public const ACCELERATION:Number = 0.1;
	static public const BULLET_SPEED:Number = 10;
};

class BehaviorFactory
{
	static private var _fmd:IBehavior;
	static public function get faceMyDirection():IBehavior
	{
		if (!_fmd)
		{
			_fmd = new FaceMyDirectionBehavior;
		}
		return _fmd;
	}
	static private var _avoid:IBehavior;
	static public function get avoid():IBehavior
	{
		if (!_avoid)
		{
			_avoid = new AvoidBehavior;
		}
		return _avoid;
	}
	static private var _follow:IBehavior;
	static public function get follow():IBehavior
	{
		if (!_follow)
		{
			_follow = new FollowBehavior;
		}
		return _follow;
	}
	static private var _strafe:IBehavior;
	static public function get strafe():IBehavior
	{
		if (!_strafe)
		{
			_strafe = new StrafeBehavior;
		}
		return _strafe;
	}
}
class FaceMyDirectionBehavior implements IBehavior
{
	public function onFrame(game:IGameState, actor:Actor):void
	{
		actor.displayObject.rotation = Physics.getDegreesRotation(actor.speed.x, actor.speed.y);
	}
}

class AvoidBehavior implements IBehavior
{
	static private var _instance:IBehavior;
	static public function get instance():IBehavior
	{
		if (!_instance)
		{
			_instance = new AvoidBehavior;
		}
		return _instance;
	}
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = Physics.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * DumbConsts.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * DumbConsts.ACCELERATION;
		
		actor.speed.x += accelX;
		actor.speed.y += accelY;
		
		actor.speed.x = Physics.constrainAbsoluteValue(actor.speed.x, DumbConsts.MAX_SPEED);
		actor.speed.y = Physics.constrainAbsoluteValue(actor.speed.y, DumbConsts.MAX_SPEED);
	}
};

class FollowBehavior implements IBehavior
{
	static private var _instance:IBehavior;
	static public function get instance():IBehavior
	{
		if (!_instance)
		{
			_instance = new FollowBehavior;
		}
		return _instance;
	}
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = Physics.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * DumbConsts.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * DumbConsts.ACCELERATION;
		
		actor.speed.x -= accelX;
		actor.speed.y -= accelY;
		
		actor.speed.x = Physics.constrainAbsoluteValue(actor.speed.x, DumbConsts.MAX_SPEED);
		actor.speed.y = Physics.constrainAbsoluteValue(actor.speed.y, DumbConsts.MAX_SPEED);
	}
};

class StrafeBehavior implements IBehavior
{
	static private var _instance:IBehavior;
	static public function get instance():IBehavior
	{
		if (!_instance)
		{
			_instance = new StrafeBehavior;
		}
		return _instance;
	}
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = Physics.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * DumbConsts.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * DumbConsts.ACCELERATION;
		
		actor.speed.x -= accelX;
		actor.speed.y -= accelY;
		
		actor.speed.x = Physics.constrainAbsoluteValue(actor.speed.x, DumbConsts.MAX_SPEED);
		actor.speed.y = Physics.constrainAbsoluteValue(actor.speed.y, DumbConsts.MAX_SPEED);
		
		actor.displayObject.rotation = Physics.getDegreesRotation(-accelX, -accelY);
	}
};
//KAI: keep everything frame-based or time-based but not both
class AutofireBehavior implements IBehavior
{
	private var _lastShot:int;

	static public function createBullet(game:IGameState, deltaX:Number, deltaY:Number, pos:Point):void
	{
		var bullet:Actor = new Actor(DebugVectorObject.createCircle(0xffaaaa, 5, 5));
		bullet.behavior = new ExpireBehavior(2000);

		const radians:Number = Physics.getRadiansRotation(deltaX, deltaY);
		
		bullet.worldPos = pos;
		bullet.speed.x = Math.sin(radians) * DumbConsts.BULLET_SPEED;
		bullet.speed.y = -Math.cos(radians) * DumbConsts.BULLET_SPEED;
		
		game.addActor(bullet);
	}
	public function onFrame(game:IGameState, actor:Actor):void
	{
		const now:int = getTimer();
		if ((now - _lastShot) > 300)
		{
			_lastShot = now;

			const deltaX:Number = game.player.worldPos.x - actor.worldPos.x;
			const deltaY:Number = game.player.worldPos.y - actor.worldPos.y;
			
			createBullet(game, deltaX, deltaY, actor.worldPos.clone());
		}
	}
}


class SpeedDecayBehavior implements IBehavior
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
		actor.speed.x = Physics.speedDecay(actor.speed.x, 0.01);
		actor.speed.y = Physics.speedDecay(actor.speed.y, 0.01);
	}
}
class CompositeBehavior implements IBehavior
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
};
class AlternatingBehavior implements IBehavior
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
class ExpireBehavior implements IBehavior
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