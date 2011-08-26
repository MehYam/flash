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

		static private function parseLevels(encodedLevels:String):Array
		{
			var lines:Array = encodedLevels.split("\n");
			
			var levels:Array = [];
			var tmpLevel:Array;
			const levelDelimiter:uint = "#".charCodeAt(0);
			for each (var line:String in lines)
			{
				if (line.length < 2) continue;
				if (line.charCodeAt(0) == levelDelimiter)
				{
					if (tmpLevel && tmpLevel.length)
					{
						levels.push(tmpLevel);
					}
					tmpLevel = [];
				}
				else
				{
					var wave:Array = []
					var spawns:Array = line.split(";");
					for each (var spawn:String in spawns)
					{
						var spawnArgs:Array = spawn.split(",");
						if (spawnArgs.length == 2)
						{
							wave.push(new Wave(EnemyEnum.LOOKUP[spawnArgs[0]], parseInt(spawnArgs[1])));
						}
						else
						{
							throw "Bad level data";
						}
					}
					tmpLevel.push(wave);
				}
			}
			return levels;
		}
		static private var s_levels:Object; 
		static public function getLevel(i:uint):IGameScript
		{
			if (!s_levels)
			{
				s_levels = { planes: parseLevels(Levels.planeLevels), tanks: parseLevels(Levels.tankLevels) };
			}
			
			const tank:Boolean = (i%2) == 0;
			const level:uint = i/2;
			const waves:Array = tank ? s_levels.tanks[level] : s_levels.planes[level]; 
			
			return new WaveBasedGameScript(waves.slice(), tank);
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
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import gameData.PlaneData;
import gameData.PlayedLevelStats;
import gameData.TankPartData;
import gameData.UserData;

import karnold.utils.Bounds;
import karnold.utils.FrameTimer;
import karnold.utils.MathUtil;
import karnold.utils.RateLimiter;
import karnold.utils.Util;

import scripts.BlingActor;
import scripts.ExplosionActor;
import scripts.GameScriptPlayerFactory;
import scripts.GameScriptPlayerVehicle;
import scripts.IGameScript;
import scripts.IPenetratingAmmo;
import scripts.ShieldActor;
import scripts.SmallExplosionActor;
import scripts.TankActor;

class EnemyEnum
{
	static public var LOOKUP:Object = {};
	public var attrs:ActorAttrs;
	public var assetIndex:uint;
	public var value:uint;
	public function EnemyEnum(attrs:ActorAttrs, assetIndex:uint, name:String, value:uint)
	{
		this.attrs = attrs;
		this.assetIndex = assetIndex;
		this.attrs.RADIUS = PlaneData.getPlane(assetIndex).radius;
		this.attrs.VALUE = value;
		this.attrs.BOUND_EXTENT = ActorAttrs.EXTENT_FURTHER;

		LOOKUP[name] = this;
	}
	
	static protected const FLEE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward);
	static protected const FLEEFACING:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.facePlayer);
	static protected const GRAVITY:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward);
	static protected const HOME:CompositeBehavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
	static public function attackAndFlee(source:*, msRate:uint, msShootRateMin:uint = 300, msShootRateMax:uint = 2000):IBehavior
	{
		return new AlternatingBehavior
		(
			msRate/2, msRate*3/2,
			GRAVITY,
			new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.createAutofire(source, msShootRateMin, msShootRateMax)),
			FLEE
		);
	}
	public function create():Actor
	{
		return create_impl();
	}
	protected function create_impl():Actor { throw "abstract method"; }
}
final class PlaneEnemyEnum extends EnemyEnum
{
	// first tier cast
	static public const BEE:EnemyEnum =       new PlaneEnemyEnum(new ActorAttrs(  40, 5,   0.05, 0,   0, 33), 0, "BEE", 5);
	static public const GREENK:EnemyEnum =    new PlaneEnemyEnum(new ActorAttrs(  20, 1.5, 0.1,  0,   0, 10), 3, "GREENK", 5);
	static public const MOTH:EnemyEnum =      new PlaneEnemyEnum(new ActorAttrs(  30, 3,   0.1,  0,   0, 15), 21, "MOTH", 10);
	static public const OSPREY:EnemyEnum =    new PlaneEnemyEnum(new ActorAttrs( 100, 1.5, 0.15, 0,   0, 33), 9, "OSPREY", 15);
	static public const BAT:EnemyEnum =       new PlaneEnemyEnum(new ActorAttrs( 100, 2,   0.05, 0,   0, 20), 6, "BAT", 15);
	
