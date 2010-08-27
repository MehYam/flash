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
			return new WaveBasedGameScript(s_levels[i].slice());
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
import flash.geom.Point;
import flash.geom.Rectangle;

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
import scripts.IGameScript;
import scripts.IPenetratingAmmo;
import scripts.ShieldActor;
import scripts.TankActor;

final class EnemyEnum
{
	static public var LOOKUP:Object = {};
	public var attrs:ActorAttrs;
	public var assetIndex:uint;
	public var value:uint;
	public function EnemyEnum(attrs:ActorAttrs, assetIndex:uint, name:String, value:uint = 5)
	{
		this.attrs = attrs;
		this.assetIndex = assetIndex;
		this.attrs.RADIUS = PlaneData.getPlane(assetIndex).radius;
		this.attrs.VALUE = value;

		LOOKUP[name] = this;
	}
	
	static private const FLEE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward);
	static private const FLEEFACING:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.facePlayer);
	static private const GRAVITY:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward);
	static private const HOME:CompositeBehavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
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

	// first tier cast
	static public const BEE:EnemyEnum =       new EnemyEnum(new ActorAttrs(  40, 5,   0.05, 0,   0, 33), 0, "BEE", 5);
	static public const GREENK:EnemyEnum =    new EnemyEnum(new ActorAttrs(  20, 1.5, 0.1,  0,   0, 10), 3, "GREENK", 5);
	static public const MOTH:EnemyEnum =      new EnemyEnum(new ActorAttrs(  30, 3,   0.1,  0,   0, 15), 21, "MOTH", 10);
	static public const OSPREY:EnemyEnum =    new EnemyEnum(new ActorAttrs( 100, 1.5, 0.15, 0,   0, 33), 9, "OSPREY", 15);
	static public const BAT:EnemyEnum =       new EnemyEnum(new ActorAttrs( 100, 2,   0.05, 0,   0, 20), 6, "BAT", 15);

	// second tier - level 6
	static public const GHOST:EnemyEnum =     new EnemyEnum(new ActorAttrs(  65, 3,   0.05, 0.1, 0, 50), 18, "GHOST", 25);
	static public const GREENK2:EnemyEnum =   new EnemyEnum(new ActorAttrs(  80, 1.5, 0.1,  0,   0, 50),  4, "GREENK2", 15);
	static public const CYGNUS:EnemyEnum =    new EnemyEnum(new ActorAttrs( 125, 6,   0.25, 0.05,0, 66), 15, "CYGNUS", 30);
	static public const ROCINANTE:EnemyEnum = new EnemyEnum(new ActorAttrs( 180, 3,   0.25, 0.05,0, 66), 28, "ROCINANTE", 35);

	// next tier - level 9
	static public const BEE2:EnemyEnum =      new EnemyEnum(new ActorAttrs( 120, 5,   0.05, 0.02,0, 50), 1,  "BEE2", 50);
	static public const FLY:EnemyEnum =       new EnemyEnum(new ActorAttrs( 180, 1.5, 0.2,  0,   0,100), 12, "FLY", 20); 
	static public const MOTH2:EnemyEnum =     new EnemyEnum(new ActorAttrs( 180, 4,   0.1,  0,   0, 66), 22, "MOTH2", 45);
	static public const BAT2:EnemyEnum =      new EnemyEnum(new ActorAttrs( 300, 2,   0.05, 0,   0, 20), 7,  "BAT2", 65);
	static public const BLUEK:EnemyEnum =     new EnemyEnum(new ActorAttrs( 250, 1.5, 0.1,  0,   0,100), 5,  "BLUEK", 30);

	static public const CYGNUS2:EnemyEnum =   new EnemyEnum(new ActorAttrs( 400, 6,   0.25, 0.05,0,125), 16, "CYGNUS2", 100);

	// third tier
	// final tier cast
	static public const BEE3:EnemyEnum =      new EnemyEnum(new ActorAttrs( 500, 5,   0.05, 0,   0, 100), 2,  "BEE3");
	static public const FLY3:EnemyEnum =      new EnemyEnum(new ActorAttrs(1000, 1.5, 0.1,  0,   0, 100), 14, "FLY3");
	static public const ESOX:EnemyEnum =      new EnemyEnum(new ActorAttrs(1000, 2,   0.1,  0,   0, 100), 33, "ESOX");
	static public const STEALTH:EnemyEnum =   new EnemyEnum(new ActorAttrs(1000, 4,   0.1,  0,   0, 150), 26, "STEALTH");
	static public const GHOST3:EnemyEnum =    new EnemyEnum(new ActorAttrs(1000, 3,   0.05, 0.1, 0, 150), 20, "GHOST3");
	static public const OSPREY3:EnemyEnum =   new EnemyEnum(new ActorAttrs(2000, 2,   1,    0,   0, 200), 11, "OSPREY3");
	static public const OSPREY3_CLOAK:EnemyEnum 
											= new EnemyEnum(new ActorAttrs(2000, 2,   1,    0,   0, 200), 11, "OSPREY3_CLOAK");
