package scripts
{
	public class GameScript
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
import behaviors.ActorAttrs;
import behaviors.AlternatingBehavior;
import behaviors.AmmoFireSource;
import behaviors.AmmoType;
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
import scripts.IPenetratingAmmo;
import scripts.TankActor;

final class Enemy
{
	static public const REDROGUE:Enemy = new Enemy;
	static public const GREENK:Enemy = new Enemy;
	static public const GRAYSHOOTER:Enemy = new Enemy;
	static public const FUNNEL:Enemy = new Enemy;
	static public const BLUE:Enemy = new Enemy;
	static public const BAT:Enemy = new Enemy;
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
	static public function getPlanePlayer():Actor
	{
		var plane:Actor = new Actor(ActorAssetManager.createShip(0), ActorAttrs.BLUE_SHIP);
		plane.behavior = BehaviorFactory.faceForward;
		return plane;
	}
	static public function getTankPlayer():Actor
	{
		var tank:Actor = TankActor.createTankActor(0, 0, ActorAttrs.TEST_TANK);
		tank.behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.faceMouse);
		return tank;
	}

	static public function addEnemyByIndex(game:IGame, index:uint):Actor
	{
		var a:Actor = new Actor(ActorAssetManager.createShip(index), ActorAttrs.RED_SHIP);
		a.behavior = attackAndFlee(REDROGUE_FIRESOURCE, 5000);

		placeAtRandomEdge(a, game.worldBounds);
		game.addEnemy(a);
		return a;
	}
	
	static public function addEnemy(game:IGame, type:Enemy):Actor
	{
		var a:Actor;
		switch (type) {
		case Enemy.REDROGUE:
			a = new Actor(ActorAssetManager.createShip(23, 0.7), ActorAttrs.RED_SHIP);
			a.name = "Red Rogue";
			a.behavior = attackAndFlee(REDROGUE_FIRESOURCE, 5000);
			break;
		case Enemy.GREENK:
			a = new Actor(ActorAssetManager.createShip(3), ActorAttrs.GREEN_SHIP);
			a.name = "Greenakazi";
			a.behavior = HOME;
			break;
		case Enemy.GRAYSHOOTER:
			a = new Actor(ActorAssetManager.createShip(6), ActorAttrs.GRAY_SHIP);
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
		case Enemy.BAT:
			a = new Actor(ActorAssetManager.createShip(9), ActorAttrs.GRAY_SHIP);
			a.name = "Bat";
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(LASERSOURCE, 1000, 3000),
				new AlternatingBehavior( 
					3000,
					HOME,
					BehaviorFactory.strafe
				)
			);
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
	public function onCenterPrintDone():void	{}

	public function onPlayerStruckByEnemy(game:IGame, enemy:Actor):void {}
	public function onPlayerStruckByAmmo(game:IGame, ammo:Actor):void {}
	public function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void {}

	static protected const TANK:Boolean = false;
	protected var _weapon:IBehavior;

	private var _fireRate:RateLimiter = new RateLimiter(300, 300);
	public function onPlayerShootForward(game:IGame):void
	{
		if (_weapon)
		{
			_weapon.onFrame(game, game.player);
		}
	}
	private function pointPlayerAtMouse(game:IGame):void
	{
		// should go in a behavior
		const mouse:Point = game.input.lastMousePos;
		var dobj:DisplayObject = game.player.displayObject;
		dobj.rotation = MathUtil.getDegreesRotation(mouse.x - dobj.x, mouse.y - dobj.y);
	}
	public function onPlayerShootToMouse(game:IGame):void
	{
		if (_weapon)
		{
			if (!TANK)
			{
				pointPlayerAtMouse(game);
			}
			_weapon.onFrame(game, game.player);
		}
	}
	public function onPlayerStopShooting(game:IGame):void
	{
		if (_weapon)
		{
			if (!TANK)
			{
				pointPlayerAtMouse(game);
			}
			_weapon.onFrame(game, game.player);
		}
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
		if (TANK)
		{
			game.showPlayer(Utils.getTankPlayer());
		}
		else
		{
			game.showPlayer(Utils.getPlanePlayer());
		}
		game.start();
		game.centerPrint("Test Script Begin");
		
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
class WaveBasedGameScript extends BaseScript
{
	static private const COMBO_LAPSE:uint = 2000;

	private var _game:IGame;
	private var _waveDelay:FrameTimer = new FrameTimer(addNextWave);
	private var _comboTimer:FrameTimer = new FrameTimer(decreaseCombo);
	private var _stats:Stats = new Stats;
	public override function begin(game:IGame):void
	{
		_game = game;

		game.tiles = GrassTilesAssets.smallLevel;

		if (TANK)
		{
			_weapon = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.BULLET, 0, -50), 300, 300);
			game.showPlayer(Utils.getTankPlayer());
		}
		else
		{
//			_weapon = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.FUSION, 0, -20), 150, 150);
			_weapon = BehaviorFactory.createChargedFire(new AmmoFireSource(AmmoType.FUSION, 0, -20), 6, 250, 1);
			game.showPlayer(Utils.getPlanePlayer());
		}
		
		game.start();
		game.centerPrint("Wave 1");

		game.scoreBoard.pctHealth = 1;
		game.scoreBoard.pctLevel = 0;
		game.scoreBoard.earnings = 0;
	}

	private var _waves:Array = 
	[
		new Wave(Enemy.GREENK, 10),
		new Wave(Enemy.BAT, 10),
		new Wave(Enemy.GREENK, 15),
		[new Wave(Enemy.GREENK, 10), new Wave(Enemy.REDROGUE, 2)],
		[new Wave(Enemy.BAT, 10), new Wave(Enemy.REDROGUE, 3)],
		new Wave(Enemy.GREENK, 20),
		[new Wave(Enemy.REDROGUE, 5), new Wave(Enemy.GRAYSHOOTER, 3)],
		[new Wave(Enemy.GREENK, 5), new Wave(Enemy.REDROGUE, 5), new Wave(Enemy.GRAYSHOOTER, 5)]
	];
	private const NUMWAVES:uint = _waves.length;

	static private const _tmpArray:Array = [];
	private var _enemies:uint = 0;
private var _wave:uint = 0;
	private function addNextWave():void
	{
//Utils.addEnemyByIndex(_game, _wave++);
//Utils.addEnemyByIndex(_game, _wave++);
//Utils.addEnemyByIndex(_game, _wave++);
//_enemies = 3;
//return;
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
	public override function onCenterPrintDone():void	
	{
		if (_waves.length)
		{
			_waveDelay.start(200, 1);
		}
		else
		{
			_game.scoreBoard.pctLevel = 1;
		}
	}

	// IGameEvents
	public override function onPlayerStruckByEnemy(game:IGame, enemy:Actor):void
	{
		damageActor(game, enemy, game.player.attrs.COLLISION_DMG, true);
		damageActor(game, game.player, enemy.attrs.COLLISION_DMG);
	}
	public override function onPlayerStruckByAmmo(game:IGame, ammo:Actor):void
	{
		damageActor(game, game.player, 10);
		game.killActor(ammo);
	}
	public override function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void
	{
		var pa:IPenetratingAmmo = ammo as IPenetratingAmmo;
		if (pa)
		{
			if (!pa.isActorStruck(enemy))
			{
				pa.strikeActor(enemy);
				damageActor(game, enemy, 34);
			}
		}
		else
		{
			damageActor(game, enemy, 34);
			game.killActor(ammo);
		}
	}

	private function damageActor(game:IGame, actor:Actor, damage:Number, struckByEnemy:Boolean = false):void
	{
		const isPlayer:Boolean = actor == game.player;
		const particles:uint = isPlayer ? damage/2 : Math.min(damage/6, 15);
		Actor.createExplosion(game, actor.worldPos, particles, isPlayer ? 0 : 1);

		actor.health -= damage;
		if (isPlayer)
		{
			game.scoreBoard.pctHealth = actor.health / ActorAttrs.MAX_HEALTH;
		}
		else if (actor.health <= 0)
		{
			AssetManager.instance.crashSound();
			if (!struckByEnemy)
			{
				_stats.earnings += actor.value * (1 + _stats.combo/10);
				game.scoreBoard.earnings = _stats.earnings;
				game.scoreBoard.combo = ++_stats.combo;
				_comboTimer.start(COMBO_LAPSE);
			}
			game.killActor(actor);

			--_enemies;
			if (!_enemies)
			{
				if (_waves.length)
				{
					_game.centerPrint("Wave " + (NUMWAVES - _waves.length + 1));	
				}
				else
				{
					_game.centerPrint("Level complete - you did it!");
				}
			}
		}
	}
	
	private function decreaseCombo():void
	{
		if (_stats.combo)
		{
			_game.scoreBoard.combo = --_stats.combo;
		}
		else
		{
			_comboTimer.stop();
		}
	}
}

final class Stats
{
	public var earnings:uint;
	public var levelsDone:Object;
	public var purchasedItems:Object;
	public var combo:uint;
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