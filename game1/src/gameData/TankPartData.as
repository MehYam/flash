package gameData
{
	public class TankPartData extends VehiclePartData
	{
		public function TankPartData(name:String, assetIndex:uint, baseStats:BaseStats)
		{
			super(name, assetIndex, baseStats);
		}
		
		static private var s_hulls:Array;
		static public function get hulls():Array
		{
			if (!s_hulls)
			{
				s_hulls =
				[
					new TankPartData("Hunter", 0,		new BaseStats(.1, 0, 0, .1, 1000)),
					new TankPartData("Hunter X", 1,		new BaseStats(.3, 0, 0, .1, 2000)),
					new TankPartData("Wreckingball", 2,	new BaseStats(.5, 0, 0, .2, 4000)),
					new TankPartData("Seeker", 3,		new BaseStats(.6, 0, 0, .3, 7000)),
					new TankPartData("Rhino", 4,		new BaseStats(.8, 0, 0, .2, 10000))
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
					new TankPartData("Stinger", 0, 		new BaseStats(0, .1, .1, 0, 1000)),
					new TankPartData("Spreader", 1,		new BaseStats(0, .3, .2, 0, 3000)),
					new TankPartData("Fuz-o", 2,		new BaseStats(0, .4, .1, 0, 5000)),
					new TankPartData("Destroyer", 3,	new BaseStats(0, .6, .1, 0, 4000)),
					new TankPartData("Trihorn", 4,		new BaseStats(0, .5, .1, 0, 6000))
				];
			}
			return s_turrets;
		}
	}
}