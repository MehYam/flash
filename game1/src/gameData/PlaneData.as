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

		[Embed(source="assets/planes.xml", mimeType="application/octet-stream")] static private const PLANEXML:Class;
		static private const CLASSNAMES:Array = ["Rogue", "Melee", "Melee/Hybrid", "Fighter"];
		static public function init(planes:Vector.<Object>):void
		{
			s_entries = new Vector.<PlaneData>;

			var plane:Object;
			var max:Object = { armor: 0, damage: 0, rate: 0, speed: 0 };
			for each (plane in planes)
			{
				max.armor = Math.max(max.armor, plane.armor);
				max.damage = Math.max(max.damage, plane.damage);
				max.rate = Math.max(max.rate, 1000 / Math.max(1, plane.rate));
				max.speed = Math.max(max.speed, plane.speed);
			}
			for each (plane in planes)
			{
				var pd:PlaneData = new PlaneData(
					plane.name,
					plane.iAsset,
					plane.radius,
					new VehiclePartStats(
						plane.armor / max.armor,
						plane.damage / max.damage,
						1000 / Math.max(1, plane.rate) / max.rate,
						plane.speed / max.speed,
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
				var planePart:VehiclePart = getPlane(desc.@plane);
				planePart.description = desc.text();
				planePart.unlockDescription = desc.@unlockText;
			}
		}
	}
}