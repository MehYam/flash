package gameData
{
	public class VehiclePartData
	{
		public var name:String;
		public var assetIndex:uint;
		public var baseStats:BaseStats;
		public var purchased:Boolean;

		public function VehiclePartData(name:String, assetIndex:uint, baseStats:BaseStats)
		{
			this.name = name;
			this.assetIndex = assetIndex;
			this.baseStats = baseStats;
			
			this.purchased = false;
		}
	}
}