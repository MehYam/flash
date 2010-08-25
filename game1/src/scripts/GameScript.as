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

import scripts.IGameScript;
import scripts.IPenetratingAmmo;
import scripts.ShieldActor;
import scripts.TankActor;

final class EnemyEnum
{
	static public var LOOKUP:Object = {};
	public var attrs:ActorAttrs;
	public var assetIndex:uint;
	public function EnemyEnum(attrs:ActorAttrs, assetIndex:uint, name:String)
	{
		this.attrs = attrs;
		this.assetIndex = assetIndex;
		this.attrs.RADIUS = PlaneData.getPlane(assetIndex).radius;

		LOOKUP[name] = this;
	}
	
	static private const FLEE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward);
	static private const FLEEFACING:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.facePlayer);
	static private const CHASE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward);
	static private const HOME:CompositeBehavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
	static public function attackAndFlee(source:*, msRate:uint, msShootRateMin:uint = 300, msShootRateMax:uint = 2000):IBehavior
	{
		return new AlternatingBehavior
		(
			msRate/2, msRate*3/2,
			CHASE,
			new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.createAutofire(source, msShootRateMin, msShootRateMax)),
			FLEE
		);
	}

	// first tier cast
	static public const BEE:EnemyEnum =       new EnemyEnum(new ActorAttrs( 40, 5,   0.05, 0, 0, 33), 0, "BEE");
	static public const GREENK:EnemyEnum =    new EnemyEnum(new ActorAttrs( 20, 1.5, 0.1,  0, 0, 10), 3, "GREENK");
	static public const MOTH:EnemyEnum =      new EnemyEnum(new ActorAttrs( 30, 3,   0.1,  0, 0, 15), 23, "MOTH");
	static public const OSPREY:EnemyEnum =    new EnemyEnum(new ActorAttrs(100, 1.5, 0.15, 0, 0, 33), 9, "OSPREY");
	static public const BAT:EnemyEnum =       new EnemyEnum(new ActorAttrs(100, 2,   0.05, 0, 0, 20), 6, "BAT");

	// second tier
	static public const GHOST:EnemyEnum =     new EnemyEnum(new ActorAttrs( 50, 3,   0.05, 0.1, 0, 50), 18, "GHOST");
	static public const FLY:EnemyEnum =       new EnemyEnum(new ActorAttrs( 80, 1.5, 0.1,  0,   0, 50), 12, "FLY");
	static public const CYGNUS:EnemyEnum =    new EnemyEnum(new ActorAttrs(100, 6,   0.25, 0.05, 0, 100), 15, "CYGNUS");
	static public const ROCINANTE:EnemyEnum = new EnemyEnum(new ActorAttrs(200, 3,   0.25, 0.05, 0, 100), 28, "ROCINANTE");
// switch BLUEK with FLY - more of a progression.  Make it shoot infrequently
//	static public const BLUEK:EnemyEnum =       new EnemyEnum(new ActorAttrs( 80, 1.5, 0.1,  0,   20, 50), "FLY");
	// third tier
	// final tier cast
	static public const BEE3:EnemyEnum =      new EnemyEnum(new ActorAttrs(500, 5,  0.05, 0, 0, 100), 2, "BEE3");
	static public const FLY3:EnemyEnum =      new EnemyEnum(new ActorAttrs(1000, 1.5, 0.1, 0, 0, 100), 14, "FLY3");
	static public const ESOX:EnemyEnum =      new EnemyEnum(new ActorAttrs(1000, 2, 0.1, 0, 0, 100), 33, "ESOX");
	static public const STEALTH:EnemyEnum =   new EnemyEnum(new ActorAttrs(1000, 4, 0.1, 0, 0, 150), 26, "STEALTH");
	static public const GHOST3:EnemyEnum =    new EnemyEnum(new ActorAttrs(1000, 3, 0.05, 0.1, 0, 150), 20, "GHOST3");
	static public const OSPREY3:EnemyEnum =   new EnemyEnum(new ActorAttrs(2000, 2, 1, 0, 0, 200), 11, "OSPREY3");
	static public const OSPREY3_CLOAK:EnemyEnum 
											= new EnemyEnum(new ActorAttrs(2000, 2, 1, 0, 0, 200), 11, "OSPREY3_CLOAK");
