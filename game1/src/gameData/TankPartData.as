package gameData
{
	public class TankPartData extends VehiclePart
	{
		private var _upgrades:Array = [];
		public function TankPartData(name:String, assetIndex:uint, baseStats:VehiclePartStats, radius:Number = 0, upgradeA:TankPartData = null, upgradeB:TankPartData = null)
		{
			super(name, assetIndex, baseStats);
			_upgrades[0] = upgradeA;
			_upgrades[1] = upgradeB;
			this.radius = radius;
		}

		public function getUpgrade(index:uint):TankPartData
		{
			return _upgrades[index];
		}
		static private var s_hulls:Array;
		static public function get hulls():Array
		{
			if (!s_hulls)
			{
				s_hulls =
				[
					new TankPartData("Hunter", 0,		new VehiclePartStats(.1, 0, 0, .1, 1000), 38, 
						new TankPartData("+500 Armor",  0, new VehiclePartStats(.3, 0, 0, 0,  1000)),
						new TankPartData("Aft Cannons", 0, new VehiclePartStats( 0, .1, .1, 0, 1000))),
					new TankPartData("Wreckingball", 1,	new VehiclePartStats(.5, 0, 0, .2, 4000), 30,
						new TankPartData("+300 Armor",  0, new VehiclePartStats(.2, 0, 0, 0, 2000)),
						new TankPartData("+25% Speed",  0, new VehiclePartStats( 0, 0, 0, .3, 3000))),
					new TankPartData("Seeker", 2,		new VehiclePartStats(.6, 0, 0, .3, 7000), 30,
						new TankPartData("Adds Shield", 0, new VehiclePartStats(.2, .2, .1, 0, 5000)),
						new TankPartData("+25% Speed",  0, new VehiclePartStats(0, 0, 0, .2, 6000))),
					new TankPartData("Rhino", 3,		new VehiclePartStats(.8, 0, 0, .2, 20000),35,
						new TankPartData("+800 Armor",  0, new VehiclePartStats(.3, 0, 0, 0, 7000)),
						new TankPartData("Adds Shield", 0, new VehiclePartStats(.2, .2, .2, 0, 7000))),
					new TankPartData("Hunter X", 4,		new VehiclePartStats(.3, 0, 0, .1, 2000), 42,
						new TankPartData("+500 Armor",  0, new VehiclePartStats(.3, 0, 0, 0, 10000)),
						new TankPartData("Aft Cannons", 0, new VehiclePartStats( 0, .2, .2, 0, 10000)))
				];
			}
			return s_hulls;
		}
		static private var s_turrets:Array;
		static public function get turrets():Array
		{
			if (!s_turrets)
			{
				s_turrets =
				[
					new TankPartData("Stinger", 0, 		new VehiclePartStats(0, .1, .1, 0, 1000), 0,
						new TankPartData("+100% Firerate", 0, new VehiclePartStats(0, 0, .5, 0, 1000)),
						new TankPartData("+50% Damage", 0,    new VehiclePartStats(0, .1, 0, 0, 1000))),
					new TankPartData("Destroyer", 1,    new VehiclePartStats(0, .3, .2, 0, 3000), 0,
						new TankPartData("Spread Fire", 0,    new VehiclePartStats(0, 0, 0, 0, 2000)),
						new TankPartData("Rockets", 0,        new VehiclePartStats(0, .4, .4, 0, 3000))),
					new TankPartData("Fuz-o", 2,		new VehiclePartStats(0, .4, .1, 0, 5000), 0,
						new TankPartData("Double Fusion", 0,  new VehiclePartStats(0, .3, 0, 0, 5000)),
						new TankPartData("+50% Firerate", 0,  new VehiclePartStats(0, 0, .3, 0, 5000))),
					new TankPartData("Spreader", 3,	    new VehiclePartStats(0, .6, .1, 0, 4000), 0,
						new TankPartData("+33% Firerate", 0,  new VehiclePartStats(0, 0, .3, 0, 7000)),
						new TankPartData("Rocket Upgrade", 0, new VehiclePartStats(0, .3, 0, 0, 7000))),
					new TankPartData("Triclops", 4,		new VehiclePartStats(0, .5, .1, 0, 20000), 0,
						new TankPartData("+33% Damage", 0,    new VehiclePartStats(0, .3, 0, 0, 8000)),
						new TankPartData("+25% Firerate", 0,  new VehiclePartStats(0, 0, .25, 0, 8000)))
				];
			}
			return s_turrets;
		}
		static public function getHull(index:uint):TankPartData { return s_hulls[ index ]; }
		static public function getTurret(index:uint):TankPartData { return s_turrets[ index ]; }
	}
}