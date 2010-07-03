package scripts
{
	public class GameScriptFactory
	{
		static public function get testScript1():IGameScript
		{
			return new TestScript(1);
		}
		static public function get testScript2():IGameScript
		{
			return new TestScript(10);
		}
		static public function get level1():IGameScript
		{
			return new Level1Script();
		}
	}
}
import behaviors.AlternatingBehavior;
import behaviors.BehaviorConsts;
import behaviors.BehaviorFactory;
import behaviors.CompositeBehavior;
import behaviors.IBehavior;

import karnold.utils.Bounds;
import karnold.utils.FrameTimer;
import karnold.utils.MathUtil;
import karnold.utils.Util;

import scripts.IGameScript;

final class Utils
{
	//KAI: maybe move these to BehaviorFactory.  Doing this here leaks the creation policy knowledge out of the factory
	static private const FLEE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward);
	static private const CHASE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward);
	static private const HOME:CompositeBehavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
	static public function attackAndFlee(msRate:uint):IBehavior
	{
		return new AlternatingBehavior
		(
			msRate,
			FLEE,
			CHASE,
			new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.createAutofire(666, BehaviorConsts.TYPE_BULLET))
		);
	}
	static public function homeAndShoot(msShootRate:uint, ammoType:uint):IBehavior
	{
		return new CompositeBehavior
		(
			HOME,
			BehaviorFactory.createAutofire(msShootRate, ammoType)
		);
	}
	static public function placeAtRandomEdge(actor:Actor, bounds:Bounds):void
	{
		actor.worldPos.x = MathUtil.random(bounds.left, bounds.right);
		actor.worldPos.y = MathUtil.random(bounds.top, bounds.bottom);
		switch(int(Math.random() * 4)) {
		case 0:
			actor.worldPos.x = bounds.left;
			break;
		case 1:
			actor.worldPos.x = bounds.right;
			break;
		case 2:
			actor.worldPos.y = bounds.top;
			break;
		case 3:
			actor.worldPos.y = bounds.bottom;
			break;
		}
	}
	static public function getBluePlayer():Actor
	{
		return new Actor(SimpleActorAsset.createBlueShip(), BehaviorConsts.BLUE_SHIP);
	}
	static public function getTankPlayer():Actor
	{
		return TankActor.createTankActor(	
			SimpleActorAsset.createTrack(),
			SimpleActorAsset.createTrack(),
			SimpleActorAsset.createHull0(),
			SimpleActorAsset.createTurret0(),
			BehaviorConsts.TEST_TANK
		);
	}
	static public const ENEMY_REDROGUE:uint = 0;
	static public const ENEMY_GREENK:uint = 1;
	static public const ENEMY_GRAYSHOOTER:uint = 2;
	static public const ENEMY_FUNNEL:uint = 3;
	static public const ENEMY_BLUE:uint = 4;
	static public const ENEMY_FIGHTER5:uint = 5;
	static public const ENEMY_FIGHTER6:uint = 6;
	static public const ENEMY_FIGHTER7:uint = 7;
	static public const ENEMY_FIGHTER8:uint = 8;
	static public const ENEMY_FIGHTER9:uint = 9;
	static public const ENEMY_FIGHTER10:uint = 10;
	static public const ENEMY_FIGHTER11:uint = 11;
	static public const ENEMY_FIGHTER12:uint = 12;
	
	static public function addEnemy(game:IGame, type:uint):Actor
	{
		var a:Actor;
		switch (type) {
		case ENEMY_REDROGUE:
			a = new Actor(SimpleActorAsset.createRedShip(), BehaviorConsts.RED_SHIP);
			a.name = "Red Rogue";
			a.behavior = attackAndFlee(5000);
			break;
		case ENEMY_GREENK:
			a = new Actor(SimpleActorAsset.createGreenShip(), BehaviorConsts.GREEN_SHIP);
			a.name = "Greenakazi";
			a.behavior = HOME;
			break;
		case ENEMY_GRAYSHOOTER:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "Gray Death";
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(2000, BehaviorConsts.TYPE_LASER),
				new AlternatingBehavior( 
					3000,
					HOME,
					BehaviorFactory.strafe
				)
			);
			break;
		case ENEMY_FUNNEL:
			a = new Actor(SimpleActorAsset.createFunnelShip(), BehaviorConsts.RED_SHIP);
			a.name = "Funnel";
			a.behavior = Utils.homeAndShoot(4000, BehaviorConsts.TYPE_LASER);
			break;
		case ENEMY_BLUE:
			a = new Actor(SimpleActorAsset.createBlueShip()(), BehaviorConsts.GRAY_SHIP);
			a.name = "Blue Bird";
			a.behavior = Utils.homeAndShoot(5000, BehaviorConsts.TYPE_BULLET);
			break;
		case ENEMY_FIGHTER5:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "5";
			a.behavior = Utils.homeAndShoot(6000, BehaviorConsts.TYPE_BULLET);
			break;
		case ENEMY_FIGHTER6:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "6";
			a.behavior = Utils.homeAndShoot(6000, BehaviorConsts.TYPE_BULLET);
			break;
		case ENEMY_FIGHTER7:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "7";
			a.behavior = Utils.homeAndShoot(6000, BehaviorConsts.TYPE_BULLET);
			break;
		case ENEMY_FIGHTER8:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "8";
			a.behavior = Utils.homeAndShoot(6000, BehaviorConsts.TYPE_BULLET);
			break;
		case ENEMY_FIGHTER9:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "9";
			a.behavior = Utils.homeAndShoot(6000, BehaviorConsts.TYPE_BULLET);
			break;
		case ENEMY_FIGHTER10:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "10";
			a.behavior = Utils.homeAndShoot(6000, BehaviorConsts.TYPE_BULLET);
			break;
		case ENEMY_FIGHTER11:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "11";
			a.behavior = Utils.homeAndShoot(6000, BehaviorConsts.TYPE_BULLET);
			break;
		case ENEMY_FIGHTER12:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "12";
			a.behavior = Utils.homeAndShoot(6000, BehaviorConsts.TYPE_BULLET);
			break;
		}
		placeAtRandomEdge(a, game.worldBounds);
		game.addEnemy(a);
		return a;
	}
}