	// second tier - level 6
	static public const GHOST:EnemyEnum =     new PlaneEnemyEnum(new ActorAttrs(  65, 3,   0.05, 0.1, 0, 50), 18, "GHOST", 25);
	static public const GREENK2:EnemyEnum =   new PlaneEnemyEnum(new ActorAttrs(  80, 1.5, 0.1,  0,   0, 50),  4, "GREENK2", 15);
	static public const CYGNUS:EnemyEnum =    new PlaneEnemyEnum(new ActorAttrs( 125, 6,   0.25, 0.05,0, 66), 15, "CYGNUS", 30);
	static public const ROCINANTE:EnemyEnum = new PlaneEnemyEnum(new ActorAttrs( 180, 3,   0.25, 0.05,0, 66), 28, "ROCINANTE", 35);
	
	// next tier - level 9
	static public const BEE2:EnemyEnum =      new PlaneEnemyEnum(new ActorAttrs( 120, 5,   0.05, 0.02,0, 50), 1,  "BEE2", 50);
	static public const FLY:EnemyEnum =       new PlaneEnemyEnum(new ActorAttrs( 180, 1.5, 0.2,  0,   0, 75), 12, "FLY", 20); 
	static public const MOTH2:EnemyEnum =     new PlaneEnemyEnum(new ActorAttrs( 180, 4,   0.1,  0,   0, 66), 22, "MOTH2", 45);
	static public const BAT2:EnemyEnum =      new PlaneEnemyEnum(new ActorAttrs( 300, 2,   0.05, 0,   0, 20), 7,  "BAT2", 65);
	static public const BLUEK:EnemyEnum =     new PlaneEnemyEnum(new ActorAttrs( 250, 1.5, 0.1,  0,   0, 75), 5,  "BLUEK", 30);
	
	static public const CYGNUS2:EnemyEnum =   new PlaneEnemyEnum(new ActorAttrs( 400, 6,   0.25, 0.05,0,125), 16, "CYGNUS2", 100);
	
	// tier level 14 -> final
	static public const OSPREY2:EnemyEnum =   new PlaneEnemyEnum(new ActorAttrs( 400, 1.5, 0.15, 0.05,0,100), 10, "OSPREY2", 100);
	static public const ROCINANTE2:EnemyEnum =new PlaneEnemyEnum(new ActorAttrs( 600, 3,   0.25, 0.05,0,125), 29, "ROCINANTE2", 125);
	static public const BAT3:EnemyEnum =      new PlaneEnemyEnum(new ActorAttrs( 600, 2,   0.05, 0,   0, 20),  8, "BAT3", 125);
	static public const GHOST2:EnemyEnum =    new PlaneEnemyEnum(new ActorAttrs( 500, 3,   0.05, 0.1, 0, 50), 19, "GHOST2", 110);
	static public const PIKE:EnemyEnum =      new PlaneEnemyEnum(new ActorAttrs( 500, 2,   0.1,  0,   0, 100),32, "PIKE", 80);
	static public const CYGNUS3:EnemyEnum =   new PlaneEnemyEnum(new ActorAttrs( 800, 6,   0.25, 0.05,0,125), 17, "CYGNUS3", 150);
	
	// final tier cast
	static public const BEE3:EnemyEnum =      new PlaneEnemyEnum(new ActorAttrs( 500, 5,   0.05, 0,   0, 100), 2,  "BEE3", 400);
	static public const FLY3:EnemyEnum =      new PlaneEnemyEnum(new ActorAttrs(1000, 1.5, 0.1,  0,   0, 100), 14, "FLY3", 200);
	static public const ESOX:EnemyEnum =      new PlaneEnemyEnum(new ActorAttrs(1000, 2,   0.1,  0,   0, 100), 33, "ESOX", 400);
	static public const STEALTH:EnemyEnum =   new PlaneEnemyEnum(new ActorAttrs(1000, 4,   0.1,  0,   0, 150), 26, "STEALTH", 500);
	static public const GHOST3:EnemyEnum =    new PlaneEnemyEnum(new ActorAttrs(1000, 3,   0.05, 0.1, 0, 150), 20, "GHOST3", 400);
	static public const OSPREY3:EnemyEnum =   new PlaneEnemyEnum(new ActorAttrs(2000, 2,   1,    0,   0, 200), 11, "OSPREY3", 600);
	static public const OSPREY3_CLOAK:EnemyEnum = new PlaneEnemyEnum(new ActorAttrs(2000, 2,   1,    0,   0, 200), 11, "OSPREY3_C", 800);

