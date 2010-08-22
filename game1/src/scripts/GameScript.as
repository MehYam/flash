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

		static private var s_levels:Array;
		static public function getLevel(i:uint):IGameScript
		{
			if (!s_levels)
			{
				s_levels = [];
				
				const waveStr:String = Levels.planeLevels;
				
				var lines:Array = waveStr.split("\n");
				lines.length;
				
				var level:Array;
				const levelDelimiter:uint = "#".charCodeAt(0);
				for each (var line:String in lines)
				{
					if (line.length < 2) continue;
					if (line.charCodeAt(0) == levelDelimiter)
					{
						if (level)
						{
							s_levels.push(level);
						}
						level = [];
					}
					else
					{
						var wave:Array = []
						var spawns:Array = line.split(";");
						for each (var spawn:String in spawns)
						{
							var spawnArgs:Array = spawn.split(",");
							wave.push(new Wave(EnemyEnum.LOOKUP[spawnArgs[0]], parseInt(spawnArgs[1])));
						}
						level.push(wave);
					}
				}
			}
			return new WaveBasedGameScript(s_levels[i]);
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
import flash.filters.DropShadowFilter;
import flash.geom.Point;

import gameData.PlaneData;
import gameData.PlayedLevelStats;
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
	static public var LOOKUP:Object = {};
	public var attrs:ActorAttrs;
	public function EnemyEnum(attrs:ActorAttrs, name:String)
	{
		this.attrs = attrs;
		LOOKUP[name] = this;
	}
	
	//KAI: Doing this here leaks the creation policy knowledge out of the factory
	static private const FLEE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward);
	static private const CHASE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward);
	static private const HOME:CompositeBehavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
	static public function attackAndFlee(source:AmmoFireSource, msRate:uint, msShootRateMin:uint = 300, msShootRateMax:uint = 2000):IBehavior
	{
		return new AlternatingBehavior
		(
			msRate,
			CHASE,
			new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.createAutofire(source, msShootRateMin, msShootRateMax)),
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

	static public const BEE:EnemyEnum =       new EnemyEnum(new ActorAttrs( 40, 5,   0.05, 0, 10, 33), "BEE");
	static public const GREENK:EnemyEnum =    new EnemyEnum(new ActorAttrs( 20, 1.5, 0.1,  0, 10, 10), "GREENK");
	static public const MOTH:EnemyEnum =      new EnemyEnum(new ActorAttrs( 30, 3,   0.1,  0, 15, 15), "MOTH");
	static public const OSPREY:EnemyEnum =    new EnemyEnum(new ActorAttrs(100, 1.5, 0.15, 0, 25, 33), "OSPREY");
	static public const BAT:EnemyEnum =       new EnemyEnum(new ActorAttrs(100, 2,   0.05, 0, 20, 20), "BAT");
	
	static private const MOTH_BULLETSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 10, 0, -20, 0, 4);
	static private const OSPREY_LASERSOURCE:Array =
		[
			new AmmoFireSource(AmmoType.LASER, 10, -35, -15),
			new AmmoFireSource(AmmoType.LASER, 10,  35, -15)
		];
	static private const BAT_ROCKETSOURCE:Array = 
		[
			new AmmoFireSource(AmmoType.ROCKET, 20, -20, -10, 0, 3),
			new AmmoFireSource(AmmoType.ROCKET, 20,  20, -10, 0, 3)
		];
	static private const BEE_BULLETSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 20, 0, -10, 0, 1);
	public function create():Actor
	{
		var a:Actor;
		switch (this) {  //KAI: omg i've never seen anything like that, lol, alternative to creating classes
		case EnemyEnum.MOTH:
			a = new Actor(ActorAssetManager.createShip(23, 0.7), attrs);
			a.behavior = attackAndFlee(MOTH_BULLETSOURCE, 5000);
			break;
		case EnemyEnum.BEE:
			a = new Actor(ActorAssetManager.createShip(0), attrs);
			a.behavior = attackAndFlee(BEE_BULLETSOURCE, 3000, 1000, 1000);
			break;
		case EnemyEnum.GREENK:
			a = new Actor(ActorAssetManager.createShip(3), attrs);
			a.behavior = HOME;
			break;
		case EnemyEnum.BAT:
			a = new Actor(ActorAssetManager.createShip(6), attrs);
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(BAT_ROCKETSOURCE[0], 2000, 4000),
				BehaviorFactory.createAutofire(BAT_ROCKETSOURCE[1], 2000, 4000),
				new AlternatingBehavior( 
					3000,
					HOME,
					BehaviorFactory.strafe
				)
			);
			break;
		case EnemyEnum.OSPREY:
			a = new Actor(ActorAssetManager.createShip(9), attrs);
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
		return a;
	}
}
final class Utils
{
	static public function getPlayerPlane():PlayerVehicle
	{
		const asset:uint = PlaneData.getPlane(UserData.instance.currentPlane).assetIndex;

		var weapon:IBehavior;
		var attrs:ActorAttrs;
		// this in order of the general progression of ships
		switch (UserData.instance.currentPlane) {
			case 0:
//				weapon = BehaviorFactory.createChargedFire(new AmmoFireSource(AmmoType.FUSION, 10, 0, -20), 5, 1000, 1);
//				weapon = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 10, 0, -10), 400);
				weapon = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.BULLET, 10, 0, -10), 400);
				attrs = new ActorAttrs(100, 4.5, 0.5, 0.2, EnemyEnum.BEE.attrs.RADIUS);
				break;
			case 1:
				weapon = BehaviorFactory.createAutofire(
					[new AmmoFireSource(AmmoType.BULLET, 10, -15, 0), new AmmoFireSource(AmmoType.BULLET, 10, 15, 0)], 
					400);
				attrs = new ActorAttrs(100, 5, 0.5, 0.1, EnemyEnum.BEE.attrs.RADIUS);
				break;
			case 3:
				weapon = BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 10, 0, -10));
				attrs = new ActorAttrs(200, 3, 1, 0.1, EnemyEnum.GREENK.attrs.RADIUS);
				break;
			case 6:
				weapon = new AlternatingBehavior(
					1000,
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20, -20, -10, 0, 3), 1000),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20,  20, -10, 0, 3), 1000)
				);
				attrs = new ActorAttrs(200, 4, 0.3, 0.1, EnemyEnum.BAT.attrs.RADIUS);
				break;
			case 2:
				weapon = BehaviorFactory.createAutofire(
					[new AmmoFireSource(AmmoType.BULLET, 10, -15, 0), 
					 new AmmoFireSource(AmmoType.BULLET, 10,  15, 0),
					 new AmmoFireSource(AmmoType.BULLET, 10,   0, -10)], 
					400);
				attrs = new ActorAttrs(100, 5.5, 1, 0.1, EnemyEnum.BEE.attrs.RADIUS);
				break;
			case 4:
				weapon = BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 20, 0, -10));
				attrs = new ActorAttrs(300, 3.5, 0.7, 0.1, EnemyEnum.GREENK.attrs.RADIUS);
				break;
			case 7:
				weapon = new AlternatingBehavior(
					400,
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15, -20, -10, 0, 3), 1000),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15, -15,  -5, 0, 3), 1000),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15,  20,   5, 0, 3), 1000),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15,  20, -10, 0, 3), 1000)
				);
				attrs = new ActorAttrs(225, 4.5, 0.3, 0.1, EnemyEnum.BAT.attrs.RADIUS+2);
				break;
			case 5:
				weapon = new CompositeBehavior(
					BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 30, 0, -10)),
					BehaviorFactory.createAutofire(
						[new AmmoFireSource(AmmoType.LASER, 5, -10, 0, 0, 1),
						new AmmoFireSource(AmmoType.LASER, 5,   10, 0, 0, 1)], 
						1500, 1500)
				);	
				attrs = new ActorAttrs(333, 3.7, 0.7, 0.1, EnemyEnum.GREENK.attrs.RADIUS);
				break;
			case 8:
				break;
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
		
		var tank:Actor = TankActor.createTankActor(hull, turret, new ActorAttrs(100, 1.5, 1, 0.5));
		tank.behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.faceMouse);
		return null;
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
	static public function addEnemy(game:IGame, type:EnemyEnum):Actor
	{
		var a:Actor = type.create();
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
			_weapon = player.weapon;
			game.setPlayer(player.actor);
		}
		else
		{
			player = Utils.getPlayerPlane();
			_weapon = player.weapon;
			game.setPlayer(player.actor);
		}
	}

	// IGameEvents
	public function onCenterPrintDone():void	{}

	public function onOpposingCollision(game:IGame, friendly:Actor, enemy:Actor):void {}
	public function onFriendlyStruckByAmmo(game:IGame, friendly:Actor, ammo:Actor):void {}
	public function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void {}

	private var _fireRate:RateLimiter = new RateLimiter(300, 300);
	public function onPlayerShooting(game:IGame, mouse:Boolean):void
	{
		if (_weapon)
		{
			if (!TANK && mouse)
			{
				pointPlayerAtMouse(game);
			}
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
	public function onPlayerStopShooting(game:IGame, mouse:Boolean):void
	{
		if (_weapon)
		{
			if (!TANK && mouse)
			{
				pointPlayerAtMouse(game);
			}
			_weapon.onFrame(game, game.player);
		}
	}
	public function damageActor(game:IGame, actor:Actor, damage:Number, actorFriendly:Boolean, wasCollision:Boolean):void {}
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
		game.tiles = GrassTilesLevels.testLevel;
		super.begin(game);
		
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
//		Utils.addEnemy(game, Enemy.BAT);
//		Utils.addEnemy(game, Enemy.FIGHTER5);
	}
}

