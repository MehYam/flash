package gameData
{
	import flash.utils.ByteArray;

	final public class PlaneData extends VehiclePart
	{
		public var upgrades:uint;
		public var purchasable:Boolean;
		public var unlock:uint = 0;  // index of PlaneData that unlocks this one

		public function PlaneData(name:String, aindex:uint, radius:Number, baseStats:VehiclePartStats, upgrades:uint = 0, purchasable:Boolean = true)
		{
			super("p" + aindex, name, aindex, baseStats);
			this.upgrades = upgrades;
			this.purchasable = purchasable;
			this.radius = radius;
		}
		static private var s_entries:Vector.<PlaneData>;
		static public function get planes():Vector.<PlaneData>
		{
			return s_entries;
		}
		//KAI: would be better to replace i with the VehiclePart.id
		static public function getPlane(i:uint):PlaneData
		{
			return planes[i];
		}

		[Embed(source="assets/planes.xml", mimeType="application/octet-stream")]
		static private const PLANEXML:Class;
		static private const CLASSNAMES:Array = ["Rogue", "Melee", "Melee/Hybrid", "Fighter"];
		static public function init(planes:Vector.<Object>):void
		{
			s_entries = new Vector.<PlaneData>; 
			for each (var plane:Object in planes)
			{
				var pd:PlaneData = new PlaneData(
					plane.name,
					plane.iAsset,
					plane.radius,
					new VehiclePartStats(
						plane.armor,
						plane.damage,
						plane.rate,
						plane.speed,
						plane.cost
					),
					plane.upgrades,
					!plane.nosale
				);
				pd.unlock = plane.unlock;
				pd.subType = CLASSNAMES[parseInt(plane["class"])];

				s_entries.push(pd);
			}

			var byteArray:ByteArray = new PLANEXML;
			const xml:XML = new XML(byteArray.readUTFBytes(byteArray.length));		
			for each (var desc:XML in xml.descs.children())
			{
				getPlane(desc.@plane).description = desc.text();
			}
		}
	}
}