	// weapons //////////////////////////////////////////////////////////
	static private const BEE_BULLETSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 20, 0, -10, 0, 1);
	static private const MOTH_BULLETSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 10, 0, -20, 0, 1);
	static private const OSPREY_LASERSOURCE:Array =
		[	new AmmoFireSource(AmmoType.LASER, 10, -35, -15),
			new AmmoFireSource(AmmoType.LASER, 10,  35, -15)];
	static private const BAT_ROCKETSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.ROCKET, 20, -20, -10, 0, 3),
			new AmmoFireSource(AmmoType.ROCKET, 20,  20, -10, 0, 3)];
	static private const GHOST_SOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 15, -10, -5),
			new AmmoFireSource(AmmoType.LASER, 15,  10, -5)];
	static private const CYGNUS_LASERSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 20, -25,  0, 0, 3),
			new AmmoFireSource(AmmoType.LASER, 20,  25,  0, 0, 3)];
	static private const ROCINANTE_FUSION:Array = 
		[	new AmmoFireSource(AmmoType.FUSION, 40, -25, 0, 0),
			new AmmoFireSource(AmmoType.FUSION, 40,  25, 0, 0)];
	// level 9
	static private const MOTH2_BULLETSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.BULLET, 40, 0, -20, 5, 2),
			new AmmoFireSource(AmmoType.BULLET, 40, 0, -20,-5, 2)];
	static private const BEE2_BULLETSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.BULLET, 20, -10, -15, 0, 1),
			new AmmoFireSource(AmmoType.BULLET, 20,  10, -15, 0, 1)];
	static private const BAT2_ROCKETSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.ROCKET, 40, -20, -10, 0, 3),
			new AmmoFireSource(AmmoType.ROCKET, 40, -15,  -5, 0, 3),
			new AmmoFireSource(AmmoType.ROCKET, 40,  20,   5, 0, 3),
			new AmmoFireSource(AmmoType.ROCKET, 40,  20, -10, 0, 3)];
	static private const BLUEK_FUSIONSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.FUSION, 66, 0, -15);
	static private const CYGNUS2_LASERSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 40, -25,  0, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 40,  25,  0, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 40, -19, -5, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 40,  19, -5, 0, 0)
		];
	// level 14 ///////////////////////////////////////////////////////////////////////////
	static private const OSPREY2_SOURCE:Array =
		[	new AmmoFireSource(AmmoType.LASER, 33, -37, -32, 0, 5),
			new AmmoFireSource(AmmoType.LASER, 33, -16, -32, 0, 5),
			new AmmoFireSource(AmmoType.LASER, 33,  16, -32, 0, 5),
			new AmmoFireSource(AmmoType.LASER, 33,  37, -32, 0, 5)];
	static private const ROCINANTE2_FUSION:Array = 
		[	new AmmoFireSource(AmmoType.FUSION, 55, -25, 0, 0),
			new AmmoFireSource(AmmoType.FUSION, 55,  25, 0, 0)];
	static private const BAT3_BULLETSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.BULLET, 50, -20, -10, 0, 3),
			new AmmoFireSource(AmmoType.BULLET, 50, -15,  -5, 0, 3),
			new AmmoFireSource(AmmoType.BULLET, 50,  20,   5, 0, 3),
			new AmmoFireSource(AmmoType.BULLET, 50,  20, -10, 0, 3)];
	static private const GHOST2_SOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 80, -10, -5, 0, 1),
			new AmmoFireSource(AmmoType.LASER, 80,  10, -5, 0, 1)];
	static private const PIKE_SOURCE:Array =
		[	new AmmoFireSource(AmmoType.LASER, 10, -30, 10, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 20, -20, 0, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 20,  20, 0, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 10,  30, 10, 0, 0)];
	static private const CYGNUS3_SOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 20, -30, 5, 0, 3),
			new AmmoFireSource(AmmoType.LASER, 20, -24, 0, 0, 3),
			new AmmoFireSource(AmmoType.LASER, 20, -19, -5, 0, 3),
			new AmmoFireSource(AmmoType.LASER, 20,  19, -5, 0, 3),
			new AmmoFireSource(AmmoType.LASER, 20,  24, 0, 0, 3),
			new AmmoFireSource(AmmoType.LASER, 20,  30, 5, 0, 3)];
	// top tier
	static private const BEE3_BULLETSOURCE:Array =
		[	new AmmoFireSource(AmmoType.BULLET, 30, -15, 0, -10, 4), 
			new AmmoFireSource(AmmoType.BULLET, 30,  15, 0,  10, 4),
			new AmmoFireSource(AmmoType.BULLET, 30,   0, -10, 0, 4)]; 
	static private const FLY3_ROCKETSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.ROCKET, 100, 0, -15, 0, 0);
	static private const ESOX_SOURCE:Array =
		[	new AmmoFireSource(AmmoType.LASER, 10, -30, 10, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 20, -20, 0, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 30, -5, -10, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 30,  5, -10, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 20,  20, 0, 0, 0),
			new AmmoFireSource(AmmoType.LASER, 10,  30, 10, 0, 0)];
	static private const ESOX_SOURCE2:Array =
		[	new AmmoFireSource(AmmoType.LASER, 15, -30, 10, 0, 1),
			new AmmoFireSource(AmmoType.LASER, 30, -20, 0, 0, 1),
			new AmmoFireSource(AmmoType.LASER, 45, -5, -10, 0, 1),
			new AmmoFireSource(AmmoType.LASER, 45,  5, -10, 0, 1),
			new AmmoFireSource(AmmoType.LASER, 30,  20, 0, 0, 1),
			new AmmoFireSource(AmmoType.LASER, 15,  30, 10, 0, 1)];
	static private const STEALTH_SOURCE:Array =
		[	new AmmoFireSource(AmmoType.ROCKET, 150, -30, -10, 0, 0),
			new AmmoFireSource(AmmoType.ROCKET, 150,  30, -10, 0, 0),
			new AmmoFireSource(AmmoType.ROCKET, 150, -15, -20, 0, 0),
			new AmmoFireSource(AmmoType.ROCKET, 150,  15, -20, 0, 0)];
	static private const GHOST3_SOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 120, -10, -5),
			new AmmoFireSource(AmmoType.LASER, 120,  10, -5)];
	static private const OSPREY3_SOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 40, -63, -35, 0, 4),
			new AmmoFireSource(AmmoType.LASER, 40, -43, -35, 0, 4),
			new AmmoFireSource(AmmoType.LASER, 40, -23, -35, 0, 4),
			new AmmoFireSource(AmmoType.LASER, 40,  23, -35, 0, 4),
			new AmmoFireSource(AmmoType.LASER, 40,  43, -35, 0, 4),
			new AmmoFireSource(AmmoType.LASER, 40,  63, -35, 0, 4)];
	
	public function PlaneEnemyEnum(attrs:ActorAttrs, assetIndex:uint, name:String, value:uint = 5)
	{
		super(attrs, assetIndex, name, value);
	}
	protected override function create_impl():Actor
	{
		var a:Actor = new Actor(ActorAssetManager.createShip(assetIndex), attrs);
		var tmp:IBehavior;
		switch (this) {  
		//KAI: omg i've never seen anything like this, lol, alternative to creating classes
		// how about anonymous functions instead?
		case BEE:
			a.behavior = attackAndFlee(BEE_BULLETSOURCE, 3000, 1000, 1000);
			break;
		case GREENK:
			a.behavior = HOME;
			break;
		case MOTH:
			a.behavior = attackAndFlee(MOTH_BULLETSOURCE, 5000);
			break;
		case OSPREY:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(OSPREY_LASERSOURCE, 1000, 3000),
				new AlternatingBehavior( 
					1500,4500,
					HOME,
					BehaviorFactory.strafe
				)
			);
			break;
		case BAT:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(BAT_ROCKETSOURCE[0], 2000, 4000),
				BehaviorFactory.createAutofire(BAT_ROCKETSOURCE[1], 2000, 4000),
				new AlternatingBehavior( 
					1500, 4500,
					HOME,
					BehaviorFactory.strafe)
			);
			break;
		case GREENK2:
			a.behavior = HOME;
			break;
		case GHOST:
			a.behavior = new AlternatingBehavior( 
				1500, 4500,
				HOME,
				BehaviorFactory.strafe,
				new CompositeBehavior(BehaviorFactory.facePlayer, BehaviorFactory.speedDecay,
					BehaviorFactory.createAutofire(GHOST_SOURCE, 1000, 1000))
			);
			break;
		case CYGNUS:
			a.behavior = new AlternatingBehavior(
				2000, 6000,
				new CompositeBehavior(
					BehaviorFactory.createAutofire(CYGNUS_LASERSOURCE, 500, 500),
					new AlternatingBehavior(1000,3000, BehaviorFactory.turret, BehaviorFactory.strafe)),
				BehaviorFactory.facePlayer
			);
			break;
		case ROCINANTE:
			a.behavior = new AlternatingBehavior(
				1000, 3000,
				FLEE,
				new CompositeBehavior(
					HOME,
					BehaviorFactory.createAutofire(ROCINANTE_FUSION, 1000, 4000))
			);
			break;
		
		////////// level 9 ///////////////////////////////
		case FLY:
			a.behavior = HOME;
			break;
		case MOTH2:
			a.behavior = attackAndFlee(MOTH2_BULLETSOURCE, 2000);
			break;
		case BLUEK:
			a.behavior = new CompositeBehavior(HOME, BehaviorFactory.createAutofire(BLUEK_FUSIONSOURCE, 1000, 10000));
			break;
		case BAT2:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(BAT2_ROCKETSOURCE[0], 2000, 4000),
				BehaviorFactory.createAutofire(BAT2_ROCKETSOURCE[1], 2000, 4000),
				BehaviorFactory.createAutofire(BAT2_ROCKETSOURCE[2], 2000, 4000),
				BehaviorFactory.createAutofire(BAT2_ROCKETSOURCE[3], 2000, 4000),
				new AlternatingBehavior( 
					1500, 4500,
					HOME,
					BehaviorFactory.turret,
					BehaviorFactory.strafe,
					BehaviorFactory.gravityPush
				)
			);
			break;
		case BEE2:
			a.behavior = new AlternatingBehavior(
				1500, 4500,
				HOME,
				new CompositeBehavior(BehaviorFactory.createAutofire(BEE2_BULLETSOURCE, 1000, 1000), BehaviorFactory.facePlayer, BehaviorFactory.speedDecay),
				FLEE
			);
			break;
		case CYGNUS2:
			a.behavior = new AlternatingBehavior(
				2000, 6000,
				new CompositeBehavior(
					BehaviorFactory.createAutofire(CYGNUS2_LASERSOURCE, 750, 750),
					new AlternatingBehavior(1000,3000, BehaviorFactory.turret, BehaviorFactory.strafe)),
				FLEE
			);
			break;
		///////////// level 14 //////////////////////
		case OSPREY2:
			tmp = BehaviorFactory.createAutofire(OSPREY2_SOURCE, 1000, 1000);
			a.behavior = new CompositeBehavior(
				BehaviorFactory.facePlayer,
				new AlternatingBehavior(
					1000,1500,
					new CompositeBehavior(BehaviorFactory.speedDecay, tmp),
					HOME
				)
			);
			break;
		case ROCINANTE2:
			a.behavior = new AlternatingBehavior(
				1000, 3000,
				FLEE,
				new CompositeBehavior(
					BehaviorFactory.strafe,
					BehaviorFactory.createAutofire(ROCINANTE_FUSION, 1000, 4000))
			);
			break;
		case BAT3:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(BAT3_BULLETSOURCE[0], 2000, 4000),
				BehaviorFactory.createAutofire(BAT3_BULLETSOURCE[1], 2000, 4000),
				BehaviorFactory.createAutofire(BAT3_BULLETSOURCE[2], 2000, 4000),
				BehaviorFactory.createAutofire(BAT3_BULLETSOURCE[3], 2000, 4000),
				new AlternatingBehavior( 
					1500, 4500,
					HOME,
					BehaviorFactory.turret,
					BehaviorFactory.strafe,
					BehaviorFactory.gravityPush
				)
			);
			break;
		case GHOST2:
			a.behavior = new CompositeBehavior( 
				BehaviorFactory.strafe,
				BehaviorFactory.createAutofire(GHOST2_SOURCE, 1000, 4000)
			);
			break;
		case PIKE:
			a.behavior = new CompositeBehavior( 
				new AlternatingBehavior(
					1000, 2500,
					HOME,
					HOME,
					HOME,
					BehaviorFactory.turret
				),
				BehaviorFactory.createAutofire(PIKE_SOURCE, 1000, 15000)
			)
			break;
		case CYGNUS3:
			a.behavior = new AlternatingBehavior(
				2000, 6000,
				new CompositeBehavior(
					BehaviorFactory.createAutofire(CYGNUS3_SOURCE, 750, 750),
					new AlternatingBehavior(1000,3000, BehaviorFactory.turret, BehaviorFactory.strafe)),
				FLEE
			);
			break;
		///////////// final tier ////////////////////
		case BEE3:
			a.behavior = attackAndFlee(BEE3_BULLETSOURCE, 3000, 1000, 1000);
			break;
		case FLY3:
			a.behavior = new CompositeBehavior(HOME, BehaviorFactory.createAutofire(FLY3_ROCKETSOURCE, 5000, 10000));
			break;
		case ESOX:
			a.behavior = new AlternatingBehavior(
				1000, 8000,
				new CompositeBehavior(HOME, BehaviorFactory.createAutofire((Math.random() > .5) ? ESOX_SOURCE : ESOX_SOURCE2, 500, 10000)),
				FLEEFACING
			);
			break;
		case STEALTH:
			a.behavior = new AlternatingBehavior(
				1000, 8000,
				new CompositeBehavior(BehaviorFactory.fadeIn, BehaviorFactory.strafe,
					new AlternatingBehavior(1000, 1000, 
						BehaviorFactory.createAutofire(STEALTH_SOURCE[0], 1000, 1000),
						BehaviorFactory.createAutofire(STEALTH_SOURCE[1], 1000, 1000),
						BehaviorFactory.createAutofire(STEALTH_SOURCE[2], 1000, 1000),
						BehaviorFactory.createAutofire(STEALTH_SOURCE[3], 1000, 1000))
				),
				new CompositeBehavior(BehaviorFactory.fade, FLEEFACING)
			);
			break;
		case GHOST3:
			a.behavior = new AlternatingBehavior( 
				1500, 4500,
				HOME,
				BehaviorFactory.strafe,
				new CompositeBehavior(BehaviorFactory.facePlayer, BehaviorFactory.speedDecay,
					BehaviorFactory.createAutofire(GHOST3_SOURCE, 1000, 1000))
			);
			break;
		case OSPREY3:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(OSPREY3_SOURCE, 1000, 2000),
				new AlternatingBehavior( 
					1500,4500,
					BehaviorFactory.strafe,
					BehaviorFactory.facePlayer
				)
			);
			break;
		case OSPREY3_CLOAK:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(OSPREY3_SOURCE, 1000, 4000),
				BehaviorFactory.fade,
				new AlternatingBehavior( 
					1000, 6000,
					BehaviorFactory.strafe,
					BehaviorFactory.facePlayer,
					new CompositeBehavior(BehaviorFactory.fade, FLEEFACING)
				)
			);
			break;
		}
		return a;
	}
}

