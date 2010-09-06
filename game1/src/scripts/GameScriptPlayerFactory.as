package scripts
{
	import behaviors.ActorAttrs;
	import behaviors.AlternatingBehavior;
	import behaviors.AmmoFireSource;
	import behaviors.AmmoType;
	import behaviors.BehaviorFactory;
	import behaviors.CompositeBehavior;
	import behaviors.IBehavior;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import gameData.PlaneData;
	import gameData.TankPartData;
	import gameData.UserData;

	public class GameScriptPlayerFactory
	{
		static private function createShieldActivator(shieldDamage:Number, shieldArmor:Number, yOffset:Number = 0, lifetime:Number = 1400):IBehavior
		{
			return ShieldActor.createActivator(
				new AmmoFireSource(AmmoType.SHIELD, shieldDamage, 0, yOffset, 0),
				new ActorAttrs(shieldArmor, 0, 0, 0.01, 45, 0, false, lifetime));
		}
		static public function getPlayerPlane():GameScriptPlayerVehicle
		{
			const asset:uint = PlaneData.getPlane(UserData.instance.currentPlane).assetIndex;
			
			var weapon:IBehavior;
			var attrs:ActorAttrs;
			
			var shield:Boolean;
			var fusion:Boolean;
			
			// Not ideal - this would be better if it were completely data driven, which could be done
			// with XML.  Note that we create the AmmoFireSources here instead of sharing them like we
			// do for enemies.  No biggy since we don't create a lot of these
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
				weapon = createShieldActivator(10, 50); 
				attrs = new ActorAttrs(200, 3, 1, 0.1);
				shield = true;
				break;
			case 4:
				weapon = createShieldActivator(20, 100); 
				attrs = new ActorAttrs(250, 3.5, 0.7, 0.1);
				shield = true;
				break;
			case 5:
				weapon = new CompositeBehavior(
					createShieldActivator(30, 150),
					BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.LASER, 3, -12, 0, 0, 1),
							new AmmoFireSource(AmmoType.LASER, 3,  12, 0, 0, 1),
							new AmmoFireSource(AmmoType.LASER, 1, -8, 5, -180, 0),
							new AmmoFireSource(AmmoType.LASER, 1,  8, 5, -180, 0)	], 
						1500, 1500)
				);	
				attrs = new ActorAttrs(300, 3.7, 0.7, 0.1);
				shield = true;
				break;
			
			case 6:
				weapon = new AlternatingBehavior(
					500, 1500,
					BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.ROCKET, 20, -18, -30, 0, 0), 
							new AmmoFireSource(AmmoType.ROCKET, 20,  18, -30, 0, 0)],
					1000)
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
				// dps: 400
				weapon = BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.BULLET, 50,  -20, 0, 0, 1),
						new AmmoFireSource(AmmoType.BULLET, 50,   20, 0, 0, 1)],
					250);
				attrs = new ActorAttrs(550, 6.5, 0.8, 0.1);
				break;
			case 36:
				// dps: 600
				weapon = BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.BULLET, 66, -20, 0, 0, 5), 
						new AmmoFireSource(AmmoType.BULLET, 66,  20, 0, 0, 5),
						new AmmoFireSource(AmmoType.BULLET, 66,   0, -10, 0, 5)], 
					333);
				attrs = new ActorAttrs(700, 8, 1, 0.1);
				break;
			
			case 28:
				weapon = BehaviorFactory.createChargedFire(
					[	new AmmoFireSource(AmmoType.FUSION, 40, -22, 0, 0),
						new AmmoFireSource(AmmoType.FUSION, 40,  22, 0, 0)],
					5, 1000, 5);
				attrs = new ActorAttrs(450, 5.2, 1, 0.1);
				fusion = true;
				break;
			case 29:
				weapon = BehaviorFactory.createChargedFire(
					[	new AmmoFireSource(AmmoType.FUSION, 130, -22, 0, 0),
						new AmmoFireSource(AmmoType.FUSION, 130,  22, 0, 0)],
					5, 1000, 5);
				attrs = new ActorAttrs(675, 6, 1, 0.1);
				fusion = true;
				break;
			case 30:
				weapon = BehaviorFactory.createChargedFire(
					[	new AmmoFireSource(AmmoType.FUSION, 225, -22, 0, 0),
						new AmmoFireSource(AmmoType.FUSION, 225,  22, 0, 0)],
					5, 1000, 10);
				attrs = new ActorAttrs(900, 7, 1, 0.1);
				fusion = true;
				break;
			
			case 15:
				weapon = BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.LASER, 110, -24, 0, 0, 1),
						new AmmoFireSource(AmmoType.LASER, 110,  24, 0, 0, 1)],
					1000, 1000);
				attrs = new ActorAttrs(425, 5, 0.8, 0.1);
				break;
			case 16:
				weapon = BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.LASER, 110, -24, 0, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 100, -19, -5, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 100,  19, -5, 0, 2),
						new AmmoFireSource(AmmoType.LASER, 110,  24, 0, 0, 2)],
					1000, 1000);
				attrs = new ActorAttrs(610, 5.5, 0.9, 0.1);
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
				weapon = createShieldActivator(40, 225);
				attrs = new ActorAttrs(1000, 3.5, 0.8, 0.5);
				shield = true;
				break;
			case 13:
				weapon = createShieldActivator(90, 500);
				attrs = new ActorAttrs(1000, 3.5, 0.8, 0.5);
				shield = true;
				break;
			case 14:
				weapon = createShieldActivator(150, 750);
				attrs = new ActorAttrs(4000, 3.5, 0.8, 0.5);
				shield = true;
				break;
			
			case 21:
				weapon = new CompositeBehavior(
					createShieldActivator(25, 150),
					BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.BULLET, 20, -20, -20),
							new AmmoFireSource(AmmoType.BULLET, 20,  20, -20)], 500)
				);
				attrs = new ActorAttrs(750, 4, 0.7, 0.1);
				shield = true;
				break;
			case 22:
				weapon = new CompositeBehavior(
					createShieldActivator(60, 250),
					BehaviorFactory.createAutofire(
						[   new AmmoFireSource(AmmoType.ROCKET, 40, -20, -25),
							new AmmoFireSource(AmmoType.ROCKET, 40,  20, -25)], 500)
				);
				attrs = new ActorAttrs(1400, 4, 0.7, 0.1);
				shield = true;
				break;
			case 23:
				weapon = new CompositeBehavior(
					createShieldActivator(100, 300),
					BehaviorFactory.createChargedFire(new AmmoFireSource(AmmoType.FUSION, 100, 0, -10, 0), 5, 1000, 5)
				);
				attrs = new ActorAttrs(3000, 4, 0.7, 0.1);
				shield = true;
				fusion = true;
				break;
			
			case 31:
				weapon = new CompositeBehavior(
					createShieldActivator(75, 350),
					BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.LASER, 25, -20, 0, 0, 1),
							new AmmoFireSource(AmmoType.LASER, 25,  20, 0, 0, 1)],
						1000, 1000)
				);
				attrs = new ActorAttrs(750, 3.75, 0.6, 0.1);
				shield = true;
				break;
			case 32:
				weapon = new CompositeBehavior(
					createShieldActivator(160, 500),
					BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.LASER, 33, -30, 10, 0, 2),
							new AmmoFireSource(AmmoType.LASER, 33, -20, 0, 0, 2),
							new AmmoFireSource(AmmoType.LASER, 33,  20, 0, 0, 2),
							new AmmoFireSource(AmmoType.LASER, 33,  30, 10, 0, 2)],
						1500, 1500)
				);
				attrs = new ActorAttrs(1800, 3.75, 0.6, 0.1);
				shield = true;
				break;
			case 33:
				weapon = new CompositeBehavior(
					createShieldActivator(250, 700),
					BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.LASER, 33, -30, 10, 0, 5),
							new AmmoFireSource(AmmoType.LASER, 33, -20, 0, 0, 5),
							new AmmoFireSource(AmmoType.LASER, 33, -5, -10, 0, 5),
							new AmmoFireSource(AmmoType.LASER, 33,  5, -10, 0, 5),
							new AmmoFireSource(AmmoType.LASER, 33,  20, 0, 0, 5),
							new AmmoFireSource(AmmoType.LASER, 33,  30, 10, 0, 5)],
						1500, 1500)
				);
				attrs = new ActorAttrs(3000, 3.75, 0.6, 0.1);
				shield = true;
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
				weapon = BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.LASER, 40, -37, -32, 0, 5),
						new AmmoFireSource(AmmoType.LASER, 40, -16, -32, 0, 5),
						new AmmoFireSource(AmmoType.LASER, 40,  16, -32, 0, 5),
						new AmmoFireSource(AmmoType.LASER, 40,  37, -32, 0, 5)],
					400
				);
				attrs = new ActorAttrs(2500, 4, 0.2, 0.1);
				break;
			case 11:
				weapon = BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.LASER, 40, -63, -35, 0, 5),
						new AmmoFireSource(AmmoType.LASER, 40, -43, -35, 0, 5),
						new AmmoFireSource(AmmoType.LASER, 40, -23, -35, 0, 5),
						new AmmoFireSource(AmmoType.LASER, 40,  23, -35, 0, 5),
						new AmmoFireSource(AmmoType.LASER, 40,  43, -35, 0, 5),
						new AmmoFireSource(AmmoType.LASER, 40,  63, -35, 0, 5)],
					333
				);
				attrs = new ActorAttrs(3700, 4.25, 0.2, 0.1);
				break;
			
			case 25:
				weapon = new AlternatingBehavior(666, 666,
					BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.ROCKET, 75, -35, -15, 0, 0),
							new AmmoFireSource(AmmoType.ROCKET, 75,  35, -15, 0, 0)],
						700, 700),
					BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.ROCKET, 75,  20, -25, 0, 0),
							new AmmoFireSource(AmmoType.ROCKET, 75, -20, -25, 0, 0)],
						700, 700)
				);
				attrs = new ActorAttrs(1000, 3.5, 0.8, 0.1);
				break;
			case 26:
				weapon = new AlternatingBehavior(333, 333,
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 100, -35, -15, 0, 0), 400, 400),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 100, -20, -25, 0, 0), 400, 400),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 100,  20, -25, 0, 0), 400, 400),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 100,  35, -15, 0, 0), 400, 400)
				);
				attrs = new ActorAttrs(2500, 3.5, 0.8, 0.1);
				break;
			case 27:
				weapon = new AlternatingBehavior(333, 333,
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 150, -30, -10, 0, 3), 400, 400),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 150,  30, -10, 0, 2), 400, 400),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 150, -15, -20, 0, 2), 400, 400),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, 150,  15, -20, 0, 3), 400, 400)
				);
				attrs = new ActorAttrs(4000, 3.5, 1, 0.1);
				break;
			
			case 18:
				weapon = new AlternatingBehavior(333, 333,
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 50, -20, -15, 0, 1), 400, 400),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 50,  20, -15, 0, 1), 400, 400)
				);
				attrs = new ActorAttrs(600, 4.1, 0.4, 0.1);
				break;
			case 19:
				weapon = new AlternatingBehavior(333, 333,
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 50, -20, -15, 0, 3), 400, 400),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 50,  20, -15, 0, 3), 400, 400)
				);
				attrs = new ActorAttrs(1050, 4.2, 0.5, 0.1);
				break;
			case 20:
				weapon = new CompositeBehavior(
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 200, 0, 40, 180, 4), 333, 333),
					new AlternatingBehavior(333, 333,
						BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 200, -20, -20, 0, 4), 400, 400),
						BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.LASER, 200,  20, -20, 0, 4), 400, 400)
					)
				);
				attrs = new ActorAttrs(1500, 4.5, 0.6, 0.1);
				break;
			}
			attrs.RADIUS = PlaneData.getPlane(asset).radius;
			
			var plane:Actor = new Actor(ActorAssetManager.createShip(asset), attrs);
			plane.behavior = BehaviorFactory.faceForward;
			plane.healthMeterEnabled = false;
			
			return new GameScriptPlayerVehicle(plane, weapon, shield, fusion);
		}
		static public function tankScale(x:Number):Number { return x*Consts.TANK_SCALE; }
		static public function getPlayerTank():GameScriptPlayerVehicle
		{
			var attrs:ActorAttrs;
			var hullWeapon:IBehavior;
			var upgrade:TankPartData;
			var source:*;
			var fireRate:Number;
			var damage:Number;
			var angle:Number;
			var turretWeapon:IBehavior;
			var showFusion:Boolean;
			var showShield:Boolean;
			
			const turret:TankPartData = TankPartData.getTurret(UserData.instance.currentTurret);
			switch (UserData.instance.currentTurret) {
			case 0:
				fireRate = 400;
				damage = 10;

				upgrade = turret.getUpgrade(0);
				if (upgrade.purchased)
				{
					fireRate *= .5;
				}
				upgrade = turret.getUpgrade(1);
				if (upgrade.purchased)
				{
					damage *= 1.5;	
				}
				source = new AmmoFireSource(AmmoType.CANNON, damage, 0, tankScale(-67), 0, 0, true);
				turretWeapon = BehaviorFactory.createAutofire(source, fireRate);
				// min dps 25, max dps 75
				break;
			case 1:
				fireRate = 666;
				damage = 26;
				upgrade = turret.getUpgrade(0);
				angle = upgrade.purchased ? 10 : 0;
				source = [	new AmmoFireSource(AmmoType.CANNON, damage, 0, tankScale(-55), 0, 0, true),
							new AmmoFireSource(AmmoType.CANNON, damage, tankScale(-15), tankScale(-20), -angle, 0, true),
							new AmmoFireSource(AmmoType.CANNON, damage, tankScale( 15), tankScale(-20),  angle, 0, true)];

				upgrade = turret.getUpgrade(1);
				if (upgrade.purchased)
				{
					turretWeapon = new CompositeBehavior(
									BehaviorFactory.createAutofire(source, fireRate),
									BehaviorFactory.createAutofire(
										[	new AmmoFireSource(AmmoType.ROCKET, damage*2, 0, tankScale(-55), 0, 0, true),
											new AmmoFireSource(AmmoType.ROCKET, damage*2, tankScale(-15), tankScale(-20), -angle - 5, 0, true),
											new AmmoFireSource(AmmoType.ROCKET, damage*2, tankScale( 15), tankScale(-20),  angle + 5, 0, true)],
										fireRate*2)
					);
				}
				else
				{
					turretWeapon = BehaviorFactory.createAutofire(source, fireRate);
				}
				// min dps 120, max dps 220
				break;
			case 2:
				// fusion starts at 100
				upgrade = turret.getUpgrade(0);
				if (upgrade.purchased)
				{
					source = [	new AmmoFireSource(AmmoType.FUSION, 60, 0, tankScale(-60), -2.5, 0, true),
								new AmmoFireSource(AmmoType.FUSION, 60, 0, tankScale(-60),  2.5, 0, true)];
				}
				else
				{
					source = new AmmoFireSource(AmmoType.FUSION, 50, 0, tankScale(-50), 0, 0, true);
				}
				upgrade = turret.getUpgrade(1);
				if (upgrade.purchased)
				{
					fireRate = 1000;
				}
				else
				{
					fireRate = 666;
				}
				turretWeapon = BehaviorFactory.createChargedFire(source, 5, fireRate, 40);
				showFusion = true;
				break;
			case 3:
				// dps - 300 -> 600
				damage = 100;
				fireRate = 1000;
				upgrade = turret.getUpgrade(0);
				if (upgrade.purchased)
				{
					fireRate = 750;
				}
				upgrade = turret.getUpgrade(1);
				var rocket:uint = 0; 
				if (upgrade.purchased)
				{
					damage = 150;
					rocket = 1;
				}
				turretWeapon = new AlternatingBehavior(fireRate/3 - 33, fireRate/3 + 33,
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, damage, tankScale(-10), tankScale(-80), -10, rocket, true), fireRate),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, damage, tankScale(  0), tankScale(-80),   0, rocket, true), fireRate),
					BehaviorFactory.createAutofire(new AmmoFireSource(AmmoType.ROCKET, damage, tankScale( 10), tankScale(-80),  10, rocket, true), fireRate)
				);
				break;
			case 4:
				// dps - 450 -> 600
				damage = 75;
				fireRate = 500;
				
				upgrade = turret.getUpgrade(0);
				var level:uint = 0;
				if (upgrade.purchased)
				{
					level = 1;
					damage = 100;
				}
				upgrade = turret.getUpgrade(0);
				if (upgrade.purchased)
				{
					fireRate = 400;
				}
				turretWeapon = BehaviorFactory.createAutofire(
					[	new AmmoFireSource(AmmoType.CANNON, damage, tankScale(-30), 0, -90, level, true),
						new AmmoFireSource(AmmoType.CANNON, damage, 0, tankScale(-30),   0, level, true),
						new AmmoFireSource(AmmoType.CANNON, damage, tankScale( 30), 0,  90, level, true)],
					fireRate
				);
				break;
			}

			const hull:TankPartData = TankPartData.getHull(UserData.instance.currentHull);
			switch(UserData.instance.currentHull) {
			case 0:
				attrs = new ActorAttrs(800, 1.5, 0.2, 0.2);
				
				upgrade = hull.getUpgrade(0);
				if (upgrade.purchased)
				{
					attrs.MAX_HEALTH = 1300;
				}
				upgrade = hull.getUpgrade(1);
				if (upgrade.purchased)
				{
					hullWeapon = BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.CANNON, 4, tankScale(-15), tankScale(40), 180, 0),
							new AmmoFireSource(AmmoType.CANNON, 4, tankScale( 15), tankScale(40), 180, 0)],
						333
					);
				}
				// armor 800-1300, speed 1.5, dps 24
				break;
			case 1:
				attrs = new ActorAttrs(1300, 2, 0.2, 0.2);
				upgrade = hull.getUpgrade(0);
				if (upgrade.purchased)
				{
					attrs.MAX_HEALTH = 1600;
				}
				upgrade = hull.getUpgrade(1);
				if (upgrade.purchased)
				{
					attrs.MAX_SPEED = 2.5;
				}
				// armor 1300-1600, speed 2-2.5
				break;
			case 2:
				attrs = new ActorAttrs(2000, 2.8, 0.5, 0.2);
				upgrade = hull.getUpgrade(0);
				if (upgrade.purchased)
				{
					hullWeapon = createShieldActivator(160, 500);
					showShield = true;
				}
				upgrade = hull.getUpgrade(1);
				if (upgrade.purchased)
				{
					attrs.MAX_SPEED = 3.3;
				}
				// armor 2000 + shield 500, speed 2.8-3.3
				break;
			case 3:
				attrs = new ActorAttrs(3000, 2.5, 0.5, 0.2);
				upgrade = hull.getUpgrade(0);
				if (upgrade.purchased)
				{
					attrs.MAX_HEALTH = 3800;
				}
				upgrade = hull.getUpgrade(1);
				if (upgrade.purchased)
				{
					hullWeapon = createShieldActivator(120, 500, -20);
					showShield = true;
				}
				// armor 3000-3800 + shield 500, speed 2.5
				break;
			case 4:
				attrs = new ActorAttrs(3800, 2.2, 0.5, 0.2);
				upgrade = hull.getUpgrade(0);
				if (upgrade.purchased)
				{
					attrs.MAX_HEALTH = 4300;
				}
				upgrade = hull.getUpgrade(1);
				if (upgrade.purchased)
				{
					hullWeapon = BehaviorFactory.createAutofire(
						[	new AmmoFireSource(AmmoType.BULLET, 15, tankScale(-15), tankScale(40), 180, 5),
							new AmmoFireSource(AmmoType.BULLET, 15, tankScale( 15), tankScale(40), 180, 5)],
						333
					);
				}
				// armor 3800-5000, speed 2.2
				break;
			}
			
			attrs.RADIUS = hull.radius * Consts.TANK_SCALE;

			var tank:Actor = TankActor.createTankActor(hull.assetIndex, turret.assetIndex, attrs);
			tank.behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.faceMouse);
			tank.healthMeterEnabled = false;

			return new GameScriptPlayerVehicle(tank, new CompositeBehavior(hullWeapon, turretWeapon), showShield, showFusion);
		}
	}
}