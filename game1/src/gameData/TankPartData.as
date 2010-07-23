package gameData
{
	public class TankPartData extends VehiclePartData
	{
		static private const s_upgrades:Array = 
		[
			new TankPartData("Improved Firerate", 0, new BaseStats(0, 0, 0.2, 0, 2000)),
			new TankPartData("Improved Damage",   0, new BaseStats(0, 0.3, 0, 0, 4000)),
			new TankPartData("Speed Boost",       0, new BaseStats(0, 0, 0, 0.3, 5000)),
			new TankPartData("Adds Rockets",      0, new BaseStats(0, 0, 0, 0, 7000))
		];
		private var _upgrades:Array = [];
		public function TankPartData(name:String, assetIndex:uint, baseStats:BaseStats, upgradeA:uint = 0, upgradeB:uint = 0)
		{
			super(name, assetIndex, baseStats);
			_upgrades[0] = upgradeA;
			_upgrades[1] = upgradeB;
		}

		public function getUpgrade(index:uint):TankPartData
		{
			return s_upgrades[_upgrades[index]];
		}
		public function getUpgradeIndex(index:uint):uint
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
					new TankPartData("Hunter", 0,		new BaseStats(.1, 0, 0, .1, 1000), 0, 1),
					new TankPartData("Hunter X", 1,		new BaseStats(.3, 0, 0, .1, 2000), 1, 2),
					new TankPartData("Wreckingball", 2,	new BaseStats(.5, 0, 0, .2, 4000), 2, 3),
					new TankPartData("Seeker", 3,		new BaseStats(.6, 0, 0, .3, 7000), 0, 1),
					new TankPartData("Rhino", 4,		new BaseStats(.8, 0, 0, .2, 20000), 0, 1)
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
					new TankPartData("Stinger", 0, 		new BaseStats(0, .1, .1, 0, 1000), 0, 1),
					new TankPartData("Spreader", 1,		new BaseStats(0, .3, .2, 0, 3000), 0, 1),
					new TankPartData("Fuz-o", 2,		new BaseStats(0, .4, .1, 0, 5000), 2, 3),
					new TankPartData("Destroyer", 3,	new BaseStats(0, .6, .1, 0, 4000), 0, 3),
					new TankPartData("Trihorn", 4,		new BaseStats(0, .5, .1, 0, 20000), 3, 2)
				];
			}
			return s_turrets;
		}
		static public function getHull(index:uint):TankPartData { return s_hulls[ index ]; }
		static public function getTurret(index:uint):TankPartData { return s_turrets[ index ]; }
	}
}