//	static public const GREENK2:EnemyEnum; // pure heavy homer

	// enemy weapons //////////////////////////////////////////////////////////
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
	public function create():Actor
	{
		var a:Actor = new Actor(ActorAssetManager.createShip(assetIndex), attrs);
		switch (this) {  
			//KAI: omg i've never seen anything like this, lol, alternative to creating classes
			// how about a map of functors or function objects instead?
		case EnemyEnum.BEE:
			a.behavior = attackAndFlee(BEE_BULLETSOURCE, 3000, 1000, 1000);
			break;
		case EnemyEnum.GREENK:
			a.behavior = HOME;
			break;
		case EnemyEnum.MOTH:
			a.behavior = attackAndFlee(MOTH_BULLETSOURCE, 5000);
			break;
		case EnemyEnum.OSPREY:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(OSPREY_LASERSOURCE, 1000, 3000),
				new AlternatingBehavior( 
					1500,4500,
					HOME,
					BehaviorFactory.strafe
				)
			);
			break;
		case EnemyEnum.BAT:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(BAT_ROCKETSOURCE[0], 2000, 4000),
				BehaviorFactory.createAutofire(BAT_ROCKETSOURCE[1], 2000, 4000),
				new AlternatingBehavior( 
					1500, 4500,
					HOME,
					BehaviorFactory.strafe)
			);
			break;
		case EnemyEnum.GREENK2:
			a.behavior = HOME;
			break;
		case EnemyEnum.GHOST:
			a.behavior = new AlternatingBehavior( 
					1500, 4500,
					HOME,
					BehaviorFactory.strafe,
					new CompositeBehavior(BehaviorFactory.facePlayer, BehaviorFactory.speedDecay,
						                  BehaviorFactory.createAutofire(GHOST_SOURCE, 1000, 1000))
			);
			break;
		case EnemyEnum.CYGNUS:
			a.behavior = new AlternatingBehavior(
				2000, 6000,
				new CompositeBehavior(
					BehaviorFactory.createAutofire(CYGNUS_LASERSOURCE, 500, 500),
					new AlternatingBehavior(1000,3000, BehaviorFactory.turret, BehaviorFactory.strafe)),
				BehaviorFactory.facePlayer
			);
			break;
		case EnemyEnum.ROCINANTE:
			a.behavior = new AlternatingBehavior(
				1000, 3000,
				FLEE,
				new CompositeBehavior(
					HOME,
					BehaviorFactory.createAutofire(ROCINANTE_FUSION, 1000, 4000))
			);
			break;
		
		////////// level 9 ///////////////////////////////
		case EnemyEnum.FLY:
			a.behavior = HOME;
			break;
		case EnemyEnum.MOTH2:
			a.behavior = attackAndFlee(MOTH2_BULLETSOURCE, 2000);
			break;
		case EnemyEnum.BLUEK:
			a.behavior = new CompositeBehavior(HOME, BehaviorFactory.createAutofire(BLUEK_FUSIONSOURCE, 1000, 10000));
			break;
		case EnemyEnum.BAT2:
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
		case EnemyEnum.BEE2:
			a.behavior = new AlternatingBehavior(
				1500, 4500,
				HOME,
				new CompositeBehavior(BehaviorFactory.createAutofire(BEE2_BULLETSOURCE, 1000, 1000), BehaviorFactory.facePlayer, BehaviorFactory.speedDecay),
				FLEE
			);
			break;
		case EnemyEnum.CYGNUS2:
			a.behavior = new AlternatingBehavior(
				2000, 6000,
				new CompositeBehavior(
					BehaviorFactory.createAutofire(CYGNUS2_LASERSOURCE, 750, 750),
					new AlternatingBehavior(1000,3000, BehaviorFactory.turret, BehaviorFactory.strafe)),
				FLEE
			);
			break;
		///////////// final tier ////////////////////
		case EnemyEnum.BEE3:
			a.behavior = attackAndFlee(BEE3_BULLETSOURCE, 3000, 1000, 1000);
			break;
		case EnemyEnum.FLY3:
			a.behavior = new CompositeBehavior(HOME, BehaviorFactory.createAutofire(FLY3_ROCKETSOURCE, 5000, 10000));
			break;
		case EnemyEnum.ESOX:
			a.behavior = new AlternatingBehavior(
				1000, 8000,
				new CompositeBehavior(HOME, BehaviorFactory.createAutofire((Math.random() > .5) ? ESOX_SOURCE : ESOX_SOURCE2, 500, 10000)),
				FLEEFACING
			);
			break;
		case EnemyEnum.STEALTH:
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
		case EnemyEnum.GHOST3:
			a.behavior = new AlternatingBehavior( 
				1500, 4500,
				HOME,
				BehaviorFactory.strafe,
				new CompositeBehavior(BehaviorFactory.facePlayer, BehaviorFactory.speedDecay,
					BehaviorFactory.createAutofire(GHOST3_SOURCE, 1000, 1000))
			);
			break;
		case EnemyEnum.OSPREY3:
			a.behavior = new CompositeBehavior(
				BehaviorFactory.createAutofire(OSPREY3_SOURCE, 1000, 2000),
				new AlternatingBehavior( 
					1500,4500,
					BehaviorFactory.strafe,
					BehaviorFactory.facePlayer
				)
			);
			break;
		case EnemyEnum.OSPREY3_CLOAK:
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
final class Utils
{
	static private function createShieldActivator(shieldDamage:Number, shieldArmor:Number, yOffset:Number, lifetime:Number = 1400):IBehavior
	{
		return BehaviorFactory.createShieldActivator(
				new AmmoFireSource(AmmoType.SHIELD, shieldDamage, 0, yOffset, 0),
				new ActorAttrs(shieldArmor, 0, 0, 0.01, 50, 0, false, lifetime));
	}
	static public function getPlayerPlane(scoreBoard:ScoreBoard):PlayerVehicle
	{
		const asset:uint = PlaneData.getPlane(UserData.instance.currentPlane).assetIndex;

		var weapon:IBehavior;
		var attrs:ActorAttrs;

		switch (UserData.instance.currentPlane) {
		/// bottom tier/////////////////////////////////////////////////////////////////
		case 0:
			weapon = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.BULLET, 10, 0, -10), 400);
			attrs = new ActorAttrs(100, 4.5, 0.5, 0.2);
			break;
		case 1:
			weapon = BehaviorFactory.createAutofire(
				[new AmmoFireSource(AmmoType.BULLET, 10, -15, 0), new AmmoFireSource(AmmoType.BULLET, 10, 15, 0)], 
				400);
			attrs = new ActorAttrs(117, 5, 0.5, 0.1);
			break;
		case 2:
			weapon = BehaviorFactory.createAutofire(
				[	new AmmoFireSource(AmmoType.BULLET, 10, -15, 0), 
					new AmmoFireSource(AmmoType.BULLET, 10,  15, 0),
					new AmmoFireSource(AmmoType.BULLET, 10,   0, -10)], 
				400);
			attrs = new ActorAttrs(133, 5.5, 1, 0.1);
			break;
		
