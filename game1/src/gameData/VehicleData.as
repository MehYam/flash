package gameData
{
	import karnold.utils.Util;

	public final class VehicleData
	{
		static private var s_instance:VehicleData;
		static public function get instance():VehicleData
		{
			if (!s_instance)
			{
				s_instance = new VehicleData(SINGLETON);
			}
			return s_instance;
		}

		[Embed(source="assets/vehicleparts.txt", mimeType="application/octet-stream")]
		static private const Parts:Class;
		public function VehicleData(lock:Class)
		{
			if (lock != SINGLETON) throw "SINGLETON";
			
			const content:String = (new Parts).toString();
			const tables:Object = Util.parseTables(content);
			PlaneData.init(tables.planes);
			TankPartData.init(tables.hulls, tables.turrets, tables.hullups, tables.turretups);
		}
	}
}
final internal class SINGLETON {}