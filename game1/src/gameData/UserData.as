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
				s_instance.credits = 10000;
				s_instance.currentPlane = 3;
				s_instance.purchasePlane(0, 0);
				s_instance.purchasePlane(1, 0);
				s_instance.purchasePlane(3, 0);
				s_instance.purchasePlane(9, 0);
				s_instance.purchasePlane(10, 0);
				s_instance.purchasePlane(11, 0);
				
				s_instance.purchaseHull(0, 0);
				s_instance.purchaseTurret(0, 0);
				s_instance.currentPlane = 0;
				s_instance.currentTurret = 0;
			}
			return s_instance;
		}
		
		public var purchasedPlanes:Array = [];
		public var purchasedHulls:Array = [];
		public var purchasedTurrets:Array = [];

		public var credits:uint;
		public var levelReached:uint;
		public var currentPlane:uint;
		public var currentHull:uint;
		public var currentTurret:uint;
		
		private function purchasePart(purchased:Array, partIndex:uint, cost:uint):void
		{
			Util.ASSERT(!purchased[partIndex]);
			Util.ASSERT(cost <= credits);
			
			purchased[partIndex] = true;
			credits -= cost;
			
		}
		public function purchasePlane(plane:uint, cost:uint):void
		{
			purchasePart(purchasedPlanes, plane, cost);
		}
		public function purchaseHull(hull:uint, cost:uint):void
		{
			purchasePart(purchasedHulls, hull, cost);
		}
		public function purchaseTurret(turret:uint, cost:uint):void
		{
			purchasePart(purchasedTurrets, turret, cost);
		}
	}
}

final internal class SINGLETONLIMITER {}