final class TestScript implements IGameScript
{
	private var _actors:int;
	public function TestScript(actors:int)
	{
		_actors = actors;
	}

	public function begin(game:IGame):void
	{
		game.tiles = GrassTiles.testLevel;
//		game.showPlayer(Utils.getBluePlayer());
		game.showPlayer(Utils.getTankPlayer());
		game.start();
		game.centerPrint("Level 1");
		
		for (var i:int = 0; i < _actors; ++i)
		{
			addTestActors(game);
		}
	}
	
	private function addTestActors(game:IGame):void
	{
		Utils.addEnemy(game, Utils.ENEMY_REDROGUE);
		Utils.addEnemy(game, Utils.ENEMY_GREENK);
		Utils.addEnemy(game, Utils.ENEMY_GRAYSHOOTER);
		Utils.addEnemy(game, Utils.ENEMY_FIGHTER5);
	}
	
	// IGameEvents
	public function onCenterPrintDone(text:String):void	{}
	public function onActorDeath(actor:Actor):void {}
}

final class Wave
{
	public var type:uint;
	public var number:uint;
	public function Wave(type:uint, number:uint)
	{
		this.type = type;
		this.number = number;
	}
}
final class Level1Script implements IGameScript
{
	private var _game:IGame;
	private var _waveDelay:FrameTimer = new FrameTimer(addNextWave);
	public function begin(game:IGame):void
	{
		_game = game;

		game.tiles = GrassTiles.smallLevel;
//		game.showPlayer(Utils.getBluePlayer());
		game.showPlayer(Utils.getTankPlayer());
		
		game.start();
		game.centerPrint("Level 1");
	}

	private var _waves:Array = 
	[
		new Wave(Utils.ENEMY_GREENK, 10),
		new Wave(Utils.ENEMY_FIGHTER5, 10),
		new Wave(Utils.ENEMY_GREENK, 15),
		[new Wave(Utils.ENEMY_GREENK, 10), new Wave(Utils.ENEMY_REDROGUE, 2)],
		[new Wave(Utils.ENEMY_FIGHTER5, 10), new Wave(Utils.ENEMY_REDROGUE, 3)],
		new Wave(Utils.ENEMY_GREENK, 20),
		[new Wave(Utils.ENEMY_REDROGUE, 5), new Wave(Utils.ENEMY_GRAYSHOOTER, 3)],
		[new Wave(Utils.ENEMY_GREENK, 5), new Wave(Utils.ENEMY_REDROGUE, 5), new Wave(Utils.ENEMY_GRAYSHOOTER, 5)]
	];

	static private const _tmpArray:Array = [];
	private var _enemies:uint = 0;
	private function addNextWave():void
	{
		if (_waves.length)
		{
			var next:Object = _waves.shift();
			if (!(next is Array))
			{
				_tmpArray.length = 0;
				_tmpArray.push(next);
				next = _tmpArray;
			}
			for each (var wave:Wave in next)
			{
				for (var i:uint = 0; i < wave.number; ++i)
				{
					Utils.addEnemy(_game, wave.type);
					++_enemies;
				}
			}
		}
	}
	// IGameEvents
	public function onCenterPrintDone(text:String):void	
	{
		if (_waves.length)
		{
			_waveDelay.start(3000, 1);
		}
	}
	public function onActorDeath(actor:Actor):void 
	{
		if (!_game.numEnemies)
		{
			if (_waves.length)
			{
				_game.centerPrint("INCOMING");	
			}
			else
			{
				_game.centerPrint("CONGRATS LEVEL DONE");
			}
		}
	}
}

final class GrassTiles
{
	[Embed(source="assets/level1_small.txt", mimeType="application/octet-stream")]
	static private const SmallLevel:Class;
	static public function get smallLevel():String
	{
		return (new SmallLevel).toString();
	}

	[Embed(source="assets/level1.txt", mimeType="application/octet-stream")]
	static private const TestLevel:Class;
	static public function get testLevel():String
	{
		return (new TestLevel).toString();
	}
}