final class Wave
{
	public var type:EnemyEnum;
	public var number:uint;
	public var attrs:ActorAttrs;
	public function Wave(type:EnemyEnum, number:uint)
	{
		this.type = type;
		this.number = number;
		this.attrs = type.attrs; // ... keeping this just in case we want to split them out again
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
	private var _stats:PlayedLevelStats = new PlayedLevelStats;
	public override function begin(game:IGame):void
	{
		_game = game;
		game.tiles = GrassTilesLevels.smallLevel;

		super.begin(game); //KAI:

		game.unpause();
		game.centerPrint("Wave 1");

		game.scoreBoard.pctHealth = 1;
		game.scoreBoard.pctLevel = 0;
		game.scoreBoard.earnings = 0;

		for each (var stage:* in _waves)
		{
			var next:Array = stage as Array;
			if (!next)
			{
				po_tmpArray[0] = stage;
				next = po_tmpArray;
			}
			for each (var wave:Wave in next)
			{
				_stats.enemiesTotal += wave.number;
			}
		}
		_stats.begin();
	}

	private const po_tmpArray:Array = [];
	private var _liveEnemies:uint = 0;
	private function addNextWave():void
	{
		_game.scoreBoard.pctLevel = 1 - _waves.length/NUMWAVES;
		if (_waves.length)
		{
			var next:Object = _waves.shift();
			if (!(next is Array))
			{
				po_tmpArray[0] = next;
				next = po_tmpArray;
			}
			for each (var wave:Wave in next)
			{
				for (var i:uint = 0; i < wave.number; ++i)
				{
					Utils.addEnemy(_game, wave.type);
					++_liveEnemies;
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
			_game.endLevel(_stats);
		}
	}

	// IGameEvents
	public override function onOpposingCollision(game:IGame, friendly:Actor, enemy:Actor):void
	{
		const shieldCollisionTreatLikeAmmo:Boolean = friendly == game.player;
		damageActor(game, enemy, friendly.damage, false, shieldCollisionTreatLikeAmmo);
		damageActor(game, friendly, enemy.damage, true, true);
	}
	public override function onFriendlyStruckByAmmo(game:IGame, friendly:Actor, ammo:Actor):void
	{
		damageActor(game, friendly, ammo.damage, true, false);
		if (friendly == game.player)
		{
			game.killActor(ammo);
		}
		else if (friendly.alive)
		{
			ammo.speed.x = -ammo.speed.x;
			ammo.speed.y = -ammo.speed.y;
		}
	}
	public override function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void
	{
		var pa:IPenetratingAmmo = ammo as IPenetratingAmmo;
		if (pa)
		{
			if (!pa.isActorStruck(enemy))
			{
				pa.strikeActor(enemy);
				damageActor(game, enemy, ammo.damage, false, false);
			}
		}
		else
		{
			damageActor(game, enemy, ammo.damage, false, false);
			game.killActor(ammo);
		}
	}

	// this is a little nutty - seems like we should be using OOP or something
	public override function damageActor(game:IGame, actor:Actor, damage:Number, isFriendly:Boolean, wasCollision:Boolean):void
	{
		const isPlayer:Boolean = actor == game.player;

		// Deal the damage and cue the visual effect
		if (!isFriendly || isPlayer)
		{
			const particles:uint = Math.max(10, 10 * damage/actor.attrs.MAX_HEALTH);
			Actor.createExplosion(game, actor.worldPos, particles, isPlayer ? 0 : 1);
		}

		actor.health -= damage;
		if (actor.health > 0)
		{
			actor.registerHit(isPlayer);
		}

		// Maintain player damage and stats
		if (isPlayer)
		{
			game.scoreBoard.pctHealth = actor.health / actor.attrs.MAX_HEALTH;
			_stats.damageReceived += damage;
		}
		if (!isFriendly && !wasCollision)
		{
			_stats.damageDealt += damage;
		}

		// handle actor death
		if (actor.health <= 0 && !isPlayer)
		{
			game.killActor(actor);

			if (!isFriendly)
			{
				AssetManager.instance.deathSound();
				if (!wasCollision)
				{
					_stats.creditsEarned += actor.value * (1 + _stats.combo/10);
					++_stats.enemiesKilled;
					game.scoreBoard.earnings = _stats.creditsEarned;
					game.scoreBoard.combo = ++_stats.combo;
					_comboTimer.start(COMBO_LAPSE);
				}
				--_liveEnemies;
				if (!_liveEnemies)
				{
					if (_waves.length)
					{
						_game.centerPrint("Wave " + (NUMWAVES - _waves.length + 1));	
					}
					else
					{
						_game.centerPrint("Level complete - you did it!");
						
						_stats.end();
						_stats.victory = true;
						
						_game.scoreBoard.pctLevel = 1;
						_comboTimer.stop();
					}
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

final class GrassTilesLevels
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

final class Levels
{
	[Embed(source="assets/planelevels.txt", mimeType="application/octet-stream")]
	static private const PlaneLevels:Class;
	static public function get planeLevels():String
	{
		return (new PlaneLevels).toString();
	}
}