final class RotateToBehavior implements IBehavior, ICompletable
{
	private var _speed:Number = 1;
	private var _point:Point;
	private var _complete:Boolean;
	public function set point(p:Point):void
	{
		_point = p;
		_complete = false;
	}
	public function set speed(s:Number):void
	{
		_speed = s;
	}
	public function get complete():Boolean
	{
		return _complete;
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		const diff:Number = Utils.getRotationDiff(actor.worldPos, actor.displayObject.rotation, _point); 
		if (diff > 0.01)
		{
			actor.displayObject.rotation += _speed; 
		}
		else if (diff < -0.01)
		{
			actor.displayObject.rotation -= _speed; 
		}
		else
		{
			_complete = true;
		}
	}
}
final class HomeBehavior implements IBehavior, ICompletable
{
	private var _pointDirty:Boolean = true;
	private var _point:Point;
	private var _complete:Boolean;
	public function set point(p:Point):void
	{
		_point = p;
		_pointDirty = true;
		_complete = false;
	}
	public function get complete():Boolean
	{
		return _complete;
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (_pointDirty)
		{
			const radians:Number = MathUtil.getRadiansBetweenPoints(actor.worldPos, _point);
			actor.speed.x = -Math.sin(radians) * actor.attrs.MAX_SPEED;
			actor.speed.y = Math.cos(radians) * actor.attrs.MAX_SPEED;
			
			_pointDirty = false;  // not quite right - this needs to be set to true if *any* of the relevant data changes, actor worldpos, etc

			BehaviorFactory.faceForward.onFrame(game, actor);
		}
		if (MathUtil.distanceBetweenPoints(actor.worldPos, _point) < 10)
		{
			actor.speed.x = 0;
			actor.speed.y = 0;
			_complete = true;
		}
	}	
}
final class TankPatrolBehavior implements IBehavior
{
	private var _weapon:IBehavior;
	public function TankPatrolBehavior(weapon:IBehavior):void
	{
		_weapon = weapon;
	}
	private var _state:uint = 0;
	private var _destination:Point;
	private var _last:uint = 0;
	