		case 3:
			weapon = createShieldActivator(10, 50, -10); 
			attrs = new ActorAttrs(200, 3, 1, 0.1);
			scoreBoard.showShield = true;
			break;
		case 4:
			weapon = createShieldActivator(20, 100, -10); 
			attrs = new ActorAttrs(250, 3.5, 0.7, 0.1);
			scoreBoard.showShield = true;
			break;
		case 5:
			weapon = new CompositeBehavior(
				createShieldActivator(30, 150, -10),
				BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.LASER, 3, -12, 0, 0, 1),
						new AmmoFireSource(AmmoType.LASER, 3,  12, 0, 0, 1),
						new AmmoFireSource(AmmoType.LASER, 1, -8, 5, -180, 0),
						new AmmoFireSource(AmmoType.LASER, 1,  8, 5, -180, 0)	], 
					1500, 1500)
			);	
			attrs = new ActorAttrs(300, 3.7, 0.7, 0.1);
			scoreBoard.showShield = true;
			break;
		
		case 6:
			weapon = new AlternatingBehavior(
				500, 1500,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20, -18, -30, 0, 0), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20,  18, -30, 0, 0), 1000)
			);
			attrs = new ActorAttrs(200, 4, 0.3, 0.1);
			break;
		case 7:
			weapon = new AlternatingBehavior(
				200, 600,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20, -18, -30, 0, 1), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20, -15, -25, 0, 1), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20,  15, -25, 0, 1), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20,  18, -30, 0, 1), 1000)
			);
			attrs = new ActorAttrs(225, 4.25, 0.3, 0.1);
			break;
		case 8:
			weapon = new AlternatingBehavior(
				250, 350,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 22, -18, -30, 0, 2), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 22, -15, -25, 0, 2), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 22,  15, -25, 0, 2), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 22,  18, -30, 0, 2), 1000)
			);
			attrs = new ActorAttrs(300, 4.25, 0.7, 0.2);
			break;
		
		// level 9 ///////////////////////////////////////////
		case 34:
			// desc: people outgrowing the Stingers but wanting the speed go this line etc
			// dps: 233
			weapon = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.BULLET, 35, 0, -15, 0, 0), 150);
			attrs = new ActorAttrs(400, 5.5, 0.7, 0.1);
			break;
		case 35:
			break;
		case 36:
			// dps: 600
			weapon = BehaviorFactory.createAutofire(
				[	new AmmoFireSource(AmmoType.BULLET, 66, -20, 0, 0, 5), 
					new AmmoFireSource(AmmoType.BULLET, 66,  20, 0, 0, 5),
					new AmmoFireSource(AmmoType.BULLET, 66,   0, -10, 0, 5)], 
				400);
			attrs = new ActorAttrs(700, 8, 1, 0.1);
			break;

		case 28:
			weapon = BehaviorFactory.createChargedFire(
				[	new AmmoFireSource(AmmoType.FUSION, 40, -22, 0, 0),
					new AmmoFireSource(AmmoType.FUSION, 40,  22, 0, 0)],
				5, 1000, 5);
			attrs = new ActorAttrs(450, 5.2, 1, 0.1);
			scoreBoard.showFusion = true;
			break;
		case 29:
			break;
		case 30:
			weapon = BehaviorFactory.createChargedFire(
				[	new AmmoFireSource(AmmoType.FUSION, 225, -22, 0, 0),
					new AmmoFireSource(AmmoType.FUSION, 225,  22, 0, 0)],
				5, 1000, 10);
			attrs = new ActorAttrs(900, 7, 1, 0.1);
			scoreBoard.showFusion = true;
			break;

		case 15:
			weapon = BehaviorFactory.createAutofire(
				[	new AmmoFireSource(AmmoType.LASER, 110, -24, 0, 0, 1),
					new AmmoFireSource(AmmoType.LASER, 110,  24, 0, 0, 1)],
				1000, 1000);
			attrs = new ActorAttrs(425, 5, 0.8, 0.1);
			break;
		case 16:
			break;
		case 17:
			weapon = BehaviorFactory.createAutofire(
				[	new AmmoFireSource(AmmoType.LASER, 100, -30, 5, 0, 4),
					new AmmoFireSource(AmmoType.LASER, 100, -24, 0, 0, 4),
					new AmmoFireSource(AmmoType.LASER, 100, -19, -5, 0, 4),
					new AmmoFireSource(AmmoType.LASER, 100,  19, -5, 0, 4),
					new AmmoFireSource(AmmoType.LASER, 100,  24, 0, 0, 4),
					new AmmoFireSource(AmmoType.LASER, 100,  30, 5, 0, 4)],
				1000, 1000);
			attrs = new ActorAttrs(800, 6, 1, 0.1);
			break;
		
		case 12:
			weapon = createShieldActivator(40, 225, -15);
			attrs = new ActorAttrs(1000, 3.5, 0.8, 0.5);
			scoreBoard.showShield = true;
			break;
		case 13:
			break;
		case 14:
			weapon = createShieldActivator(150, 750, -15);
			attrs = new ActorAttrs(4000, 3.5, 0.8, 0.5);
			scoreBoard.showShield = true;
			break;

		case 21:
			weapon = new CompositeBehavior(
				createShieldActivator(25, 150, -15),
				BehaviorFactory.createAutofire(
					[ new AmmoFireSource(AmmoType.BULLET, 20, -20, -20),
					  new AmmoFireSource(AmmoType.BULLET, 20,  20, -20)], 500)
			);
			attrs = new ActorAttrs(750, 4, 0.7, 0.1);
			scoreBoard.showShield = true;
			break;
		case 22:
			break;
		case 23:
			weapon = new CompositeBehavior(
				createShieldActivator(100, 300, -15),
				BehaviorFactory.createChargedFire(new AmmoFireSource(AmmoType.FUSION, 100, 0, -10, 0), 5, 1000, 5)
			);
			attrs = new ActorAttrs(3000, 4, 0.7, 0.1);
			scoreBoard.showShield = true;
			scoreBoard.showFusion = true;
			break;

		case 31:
			weapon = new CompositeBehavior(
				createShieldActivator(75, 350, -15),
				BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.LASER, 25, -20, 0, 0, 1),
						new AmmoFireSource(AmmoType.LASER, 25,  20, 0, 0, 1)],
					1000, 1000)
			);
			attrs = new ActorAttrs(750, 3.75, 0.6, 0.1);
			scoreBoard.showShield = true;
			break;
		case 32:
			break;
		case 33:
			weapon = new CompositeBehavior(
				createShieldActivator(250, 700, -15),
				BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.LASER, 33, -30, 10, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33, -20, 0, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33, -5, -10, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33,  5, -10, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33,  20, 0, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33,  30, 10, 0, 2)],
					1500, 1500)
			);
			attrs = new ActorAttrs(3000, 3.75, 0.6, 0.1);
			scoreBoard.showShield = true;
			break;

		case 9:
			weapon = BehaviorFactory.createAutofire(
				[	new AmmoFireSource(AmmoType.LASER, 70, -35, -15),
					new AmmoFireSource(AmmoType.LASER, 70,  35, -15)],
				500
			);
			attrs = new ActorAttrs(1000, 4, 0.2, 0.1);
			break;
		case 10:
			break;
		case 11:
			weapon = BehaviorFactory.createAutofire(
				[	new AmmoFireSource(AmmoType.LASER, 40, -63, -35, 0, 1),
					new AmmoFireSource(AmmoType.LASER, 40, -43, -35, 0, 1),
					new AmmoFireSource(AmmoType.LASER, 40, -23, -35, 0, 1),
					new AmmoFireSource(AmmoType.LASER, 40,  23, -35, 0, 1),
					new AmmoFireSource(AmmoType.LASER, 40,  43, -35, 0, 1),
					new AmmoFireSource(AmmoType.LASER, 40,  63, -35, 0, 1)],
				333
			);
			attrs = new ActorAttrs(3700, 4, 0.2, 0.1);
			break;

		case 25:
			weapon = new AlternatingBehavior(666, 666,
				new CompositeBehavior(
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 75, -35, -15, 0, 0), 700, 700),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 75,  35, -15, 0, 0), 700, 700)
				),
				new CompositeBehavior(
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 75,  20, -25, 0, 0), 700, 700),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 75, -20, -25, 0, 0), 700, 700)
				)
			);
			attrs = new ActorAttrs(1000, 3.5, 0.8, 0.1);
			break;
		case 26:
			break;
		case 27:
			weapon = new AlternatingBehavior(333, 333,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 150, -30, -10, 0, 3), 400, 400),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 150,  30, -10, 0, 2), 400, 400),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 150, -15, -20, 0, 2), 400, 400),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 150,  15, -20, 0, 3), 400, 400)
			);
			attrs = new ActorAttrs(4000, 3.5, 0.8, 0.1);
			break;

		case 18:
			weapon = new AlternatingBehavior(333, 333,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 50, -20, -15, 0, 1), 400, 400),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 50,  20, -15, 0, 1), 400, 400)
			);
			attrs = new ActorAttrs(600, 4.1, 0.4, 0.1);
			break;
		case 19:
			break;
		case 20:
			weapon = new AlternatingBehavior(333, 333,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 200, -20, -20, 0, 4), 400, 400),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 200,  20, -20, 0, 4), 400, 400)
			);
			attrs = new ActorAttrs(1500, 4.5, 0.4, 0.1);
			break;
		}
		attrs.RADIUS = PlaneData.getPlane(asset).radius;
		
		var plane:Actor = new Actor(ActorAssetManager.createShip(asset), attrs);
		plane.behavior = BehaviorFactory.faceForward;
		plane.healthMeterEnabled = false;
		
		return new PlayerVehicle(plane, weapon);
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
		game.scoreBoard.showFusion = false;
		game.scoreBoard.showShield = false;
		
		var player:PlayerVehicle;
		if (TANK)
		{
			player = Utils.getPlayerTank();
			_weapon = player.weapon;
			game.setPlayer(player.actor);
		}
		else
		{
			player = Utils.getPlayerPlane(game.scoreBoard);
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
		}
		else if (friendly.alive)
		{
			ammo.speed.x = -ammo.speed.x;
			ammo.speed.y = -ammo.speed.y;
			
			game.convertToFriendlyAmmo(ammo);
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
			const particles:uint = Math.min(20, 3 + 10 * damage/actor.attrs.MAX_HEALTH);
			Actor.createExplosion(game, actor.worldPos, particles, isPlayer ? 0 : 1);
		}

		actor.health -= damage;
		if (actor.health > 0)
		{
			actor.registerHit(game, isPlayer);
		}

		// Maintain player damage and stats
		if (isPlayer)
		{
			game.scoreBoard.pctHealth = actor.health / actor.attrs.MAX_HEALTH;
			_stats.damageReceived += damage;
		trace("PLAYER HIT FOR", damage, "TO", actor.health, "/", actor.attrs.MAX_HEALTH); 
		}
		else
		{
		trace("ENEMY HIT FOR", damage, "TO", actor.health, "/", actor.attrs.MAX_HEALTH); 
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
}