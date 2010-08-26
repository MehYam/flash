package gameData
{
	import flash.utils.ByteArray;

	final public class PlaneData extends VehiclePart
	{
		public var upgrades:uint;
		public var purchasable:Boolean;
		public var unlock:uint = 0;  // index of PlaneData that unlocks this one
		public var radius:Number;

		public function PlaneData(name:String, aindex:uint, radius:Number, baseStats:VehiclePartStats, upgrades:uint = 0, purchasable:Boolean = true)
		{
			super(name, aindex, baseStats);
			this.upgrades = upgrades;
			this.purchasable = purchasable;
			this.radius = radius;
		}
		static private var s_entries:Array;
		static public function getPlane(i:uint):PlaneData
		{
			return planes[i];
		}

		[Embed(source="assets/planes.xml", mimeType="application/octet-stream")]
		static private const PLANEXML:Class;

		static public function get planes():Array
		{
			if (!s_entries)
			{
				s_entries = []; 
				
				var byteArray:ByteArray = new PLANEXML;
				const xml:XML = new XML(byteArray.readUTFBytes(byteArray.length));		
				for each (var item:XML in xml.planes.children())
				{
					var pd:PlaneData =
						new PlaneData(
							item.@n,
							item.@a,
							item.@rad,
							new VehiclePartStats(
								item.@arm,
								item.@dmg,
								item.@rate,
								item.@speed,
								item.@cost
							),
							item.@up,
							item.@nosale != "true"
						);
					pd.unlock = item.@unl;
					s_entries.push(pd);
				}

				for each (var desc:XML in xml.descs.children())
				{
					getPlane(desc.@plane).description = desc.text();
				}
			}
			return s_entries;
		}
	}
}