	private var _rotateTo:RotateToBehavior = new RotateToBehavior;
	private var _home:HomeBehavior = new HomeBehavior;
	private function pickNew(bounds:Bounds):void
	{
		_destination.x = MathUtil.random(bounds.left, bounds.right);
		_destination.y = MathUtil.random(bounds.top, bounds.bottom);
		_rotateTo.point = _destination;
		_home.point = _destination;
	}
	static private const FIRE_DURATION_MAX:uint = 2000;
	static private const WAIT_DURATION_MAX:uint = 5000;
	private var _burstLimiter:RateLimiter = new RateLimiter(1000, FIRE_DURATION_MAX);
	private var _firing:Boolean = false;
	public function onFrame(game:IGame, actor:Actor):void
	{
		//////////////////////////
		// 1. patrol
		if (!_destination)
		{
			_destination = new Point;
			_rotateTo.speed = 0.5;

			pickNew(game.worldBounds);
			
			// immediately face player
			BehaviorFactory.facePlayer.onFrame(game, actor);
		}
		if (!_rotateTo.complete)
		{
			_rotateTo.onFrame(game, actor);
		}
		else if (!_home.complete)
		{
			_home.onFrame(game, actor);
		}
		else
		{
			pickNew(game.worldBounds);
		}

		///////////////////////////////
		// 2. Aim and fire
		//if (actor.health != actor.attrs.MAX_HEALTH) {actor.speed.x = 0; actor.speed.y = 0;}
		var tank:TankActor = actor as TankActor;
		if (tank)
		{
			const diff:Number = Utils.getRotationDiff(tank.worldPos, tank.turretRotation, game.player.worldPos);
			if (diff > 0.01)
			{
				tank.turretRotationRelativeToHull += 1; 
			}
			else if (diff < 0.01)
			{
				tank.turretRotationRelativeToHull -= 1; 
			}

			// this could really be a "burst" behavior.  We want to fire for a while,
			// then stop for a while
			if (!_firing && Math.abs(diff) < 0.1 && _burstLimiter.now)
			{
				_firing = true;

				_burstLimiter.maxRate = FIRE_DURATION_MAX;
				_burstLimiter.reset();
			}
			if (_firing)
			{
				_weapon.onFrame(game, actor);
				if (_burstLimiter.now)
				{
					_firing = false;

					_burstLimiter.maxRate = WAIT_DURATION_MAX;
					_burstLimiter.reset();
				}
			}
		}
	}
}

