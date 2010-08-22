package gameData
{
	public class VehiclePart
	{
		public var name:String;
		public var assetIndex:uint;
		public var baseStats:VehiclePartStats;
		public var purchased:Boolean;
		public var description:String;

		public function VehiclePart(name:String, assetIndex:uint, baseStats:VehiclePartStats)
		{
			this.name = name;
			this.assetIndex = assetIndex;
			this.baseStats = baseStats;
			
			this.purchased = false;
		}
	}
}