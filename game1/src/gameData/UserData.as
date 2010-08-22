package gameData
{
	import karnold.utils.Util;

	public class UserData
	{
		public function UserData(s:SINGLETONLIMITER){if (!s) throw "THIS IS A SINGLETON";}
		
		static private var s_instance:UserData;
		static public function get instance():UserData
		{
			if (!s_instance)
			{
				s_instance = new UserData(new SINGLETONLIMITER);
				s_instance.currentPlane = 0;
		
				// priming
				PlaneData.planes;
				TankPartData.hulls;
				TankPartData.turrets;

				s_instance.purchasePart(PlaneData.getPlane(0), 0);
				s_instance.purchasePart(TankPartData.getHull(0), 0);
				s_instance.purchasePart(TankPartData.getTurret(0), 0);

				s_instance.currentPlane = 0;
				s_instance.currentHull = 0;
				s_instance.currentTurret = 0;
				
				// TEST DATA BELOW
//				s_instance.credits = 100000;
				s_instance.purchasePart(PlaneData.getPlane(1), 0);
//				s_instance.purchasePart(PlaneData.getPlane(3), 0);
//				s_instance.levelReached = 2;
//				s_instance.currentPlane = 3;
//				s_instance.purchasePart(PlaneData.getPlane(2), 0);
//				s_instance.purchasePart(PlaneData.getPlane(1), 0);
//				s_instance.purchasePart(PlaneData.getPlane(3), 0);
//				s_instance.purchasePart(PlaneData.getPlane(9), 0);
//				s_instance.purchasePart(PlaneData.getPlane(10), 0);
//				s_instance.purchasePart(PlaneData.getPlane(12), 0);
//				s_instance.purchasePart(TankPartData.getHull(0).getUpgrade(0), 0);
//				s_instance.purchasePart(TankPartData.getTurret(0).getUpgrade(1), 0);
			}
			return s_instance;
		}
		
		public var credits:uint;
		public var levelReached:uint;
		public var currentPlane:uint;
		public var currentHull:uint;
		public var currentTurret:uint;
		
		public function purchasePart(part:VehiclePart, cost:uint):void
		{
			Util.ASSERT(!part.purchased);
			Util.ASSERT(cost <= credits);
			
			part.purchased = true;
			credits -= cost;
		}
	}
}

final internal class SINGLETONLIMITER {}