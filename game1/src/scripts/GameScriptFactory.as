package scripts
{
	public class GameScriptFactory
	{
		static public function get testScript1():IGameScript
		{
			return new TestScript(0);
		}
		static public function get testScript2():IGameScript
		{
			return new TestScript(10);
		}
		static public function get level1():IGameScript
		{
			return new WaveBasedGameScript();
		}
	}
}
import behaviors.AlternatingBehavior;
import behaviors.AmmoFireSource;
import behaviors.AmmoType;
import behaviors.BehaviorConsts;
import behaviors.BehaviorFactory;
import behaviors.CompositeBehavior;
import behaviors.IBehavior;

import flash.display.DisplayObject;
import flash.geom.Point;

import karnold.utils.Bounds;
import karnold.utils.FrameTimer;
import karnold.utils.MathUtil;
import karnold.utils.RateLimiter;
import karnold.utils.Util;

import scripts.IGameScript;
import scripts.TankActor;

final class Enemy
{
	static public const REDROGUE:Enemy = new Enemy;
	static public const GREENK:Enemy = new Enemy;
	static public const GRAYSHOOTER:Enemy = new Enemy;
	static public const FUNNEL:Enemy = new Enemy;
	static public const BLUE:Enemy = new Enemy;
	static public const FIGHTER5:Enemy = new Enemy;
	static public const FIGHTER6:Enemy = new Enemy;
	static public const FIGHTER7:Enemy = new Enemy;
	static public const FIGHTER8:Enemy = new Enemy;
	static public const FIGHTER9:Enemy = new Enemy;
	static public const FIGHTER10:Enemy = new Enemy;
	static public const FIGHTER11:Enemy = new Enemy;
	static public const FIGHTER12:Enemy = new Enemy;
}

final class Utils
{
	static private const REDROGUE_FIRESOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 0, -20);
	static private const LASERSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.LASER, 0, -20);

	//KAI: Doing this here leaks the creation policy knowledge out of the factory
	static private const FLEE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward);
	static private const CHASE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward);
	static private const HOME:CompositeBehavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
	static public function attackAndFlee(source:AmmoFireSource, msRate:uint):IBehavior
	{
		return new AlternatingBehavior
		(
			msRate,
			CHASE,
			new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.createAutofire(source, 300, 1000)),
			FLEE
		);
	}
	static public function homeAndShoot(msShootRate:uint, ammoType:AmmoType):IBehavior
	{
		return new CompositeBehavior
		(
			HOME,
			BehaviorFactory.createAutofire(LASERSOURCE, msShootRate/2, msShootRate)
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
		var plane:Actor = new Actor(SimpleActorAsset.createBlueShip(), BehaviorConsts.BLUE_SHIP);
		plane.behavior = BehaviorFactory.faceForward;
		return plane;
	}
	static public function getTankPlayer():Actor
	{
		var tank:Actor = TankActor.createTankActor(	
			SimpleActorAsset.createTrack(),
			SimpleActorAsset.createTrack(),
			SimpleActorAsset.createHull0(),
			SimpleActorAsset.createTurret0(),
			BehaviorConsts.TEST_TANK
		);
		tank.behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.faceMouse);
		return tank;
	}
	
	static public function addEnemy(game:IGame, type:Enemy):Actor
	{
		var a:Actor;
		switch (type) {
		case Enemy.REDROGUE:
			a = new Actor(SimpleActorAsset.createRedShip(), BehaviorConsts.RED_SHIP);
			a.name = "Red Rogue";
			a.behavior = attackAndFlee(REDROGUE_FIRESOURCE, 5000);
			break;
		case Enemy.GREENK:
			a = new Actor(SimpleActorAsset.createGreenShip(), BehaviorConsts.GREEN_SHIP);
			a.name = "Greenakazi";
			a.behavior = HOME;
			break;
		case Enemy.GRAYSHOOTER:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "Gray Death";
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(LASERSOURCE, 1000, 3000),
				new AlternatingBehavior( 
					3000,
					HOME,
					BehaviorFactory.strafe
				)
			);
			break;
		case Enemy.FUNNEL:
			a = new Actor(SimpleActorAsset.createFunnelShip(), BehaviorConsts.RED_SHIP);
			a.name = "Funnel";
			a.behavior = Utils.homeAndShoot(4000, AmmoType.LASER);
			break;
		case Enemy.BLUE:
			a = new Actor(SimpleActorAsset.createBlueShip()(), BehaviorConsts.GRAY_SHIP);
			a.name = "Blue Bird";
			a.behavior = Utils.homeAndShoot(5000, AmmoType.BULLET);
			break;
		case Enemy.FIGHTER5:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "5";
			a.behavior = Utils.homeAndShoot(6000, AmmoType.BULLET);
			break;
		case Enemy.FIGHTER6:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "6";
			a.behavior = Utils.homeAndShoot(6000, AmmoType.BULLET);
			break;
		case Enemy.FIGHTER7:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "7";
			a.behavior = Utils.homeAndShoot(6000, AmmoType.BULLET);
			break;
		case Enemy.FIGHTER8:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "8";
			a.behavior = Utils.homeAndShoot(6000, AmmoType.BULLET);
			break;
		case Enemy.FIGHTER9:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "9";
			a.behavior = Utils.homeAndShoot(6000, AmmoType.BULLET);
			break;
		case Enemy.FIGHTER10:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "10";
			a.behavior = Utils.homeAndShoot(6000, AmmoType.BULLET);
			break;
		case Enemy.FIGHTER11:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "11";
			a.behavior = Utils.homeAndShoot(6000, AmmoType.BULLET);
			break;
		case Enemy.FIGHTER12:
			a = new Actor(SimpleActorAsset.createGrayShip(), BehaviorConsts.GRAY_SHIP);
			a.name = "12";
			a.behavior = Utils.homeAndShoot(6000, AmmoType.BULLET);
			break;
		}
		placeAtRandomEdge(a, game.worldBounds);
		game.addEnemy(a);
		return a;
	}
}

