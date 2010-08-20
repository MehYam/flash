package gameData
{
	public class TankPartData extends VehiclePart
	{
		static private function createUpgrade(i:uint):TankPartData
		{
			switch (i) {
			case 0:
				return new TankPartData("Improved Firerate", 0, new VehiclePartStats(0, 0, 0.2, 0, 2000));
			case 1:
				return new TankPartData("Improved Damage",   0, new VehiclePartStats(0, 0.3, 0, 0, 4000));
			case 2:
				return new TankPartData("Speed Boost",       0, new VehiclePartStats(0, 0, 0, 0.3, 5000));
			case 3:
				return new TankPartData("Adds Rockets",      0, new VehiclePartStats(0, 0, 0, 0, 7000));
			}
			return null;
		}
		private var _upgrades:Array = [];
		public function TankPartData(name:String, assetIndex:uint, baseStats:VehiclePartStats, upgradeA:int = -1, upgradeB:int = -1)
		{
			super(name, assetIndex, baseStats);
			if (upgradeA >= 0)
			{
				_upgrades[0] = createUpgrade(upgradeA);
			}
			if (upgradeB >= 0)
			{
				_upgrades[1] = createUpgrade(upgradeB);
			}
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
					new TankPartData("Hunter", 0,		new VehiclePartStats(.1, 0, 0, .1, 1000), 0, 1),
					new TankPartData("Hunter X", 1,		new VehiclePartStats(.3, 0, 0, .1, 2000), 1, 2),
					new TankPartData("Wreckingball", 2,	new VehiclePartStats(.5, 0, 0, .2, 4000), 2, 3),
					new TankPartData("Seeker", 3,		new VehiclePartStats(.6, 0, 0, .3, 7000), 0, 1),
					new TankPartData("Rhino", 4,		new VehiclePartStats(.8, 0, 0, .2, 20000), 0, 1)
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
					new TankPartData("Stinger", 0, 		new VehiclePartStats(0, .1, .1, 0, 1000), 0, 1),
					new TankPartData("Spreader", 1,		new VehiclePartStats(0, .3, .2, 0, 3000), 0, 1),
					new TankPartData("Fuz-o", 2,		new VehiclePartStats(0, .4, .1, 0, 5000), 2, 3),
					new TankPartData("Destroyer", 3,	new VehiclePartStats(0, .6, .1, 0, 4000), 0, 3),
					new TankPartData("Trihorn", 4,		new VehiclePartStats(0, .5, .1, 0, 20000), 3, 2)
				];
			}
			return s_turrets;
		}
		static public function getHull(index:uint):TankPartData { return s_hulls[ index ]; }
		static public function getTurret(index:uint):TankPartData { return s_turrets[ index ]; }
	}
}