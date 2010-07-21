package gameData
{
	final public class PlaneData extends VehiclePartData
	{
		public var upgrades:uint;
		
		public function PlaneData(name:String, index:uint, baseStats:BaseStats, upgrades:uint = 0)
		{
			super(name, index, baseStats);
			this.upgrades = upgrades;
		}
		static private var s_entries:Array;
		static public function getEntry(i:uint):PlaneData
		{
			return entries[i];
		}
		static public function get entries():Array
		{
			if (!s_entries)
			{
				s_entries = 
				[
				new PlaneData("Hornet", 0,	new BaseStats(0.2, 0.4, 0.3, 0.8, 1000), 2),
				new PlaneData(null, 1,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 2,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Jem", 3,		new BaseStats(0.2, 0, 0, 0.8, 2000), 2),
				new PlaneData(null, 4,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 5,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Yango", 6,	new BaseStats(0.3, 0.4, 0.3, 0.2, 3000), 2),
				new PlaneData(null, 7,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 8,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Osprey", 9,	new BaseStats(0.4, 0.4, 0.3, 0.8, 4000), 2),
				new PlaneData(null, 10, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 11, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Diptera", 12, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 5000), 2),
				new PlaneData(null, 13, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 14, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Cygnus X-1", 15, new BaseStats(0.3, 0.4, 0.3, 0.8, 6000), 2),
				new PlaneData(null, 16, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 17, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Ghost", 18, 		new BaseStats(0.6, 0.4, 0.3, 0.8, 7000), 2),
				new PlaneData(null, 19, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 20, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Attacus", 21, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 8000), 2),
				new PlaneData(null, 22, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 23, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("???", 24, 		new BaseStats(0.1, 0.4, 0.3, 0.8, 9000)),
				new PlaneData("Stealth", 25, 	new BaseStats(0.02, 0.4, 0.3, 0.8, 10000), 2),
				new PlaneData(null, 26, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 27, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Rocinante", 28, 	new BaseStats(0.2, 0.4, 0.3, 0.8, 11000), 2),
				new PlaneData(null, 29, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 30, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Esox", 31, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 12000), 2),
				new PlaneData(null, 32, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 33, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Corvid", 34, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 12000), 2),
				new PlaneData(null, 35, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData(null, 36, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000))
				];
			}
			return s_entries;
		}
	}
}