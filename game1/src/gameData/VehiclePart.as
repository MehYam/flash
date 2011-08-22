package gameData
{
	public class VehiclePart
	{
		public var id:String;

		public var name:String;
		public var subType:String;
		public var assetIndex:uint;
		public var baseStats:VehiclePartStats;
		public var description:String;
		public var unlockDescription:String;  // description of what this item unlocks
		public var level:uint;
		public var radius:Number;

		public function VehiclePart(id:String, name:String, assetIndex:uint, baseStats:VehiclePartStats)
		{
			this.id = id;
			this.name = name;
			this.assetIndex = assetIndex;
			this.baseStats = baseStats;
		}
	}
}