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
		static public function getPlane(i:uint):PlaneData
		{
			return planes[i];
		}
		static public function get planes():Array
		{
			if (!s_entries)
			{
				s_entries = 
				[
				new PlaneData("Bee", 0,	new BaseStats(0.2, 0.4, 0.3, 0.8, 1000), 2),
				new PlaneData("Wasp", 1,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Hornet", 2,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Jem", 3,		new BaseStats(0.2, 0, 0, 0.8, 2000), 2),
				new PlaneData("Jem II", 4,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Jem VSBL", 5,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Yango", 6,	new BaseStats(0.3, 0.4, 0.3, 0.2, 3000), 2),
				new PlaneData("Yango II", 7,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Yango III", 8,		new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Osprey", 9,	new BaseStats(0.4, 0.4, 0.3, 0.8, 4000), 2),
				new PlaneData("Osprey II", 10, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Osprey III", 11, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Diptera", 12, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 5000), 2),
				new PlaneData("Diptera X", 13, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Diptera XI", 14, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Cygnus X-1", 15, new BaseStats(0.3, 0.4, 0.3, 0.8, 6000), 2),
				new PlaneData("Cygnus X-2", 16, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Cygnus X-3", 17, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Ghost", 18, 		new BaseStats(0.6, 0.4, 0.3, 0.8, 7000), 2),
				new PlaneData("Phantom", 19, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Spectre", 20, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Attacus", 21, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 8000), 2),
				new PlaneData("Attacus 2", 22, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Attacus 3", 23, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("???", 24, 		new BaseStats(0.1, 0.4, 0.3, 0.8, 9000)),
				new PlaneData("XStealth", 25, 	new BaseStats(0.02, 0.4, 0.3, 0.8, 10000), 2),
				new PlaneData("YStealth", 26, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("ZStealth", 27, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Rocinante", 28, 	new BaseStats(0.2, 0.4, 0.3, 0.8, 11000), 2),
				new PlaneData("Rocinante I", 29, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Rocinante II", 30, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Esox", 31, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 12000), 2),
				new PlaneData("Pike", 32, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Musky", 33, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Corvid", 34, 	new BaseStats(0.5, 0.4, 0.3, 0.8, 12000), 2),
				new PlaneData("Corvid X", 35, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Death Bird", 36, new BaseStats(0.2, 0.4, 0.3, 0.8, 2000))
				];
			}
			return s_entries;
		}
	}
}