//	static public const BLUEK:EnemyEnum; // pure heavy homer

	// enemy weapons //////////////////////////////////////////////////////////
	static private const BEE_BULLETSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 20, 0, -10, 0, 1);
	static private const MOTH_BULLETSOURCE:AmmoFireSource = new AmmoFireSource(AmmoType.BULLET, 10, 0, -20, 0, 4);
	static private const OSPREY_LASERSOURCE:Array =
		[	new AmmoFireSource(AmmoType.LASER, 10, -35, -15),
			new AmmoFireSource(AmmoType.LASER, 10,  35, -15)];
	static private const BAT_ROCKETSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.ROCKET, 20, -20, -10, 0, 3),
			new AmmoFireSource(AmmoType.ROCKET, 20,  20, -10, 0, 3)];
	static private const GHOST_SOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 20, -10, -5),
			new AmmoFireSource(AmmoType.LASER, 20,  10, -5)];
	static private const CYGNUS_LASERSOURCE:Array = 
		[	new AmmoFireSource(AmmoType.LASER, 30, -25,  0, 0, 3),
			new AmmoFireSource(AmmoType.LASER, 30,  25,  0, 0, 3)];
	static private const ROCINANTE_FUSION:Array = 
		[	new AmmoFireSource(AmmoType.FUSION, 30, -25, 0, 0),
			new AmmoFireSource(AmmoType.FUSION, 30,  25, 0, 0)];
	
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
		case EnemyEnum.FLY:
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
	static public function getPlayerPlane(scoreBoard:ScoreBoard):PlayerVehicle
	{
		const asset:uint = PlaneData.getPlane(UserData.instance.currentPlane).assetIndex;

		var weapon:IBehavior;
		var attrs:ActorAttrs;
		// this in order of the general progression of ships
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
			attrs = new ActorAttrs(100, 5, 0.5, 0.1);
			break;
		case 3:
			weapon = BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 10, 0, -10, 0, 0), 1000);
			attrs = new ActorAttrs(200, 3, 1, 0.1);
			scoreBoard.showShield = true;
			break;
		case 6:
			// desc: model has problems with its firing, occasionally stop firing to have more predictability
			weapon = new AlternatingBehavior(
				500, 1500,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20, -20, -10, 0, 3), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 20,  20, -10, 0, 3), 1000)
			);
			attrs = new ActorAttrs(200, 4, 0.3, 0.1);
			break;
		case 2:
			weapon = BehaviorFactory.createAutofire(
				[new AmmoFireSource(AmmoType.BULLET, 10, -15, 0), 
				 new AmmoFireSource(AmmoType.BULLET, 10,  15, 0),
				 new AmmoFireSource(AmmoType.BULLET, 10,   0, -10)], 
				400);
			attrs = new ActorAttrs(100, 5.5, 1, 0.1);
			break;
		case 4:
			weapon = BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 20, 0, -10, 0), 1000);
			attrs = new ActorAttrs(300, 3.5, 0.7, 0.1);
			scoreBoard.showShield = true;
			break;
		case 7:
			weapon = new AlternatingBehavior(
				200, 600,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15, -20, -10, 0, 3), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15, -15,  -5, 0, 3), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15,  20,   5, 0, 3), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15,  20, -10, 0, 3), 1000)
			);
			attrs = new ActorAttrs(225, 4.25, 0.3, 0.1);
			break;
		case 5:
			// desc: has shield + weak lasers
			weapon = new CompositeBehavior(
				BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 30, 0, -10), 1000),
				BehaviorFactory.createAutofire(
					[new AmmoFireSource(AmmoType.LASER, 5, -10, 0, 0, 1),
					new AmmoFireSource(AmmoType.LASER, 5,   10, 0, 0, 1)], 
					1500, 1500)
			);	
			attrs = new ActorAttrs(333, 3.7, 0.7, 0.1);
			scoreBoard.showShield = true;
			break;
		case 8:
			// desc: slightly more predictable firing
			weapon = new AlternatingBehavior(
				250, 350,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15, -20, -10, 0, 3), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15, -15,  -5, 0, 3), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15,  20,   5, 0, 3), 1000),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 15,  20, -10, 0, 3), 1000)
			);
			attrs = new ActorAttrs(250, 4.25, 0.7, 0.2);
			break;
		
		// second tier //////////////////////////////////////////////
		case 34:
			// desc: people outgrowing the Stingers but wanting the speed go this line etc
			weapon = BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.BULLET, 35, 0, -15, 0, 1), 300);
			attrs = new ActorAttrs(100, 5, 1, 0.1);
			break;
		case 28:
			break;
		case 15:
			break;
		case 12:
			break;
		case 21:
			break;
		case 31:
			break;
		case 9:
			break;
		case 25:
			break;
		case 18:
			break;
		
		/////// third tier ////////////////////////////////////////////////////////
		case 35:
			break;
		case 29:
			break;
		case 16:
			break;
		case 13:
			break;
		case 22:
			break;
		case 32:
			break;
		case 10:
			break;
		case 26:
			break;
		case 19:
			break;

		/////// Top Tier //////////////////////////////////////////////////////////
		case 36:
			weapon = BehaviorFactory.createAutofire(
				[	new AmmoFireSource(AmmoType.BULLET, 66, -20, 0), 
					new AmmoFireSource(AmmoType.BULLET, 66,  20, 0),
					new AmmoFireSource(AmmoType.BULLET, 66,   0, -10)], 
				400);
			attrs = new ActorAttrs(700, 8, 1, 0.1);
			break;
		case 30:
			weapon = BehaviorFactory.createChargedFire(
				[	new AmmoFireSource(AmmoType.FUSION, 225, -22, 0, 0),
					new AmmoFireSource(AmmoType.FUSION, 225,  22, 0, 0)],
				5, 1000, 1);
			attrs = new ActorAttrs(900, 7, 1, 0.1);
			scoreBoard.showFusion = true;
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
		case 14:
			weapon = BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 150, 0, -10, 0, 2), 1000);
			attrs = new ActorAttrs(4000, 3.5, 0.8, 1);
			scoreBoard.showShield = true;
			break;
		case 23:
			weapon = new CompositeBehavior(
				BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 100, 0, -10), 1000),
				BehaviorFactory.createChargedFire(new AmmoFireSource(AmmoType.FUSION, 100, 0, -10, 0), 5, 1000, 5)
			);
			attrs = new ActorAttrs(3000, 4, 0.1, 0.1);
			scoreBoard.showShield = true;
			scoreBoard.showFusion = true;
			break;
		case 33:
			weapon = new CompositeBehavior(
				BehaviorFactory.createShieldActivator(new AmmoFireSource(AmmoType.SHIELD, 100, 0, -10), 1000),
				BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.LASER, 33, -30, 10, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33, -20, 0, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33, -5, -10, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33,  5, -10, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33,  20, 0, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 33,  30, 10, 0, 2)],
					2000, 2000)
			);
			attrs = new ActorAttrs(3000, 3.75, 0.1, 0.1);
			scoreBoard.showShield = true;
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
		case 20:
			weapon = new AlternatingBehavior(333, 333,
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 200, -20, -20, 0, 4), 400, 400),
				BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 200,  20, -20, 0, 4), 400, 400)
			);
			attrs = new ActorAttrs(1500, 4.5, 0.4, 0.1);
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
		}
		attrs.RADIUS = PlaneData.getPlane(asset).radius;
		
		var plane:Actor = new Actor(ActorAssetManager.createShip(asset), attrs);
		plane.behavior = BehaviorFactory.faceForward;
		
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
			const particles:uint = Math.min(15, 10 * damage/actor.attrs.MAX_HEALTH);
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
		//trace("PLAYER HIT FOR", damage, "TO", actor.health); 
		}
		else
		{
		//trace("ENEMY HIT FOR", damage, "TO", actor.health); 
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
					_stats.creditsEarned += actor.value * (1 + _stats.combo/10);
					++_stats.enemiesKilledCleanly;
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