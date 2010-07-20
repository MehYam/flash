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
			}
			return s_instance;
		}
		
		public var purchasedPlanes:Array = [];
		public var credits:uint;
		public var levelReached:uint;
		public var currentPlane:uint;
		
		public function purchasePlane(plane:uint, cost:uint):void
		{
			Util.ASSERT(!purchasedPlanes[plane]);
			Util.ASSERT(cost <= credits);
			
			purchasedPlanes[plane] = true;
			credits -= cost;
		}
	}
}

final internal class SINGLETONLIMITER {}