class BaseScript implements IGameScript
{
	// IGameScript
	public function begin(game:IGame):void {}

	// IGameEvents
	public function onCenterPrintDone(text:String):void	{}

	public function onPlayerStruckByEnemy(game:IGame, enemy:Actor):void {}
	public function onPlayerStruckByAmmo(game:IGame, ammo:Actor):void {}
	public function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void {}

	static private const TANK_SOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 0, -50);

	private var _weapon:IBehavior = BehaviorFactory.createAutofire(TANK_SOURCE, 300, 300);
	private var _weaponPlane:IBehavior = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.BULLET, 0, -20), 150, 150);
	private var _fireRate:RateLimiter = new RateLimiter(300, 300);
	public function onPlayerShootForward(game:IGame):void
	{
		_weaponPlane.onFrame(game, game.player);
	}
	public function onPlayerShootTo(game:IGame, to:Point):void
	{
		var dobj:DisplayObject = game.player.displayObject;
		dobj.rotation = MathUtil.getDegreesRotation(to.x - dobj.x, to.y - dobj.y);

		_weaponPlane.onFrame(game, game.player);
	}
}

final class TestScript extends BaseScript
{
	private var _actors:int;
	public function TestScript(actors:int)
	{
		_actors = actors;
	}

	public override function begin(game:IGame):void
	{
		game.tiles = GrassTilesAssets.testLevel;
		game.showPlayer(Utils.getBluePlayer());
//		game.showPlayer(Utils.getTankPlayer());
		game.start();
		game.centerPrint("Level 1");
		
		for (var i:int = 0; i < _actors; ++i)
		{
			addTestActors(game);
		}
	}
	
