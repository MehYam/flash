package scripts
{
	import behaviors.ActorAttrs;

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
			const GREEN:ActorAttrs = new ActorAttrs(20, 1.5, 0.1, 0, 10, 10);
			const MOTH:ActorAttrs = new ActorAttrs(30, 3, 0.1, 0, 15, 15);
			const OSPREY:ActorAttrs = new ActorAttrs(100, 1.5, 0.15, 20);
			
			var waves:Array =
			[
				new Wave(EnemyEnum.GREENK, 5, GREEN),
				[new Wave(EnemyEnum.GREENK, 5, GREEN), new Wave(EnemyEnum.MOTH, 1, MOTH)],
				new Wave(EnemyEnum.MOTH, 3, MOTH),
				[new Wave(EnemyEnum.GREENK, 7, GREEN), new Wave(EnemyEnum.MOTH, 2, MOTH)],
				new Wave(EnemyEnum.OSPREY, 1, OSPREY),
				new Wave(EnemyEnum.GREENK, 7, GREEN),
				[new Wave(EnemyEnum.GREENK, 2, GREEN), new Wave(EnemyEnum.MOTH, 3, MOTH)],
				new Wave(EnemyEnum.MOTH, 6, MOTH),
				[new Wave(EnemyEnum.GREENK, 5, GREEN), new Wave(EnemyEnum.MOTH, 3, MOTH)],
				new Wave(EnemyEnum.OSPREY, 3, OSPREY)
			];

			return new WaveBasedGameScript(waves);
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

import gameData.PlaneData;
import gameData.TankPartData;
import gameData.UserData;

import karnold.utils.Bounds;
import karnold.utils.FrameTimer;
import karnold.utils.MathUtil;
import karnold.utils.RateLimiter;
import karnold.utils.Util;

import scripts.IGameScript;
import scripts.IPenetratingAmmo;
import scripts.TankActor;

final class EnemyEnum
{
	static public const MOTH:EnemyEnum = new EnemyEnum;
	static public const GREENK:EnemyEnum = new EnemyEnum;
	static public const GRAYSHOOTER:EnemyEnum = new EnemyEnum;
	static public const FUNNEL:EnemyEnum = new EnemyEnum;
	static public const BLUE:EnemyEnum = new EnemyEnum;
	static public const OSPREY:EnemyEnum = new EnemyEnum;
}

final class TestAttrs
{
	static public const RED_SHIP:ActorAttrs = new ActorAttrs(100, 3, 0.1, 0, 15, 15);
	static public const TANK:ActorAttrs = new ActorAttrs(100, 1.5, 1, 0.5);
}
final class Utils
{
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
			new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.createAutofire(source, 300, 2000)),
			FLEE
		);
	}
	static public function homeAndShoot(msShootRate:uint, ammoType:AmmoType):IBehavior
	{
		return new CompositeBehavior
		(
			HOME,
			BehaviorFactory.createAutofire(OSPREY_LASERSOURCE, msShootRate/2, msShootRate)
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
	static public function getPlayerPlane():PlayerVehicle
	{
		const asset:uint = PlaneData.getPlane(UserData.instance.currentPlane).assetIndex;

		var weapon:IBehavior;
		var attrs:ActorAttrs;
		switch (UserData.instance.currentPlane) {
			case 0:
				weapon = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.BULLET, 10, 0, -20), 333);
				attrs = new ActorAttrs(100, 5, 1, 0.1);
				break;
//			case 1:
//				weapon = new CompositeBehavior(BehaviorFactory.createAutoFire(new 
		}
		var plane:Actor = new Actor(ActorAssetManager.createShip(asset), attrs);
		plane.behavior = BehaviorFactory.faceForward;
		var retval:PlayerVehicle = new PlayerVehicle(plane, weapon);
		
		return retval;
	}
	static public function getPlayerTank():PlayerVehicle
	{
		const hull:uint = TankPartData.getHull(UserData.instance.currentHull).assetIndex;
		const turret:uint = TankPartData.getTurret(UserData.instance.currentTurret).assetIndex;
		
		var tank:Actor = TankActor.createTankActor(hull, turret, TestAttrs.TANK);
		tank.behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.faceMouse);
		return null;
	}

	static public function addEnemyByIndex(game:IGame, index:uint):Actor
	{
		var a:Actor = new Actor(ActorAssetManager.createShip(index), TestAttrs.RED_SHIP);
		a.behavior = attackAndFlee(MOTH_BULLETSOURCE, 5000);

		placeAtRandomEdge(a, game.worldBounds);
		game.addEnemy(a);
		return a;
	}
	
	static private const MOTH_BULLETSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 10, 0, -20, 0, 4);
	static private const OSPREY_LASERSOURCE:Array =
	[
		new AmmoFireSource(AmmoType.LASER, 10, -35, -15),
		new AmmoFireSource(AmmoType.LASER, 10,  35, -15)
	];
	static public function addEnemy(game:IGame, type:EnemyEnum, attrs:ActorAttrs):Actor
	{
		var a:Actor;
		switch (type) {
		case EnemyEnum.MOTH:
			a = new Actor(ActorAssetManager.createShip(23, 0.7), attrs);
			a.name = "Red Rogue";
			a.behavior = attackAndFlee(MOTH_BULLETSOURCE, 5000);
			break;
		case EnemyEnum.GREENK:
			a = new Actor(ActorAssetManager.createShip(3), attrs);
			a.name = "Greenakazi";
			a.behavior = HOME;
			break;
		case EnemyEnum.GRAYSHOOTER:
			a = new Actor(ActorAssetManager.createShip(6), attrs);
			a.name = "Gray Death";
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(OSPREY_LASERSOURCE, 1000, 3000),
				new AlternatingBehavior( 
					3000,
					HOME,
					BehaviorFactory.strafe
				)
			);
			break;
		case EnemyEnum.OSPREY:
			a = new Actor(ActorAssetManager.createShip(9), attrs);
			a.name = "Osprey";
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(OSPREY_LASERSOURCE, 1000, 3000),
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
	protected const TANK:Boolean = false;
	private var _weapon:IBehavior;
	public function begin(game:IGame):void 
	{
		var player:PlayerVehicle;
		if (TANK)
		{
			player = Utils.getPlayerTank();
			_weapon = player.weapon;//BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.BULLET, 0, -50), 300, 300);
			game.showPlayer(player.actor);
		}
		else
		{
			player = Utils.getPlayerPlane();
			_weapon = player.weapon;
			game.showPlayer(player.actor);
		}
	}

	// IGameEvents
	public function onCenterPrintDone():void	{}

	public function onPlayerStruckByEnemy(game:IGame, enemy:Actor):void {}
	public function onPlayerStruckByAmmo(game:IGame, ammo:Actor):void {}
	public function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void {}

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
				//KAI: bug to fix here when player shooting w/ keyboard.  I think this was to get fusion to work right
				pointPlayerAtMouse(game);
			}
			_weapon.onFrame(game, game.player);
		}
	}
	public function damageActor(game:IGame, actor:Actor, damage:Number, struckByEnemy:Boolean = false):void {}
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
			game.showPlayer(Utils.getPlayerTank().actor);
		}
		else
		{
			game.showPlayer(Utils.getPlayerPlane().actor);
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
//		Utils.addEnemy(game, EnemyEnum.MOTH);
//		Utils.addEnemy(game, Enemy.GREENK);
//		Utils.addEnemy(game, Enemy.GRAYSHOOTER);
//		Utils.addEnemy(game, Enemy.FIGHTER5);
	}
}