final class TankEnemyEnum extends EnemyEnum
{
	// first tier cast
	static public const TANK1:EnemyEnum =     new TankEnemyEnum(new ActorAttrs( 200, 1,   0.01, 0,   0,100), 0, "TANK1", 100);
	// second tier - level 6
	// next tier - level 9
	// tier level 14 -> final
	// final tier cast
	public function TankEnemyEnum(attrs:ActorAttrs, assetIndex:uint, name:String, value:uint = 5)
	{
		super(attrs, assetIndex, name, value);
	}
	protected override function create_impl():Actor
	{
		var retval:Actor;
		var vehicle:GameScriptPlayerVehicle;
		switch(this) {
		case TANK1:
			vehicle = GameScriptPlayerFactory.getTank(TankPartData.getHull(0), TankPartData.getTurret(0));
			retval = vehicle.actor;
			retval.behavior = new TankPatrolBehavior(vehicle.weapon);
			break;
		}
		retval.healthMeterEnabled = true; // because it's from the player factory - this needs refactoring
		return retval;
	}
}
final class Utils
{
	static public function placeAtRandomEdge(actor:Actor, bounds:Bounds):void
	{
		actor.worldPos.x = MathUtil.random(bounds.left, bounds.right);
		actor.worldPos.y = MathUtil.random(bounds.top, bounds.bottom);
		switch(int(Math.random() * 4)) {
			case 0:
				actor.worldPos.x = bounds.left - actor.attrs.BOUND_EXTENT.x;
				break;
			case 1:
				actor.worldPos.x = bounds.right + actor.attrs.BOUND_EXTENT.x;
				break;
			case 2:
				actor.worldPos.y = bounds.top - actor.attrs.BOUND_EXTENT.y;
				break;
			case 3:
				actor.worldPos.y = bounds.bottom + actor.attrs.BOUND_EXTENT.y;
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
	static public function getRotationDiff(from:Point, currentDegrees:Number, to:Point):Number
	{
		const radians:Number = MathUtil.degreesToRadians(currentDegrees); 
		const goalRadians:Number = MathUtil.getRadiansBetweenPoints(to, from);
		return MathUtil.diffRadians(radians, goalRadians);
	}
}

class BaseScript implements IGameScript
{
	// IGameScript
	private var TANK:Boolean;
	public function BaseScript(tank:Boolean):void
	{
		TANK = tank;

//		var planes:Array = [];
	}
	private var _weapon:IBehavior;
	public function begin(game:IGame):void 
	{
		var player:GameScriptPlayerVehicle = TANK ?
			GameScriptPlayerFactory.getPlayerTank() : GameScriptPlayerFactory.getPlayerPlane();

		_weapon = player.weapon;
		game.scoreBoard.showFusion = player.usingFusion;
		game.scoreBoard.showShield = player.usingShield;
		game.setPlayer(player.actor);
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
		super(true);
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
	public function WaveBasedGameScript(waves:Array, tank:Boolean)
	{
		super(tank);
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
		game.centerPrint("Begin!");

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
//	if (!isFriendly || isPlayer)
//	{
//		const particles:uint = Math.min(20, 3 + 10 * damage/actor.attrs.MAX_HEALTH);
//		Actor.createExplosionParticle(game, actor.worldPos, particles, isPlayer ? 0 : 1);
//	}
	public override function onOpposingCollision(game:IGame, friendly:Actor, enemy:Actor):void
	{
		const friendlyIsShield:Boolean = friendly is ShieldActor;
		if (friendlyIsShield)
		{
			// treat it like ammo
			damageActor(game, enemy, friendly.damage, false, false);
		}
		else
		{
			Util.ASSERT(friendly == game.player);
			
			// kill the enemy outright
			damageActor(game, enemy, 100000, false, true);
		}
		damageActor(game, friendly, enemy.damage, true, true);
	}
	public override function onFriendlyStruckByAmmo(game:IGame, friendly:Actor, ammo:Actor):void
	{
		damageActor(game, friendly, ammo.damage, true, false);
		if (friendly == game.player)
		{
			game.killActor(ammo);
			
			SmallExplosionActor.launch(game, ammo.worldPos, ammo.speed);
		}
		else if (friendly.alive)
		{
			// bounce - I think this only happens with shields (since it's the only friendly)
			ammo.speed.x = -ammo.speed.x;
			ammo.speed.y = -ammo.speed.y;
			
			game.convertToFriendlyAmmo(ammo);
			
			AssetManager.instance.laserBounceSound();
		}
	}
	public override function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void
	{
		var pa:IPenetratingAmmo = ammo as IPenetratingAmmo;
		if (pa)
		{
			if (!pa.isActorStruck(enemy))
			{
				Actor.createExplosionParticle(game, enemy.worldPos, 20, 0);

				pa.strikeActor(enemy);
				damageActor(game, enemy, ammo.damage, false, false);
			}
		}
		else
		{
			SmallExplosionActor.launch(game, ammo.worldPos, ammo.speed);
			
			damageActor(game, enemy, ammo.damage, false, false);
			game.killActor(ammo);
		}
	}

	static private const GLOW:Array = [ new GlowFilter(0x00ffff, 0.75, 25, 10) ];
	
	// this is a little nutty - seems like we should be using OOP or something
	public override function damageActor(game:IGame, actor:Actor, damage:Number, isFriendly:Boolean, wasCollision:Boolean):void
	{
		actor.health -= damage;
		if (actor.health > 0)
		{
			actor.registerHit(game, isPlayer);
		}

		// Maintain player damage and stats
		const isPlayer:Boolean = actor == game.player;
		if (isPlayer)
		{
			game.scoreBoard.pctHealth = actor.health / actor.attrs.MAX_HEALTH;
			_stats.damageReceived += damage;
//		trace("PLAYER HIT FOR", damage, "TO", actor.health, "/", actor.attrs.MAX_HEALTH); 
		}
		else
		{
//		trace("ENEMY HIT FOR", damage, "TO", actor.health, "/", actor.attrs.MAX_HEALTH); 
		}
			
		if (!isFriendly && !wasCollision)
		{
			_stats.damageDealt += damage;
		}

		if (wasCollision)
		{
			AssetManager.instance.collisionSound();
		}
		
		// handle actor death
		if (actor.health <= 0)
		{
			if (isPlayer)
			{
				actor.behavior = new DeathAnimationBehavior;
			}
			else if (actor is TankActor)
			{
				DeathAnimationBehavior.randomLargeExplosion(game, actor);
				DeathAnimationBehavior.randomLargeExplosion(game, actor);
				DeathAnimationBehavior.randomLargeExplosion(game, actor);
			}
			else
			{
				ExplosionActor.launch(game, actor.worldPos.x, actor.worldPos.y);
			}

			if (isPlayer && actor.alive)
			{
				game.stunMobs();

				_game.centerPrint("Level lost - you must try again.");
				
				_stats.end();
				_stats.victory = false;
				_waves.length = 0;
			}
			game.killActor(actor);

			if (!isFriendly)
			{
				AssetManager.instance.explosionSound();
				++_stats.enemiesKilled;

				_game.scoreBoard.pctLevel = _stats.enemiesKilled / _stats.enemiesTotal;
				if (!wasCollision)
				{
					const credits:uint = actor.attrs.VALUE * (1 + _stats.combo/10);

					_stats.creditsEarned += credits;
					++_stats.enemiesKilledCleanly;
					game.scoreBoard.earnings = _stats.creditsEarned;
					game.scoreBoard.combo = ++_stats.combo;
					_comboTimer.start(COMBO_LAPSE);
					
					BlingActor.launch(game, actor.worldPos.x, actor.worldPos.y, credits);
					
					if (Math.random() < Consts.SHIP_DROP_CHANCE)
					{
						var powerup:Actor = new Actor(AssetManager.instance.planeIcon(), new ActorAttrs(0, 10, 0, 0.05));
						powerup.displayObject.scaleX;
						powerup.displayObject.scaleY;
						powerup.displayObject.filters = GLOW;
						
						powerup.speed.x = actor.speed.x;
						powerup.speed.y = actor.speed.y;
						powerup.worldPos.x = actor.worldPos.x;
						powerup.worldPos.y = actor.worldPos.y;
						
						powerup.behavior = BehaviorFactory.createSpinDrift();
						
						game.addEffect(powerup);
					}
				}
				--_liveEnemies;
				if (!_liveEnemies)
				{
					if (_waves.length == 1)
					{
						_game.centerPrint("Final Wave");	
					}
					else if (_waves.length == 0)
					{
						_game.centerPrint("Level complete - you did it!");
						
						_stats.end();
						_stats.victory = true;
						_comboTimer.stop();
					}
					else
					{
						_waveDelay.start(500 + Math.random()*3000, 1);
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

// KAI: this is really a "spawner"-like activity.  randomLargeExplosion could be an argument
final class DeathAnimationBehavior implements IBehavior
{
	private var _limiter:RateLimiter = new RateLimiter(0, 300);
	private var _remaining:uint = 7;
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (_limiter.now && _remaining)
		{
			randomLargeExplosion(game, actor);
			--_remaining;
		}
	}
	public static function randomLargeExplosion(game:IGame, actor:Actor):void
	{
		ExplosionActor.launch(game, 
			actor.worldPos.x + ((Math.random() - 0.5) * actor.displayObject.width), 
			actor.worldPos.y + ((Math.random() - 0.5) * actor.displayObject.height));
	}
}

final class GrassTilesLevels
{
//	[Embed(source="assets/level1_small.txt", mimeType="application/octet-stream")]
	[Embed(source="assets/level2_small.txt", mimeType="application/octet-stream")]
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
	[Embed(source="assets/tanklevels.txt", mimeType="application/octet-stream")]
	static private const TankLevels:Class;
	static public function get tankLevels():String
	{
		return (new TankLevels).toString();
	}
}