	private function addTestActors(game:IGame):void
	{
		Utils.addEnemy(game, Enemy.REDROGUE);
//		Utils.addEnemy(game, Enemy.GREENK);
//		Utils.addEnemy(game, Enemy.GRAYSHOOTER);
//		Utils.addEnemy(game, Enemy.FIGHTER5);
	}
}

final class Wave
{
	public var type:Enemy;
	public var number:uint;
	public function Wave(type:Enemy, number:uint)
	{
		this.type = type;
		this.number = number;
	}
}
final class WaveBasedGameScript extends BaseScript
{
	private var _game:IGame;
	private var _waveDelay:FrameTimer = new FrameTimer(addNextWave);
	private var _stats:Stats = new Stats;
	public override function begin(game:IGame):void
	{
		_game = game;

		game.tiles = GrassTilesAssets.smallLevel;
		game.showPlayer(Utils.getBluePlayer());
//		game.showPlayer(Utils.getTankPlayer());
		
		game.start();
		game.centerPrint("Level 1");

		game.scoreBoard.pctHealth = 1;
		game.scoreBoard.pctLevel = 0;
		game.scoreBoard.earnings = 0;
	}

	private var _waves:Array = 
	[
		new Wave(Enemy.GREENK, 10),
		new Wave(Enemy.FIGHTER5, 10),
		new Wave(Enemy.GREENK, 15),
		[new Wave(Enemy.GREENK, 10), new Wave(Enemy.REDROGUE, 2)],
		[new Wave(Enemy.FIGHTER5, 10), new Wave(Enemy.REDROGUE, 3)],
		new Wave(Enemy.GREENK, 20),
		[new Wave(Enemy.REDROGUE, 5), new Wave(Enemy.GRAYSHOOTER, 3)],
		[new Wave(Enemy.GREENK, 5), new Wave(Enemy.REDROGUE, 5), new Wave(Enemy.GRAYSHOOTER, 5)]
	];
	private const NUMWAVES:uint = _waves.length;

	static private const _tmpArray:Array = [];
	private var _enemies:uint = 0;
	private function addNextWave():void
	{
		_game.scoreBoard.pctLevel = 1 - _waves.length/NUMWAVES;
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
	public override function onCenterPrintDone(text:String):void	
	{
		if (_waves.length)
		{
			_waveDelay.start(3000, 1);
		}
		else
		{
			_game.scoreBoard.pctLevel = 1;
		}
	}

	// IGameEvents
	public override function onPlayerStruckByEnemy(game:IGame, enemy:Actor):void
	{
		damageActor(game, enemy, game.player.consts.COLLISION_DMG);
		damageActor(game, game.player, enemy.consts.COLLISION_DMG);
	}
	public override function onPlayerStruckByAmmo(game:IGame, ammo:Actor):void
	{
		damageActor(game, game.player, 10);
		game.killActor(ammo);
	}
	public override function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void
	{
		damageActor(game, enemy, 34);
		game.killActor(ammo);
	}

	private function damageActor(game:IGame, actor:Actor, damage:Number):void
	{
		const particles:uint = Math.min(damage/6, 15);
		Actor.createExplosion(game, actor.worldPos, particles, actor == game.player ? 0xffffff : 0xffff00);

		actor.health -= damage;
		if (actor == game.player)
		{
			game.scoreBoard.pctHealth = actor.health / BehaviorConsts.MAX_HEALTH;
		}
		else if (actor.health <= 0)
		{
			_stats.earnings += actor.value;
			game.scoreBoard.earnings = _stats.earnings;
			game.killActor(actor);
			
			--_enemies;
			if (!_enemies)
			{
				if (_waves.length)
				{
					_game.centerPrint("INCOMING WAVE " + (NUMWAVES - _waves.length));	
				}
				else
				{
					_game.centerPrint("CONGRATS LEVEL DONE");
				}
			}
		}
	}
}

final class Stats
{
	public var earnings:uint;
	public var levelsDone:Object;
	public var purchasedItems:Object;
}

final class GrassTilesAssets
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