final class Wave
{
	public var type:EnemyEnum;
	public var number:uint;
	public var attrs:ActorAttrs;
	public function Wave(type:EnemyEnum, number:uint, attrs:ActorAttrs)
	{
		this.type = type;
		this.number = number;
		this.attrs = attrs;
	}
}
class WaveBasedGameScript extends BaseScript
{
	static private const COMBO_LAPSE:uint = 2000;

	private var NUMWAVES:uint;
	private var _waves:Array; 
	public function WaveBasedGameScript(waves:Array)
	{
		super();
		_waves = waves;
		NUMWAVES = waves.length;
	}

	private var _game:IGame;
	private var _waveDelay:FrameTimer = new FrameTimer(addNextWave);
	private var _comboTimer:FrameTimer = new FrameTimer(decreaseCombo);
	private var _stats:Stats = new Stats;
	public override function begin(game:IGame):void
	{
		_game = game;
		game.tiles = GrassTilesAssets.smallLevel;

		super.begin(game); //KAI:

		game.start();
		game.centerPrint("Wave 1");

		game.scoreBoard.pctHealth = 1;
		game.scoreBoard.pctLevel = 0;
		game.scoreBoard.earnings = 0;
	}


	static private const _tmpArray:Array = [];
	private var _enemies:uint = 0;
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
					Utils.addEnemy(_game, wave.type, wave.attrs);
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
		damageActor(game, enemy, game.player.damage, true);
		damageActor(game, game.player, enemy.damage);
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
				damageActor(game, enemy, ammo.damage);
			}
		}
		else
		{
			damageActor(game, enemy, ammo.damage);
			game.killActor(ammo);
		}
	}

	public override function damageActor(game:IGame, actor:Actor, damage:Number, struckByEnemy:Boolean = false):void
	{
		const isPlayer:Boolean = actor == game.player;
		const particles:uint = isPlayer ? Math.max(2, damage/2) : Math.min(damage/6, 15);
		Actor.createExplosion(game, actor.worldPos, particles, isPlayer ? 0 : 1);
		actor.health -= damage;
		if (isPlayer)
		{
			game.scoreBoard.pctHealth = actor.health / actor.attrs.MAX_HEALTH;
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

final class PlayerVehicle
{
	public var actor:Actor;
	public var weapon:IBehavior;
	
	public function PlayerVehicle(actor:Actor, weapon:IBehavior)
	{
		this.actor = actor;
		this.weapon = weapon;
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