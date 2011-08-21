package gameData
{
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import karnold.utils.Util;

	public final class UserData implements IExternalizable
	{
		static private var s_instance:UserData;
		static public function get instance():UserData
		{
			if (!s_instance)
			{
				registerClassAlias("PlanevTank.UserData", UserData);
				var so:SharedObject = SharedObject.getLocal("store.PlanevTank.UserData");
				
				// priming
				VehicleData.instance;

				if (so.data.userData)
				{
					s_instance = so.data.userData;
				}
				else
				{
					s_instance = new UserData;
					so.data.userData = s_instance; 

					debug();
					
					s_instance.purchasePart(PlaneData.getPlane(0), 0);
					s_instance.purchasePart(TankPartData.getHull(0), 0);
					s_instance.purchasePart(TankPartData.getTurret(0), 0);
		
					s_instance.currentPlane = 0;
					s_instance.currentHull = 0;
					s_instance.currentTurret = 0;
				}
			}
			return s_instance;
		}
		static public function reset():void
		{
			s_instance = null;
		}
		static private function debug():void
		{
			// TEST DATA BELOW
			s_instance.credits = 100000;
//			s_instance.purchasePart(PlaneData.getPlane(1), 0);
//			s_instance.purchasePart(PlaneData.getPlane(3), 0);
//			s_instance.purchasePart(PlaneData.getPlane(2), 0);
//			s_instance.purchasePart(PlaneData.getPlane(6), 0);
//			s_instance.purchasePart(PlaneData.getPlane(4), 0);
//			s_instance.purchasePart(PlaneData.getPlane(7), 0);
//			s_instance.purchasePart(PlaneData.getPlane(5), 0);
//			s_instance.purchasePart(PlaneData.getPlane(8), 0);
//			
//			// second tier
//			s_instance.purchasePart(PlaneData.getPlane(34), 0);
//			s_instance.purchasePart(PlaneData.getPlane(28), 0);
//			s_instance.purchasePart(PlaneData.getPlane(15), 0);
//			s_instance.purchasePart(PlaneData.getPlane(12), 0);
//			s_instance.purchasePart(PlaneData.getPlane(21), 0);
//			s_instance.purchasePart(PlaneData.getPlane(31), 0);
//			s_instance.purchasePart(PlaneData.getPlane( 9), 0);
//			s_instance.purchasePart(PlaneData.getPlane(25), 0);
//			s_instance.purchasePart(PlaneData.getPlane(18), 0);
//
//			s_instance.purchasePart(PlaneData.getPlane(35), 0);
//			s_instance.purchasePart(PlaneData.getPlane(29), 0);
//			s_instance.purchasePart(PlaneData.getPlane(16), 0);
//			s_instance.purchasePart(PlaneData.getPlane(13), 0);
//			s_instance.purchasePart(PlaneData.getPlane(22), 0);
//			s_instance.purchasePart(PlaneData.getPlane(32), 0);
//			s_instance.purchasePart(PlaneData.getPlane(10), 0);
//			s_instance.purchasePart(PlaneData.getPlane(26), 0);
//			s_instance.purchasePart(PlaneData.getPlane(19), 0);
//			
//			// final tier testing
//			s_instance.purchasePart(PlaneData.getPlane(36), 0);
//			s_instance.purchasePart(PlaneData.getPlane(30), 0);
//			s_instance.purchasePart(PlaneData.getPlane(17), 0);
//			s_instance.purchasePart(PlaneData.getPlane(14), 0);
//			s_instance.purchasePart(PlaneData.getPlane(23), 0);
//			s_instance.purchasePart(PlaneData.getPlane(33), 0);
//			s_instance.purchasePart(PlaneData.getPlane(11), 0);
//			s_instance.purchasePart(PlaneData.getPlane(20), 0);
//			s_instance.purchasePart(PlaneData.getPlane(27), 0);
//
//			const testHull:uint = 2;
//			s_instance.currentHull = testHull;
//			s_instance.purchasePart(TankPartData.getHull(testHull).getUpgrade(0), 0);
//			s_instance.purchasePart(TankPartData.getHull(testHull).getUpgrade(1), 0);
//			const testTurret:uint = 1;
//			s_instance.currentTurret = testTurret;
//			s_instance.purchasePart(TankPartData.getTurret(testTurret).getUpgrade(0), 0);
//			s_instance.purchasePart(TankPartData.getTurret(testTurret).getUpgrade(1), 0);
//			for (var i:uint = 1; i < 5; ++i)
//			{
//				s_instance.purchasePart(TankPartData.getHull(i), 0);
//				s_instance.purchasePart(TankPartData.getTurret(i), 0);
//			}
//			s_instance.currentPlane = 36;
			s_instance.levelsBeaten = 34;
		}
		
		public var credits:uint;
		public var levelsBeaten:uint;  // essentially 1-based index, so == 0 means not yet completed any levels
		public var currentPlane:uint;
		public var currentHull:uint;
		public var currentTurret:uint;

		private var _purchases:Object = {}; // key of id => VehiclePartData
		public function readExternal(input:IDataInput):void
		{
			this.credits = input.readUnsignedInt();
			this.levelsBeaten = input.readUnsignedInt();
			this.currentPlane = input.readUnsignedInt();
			this.currentHull = input.readUnsignedInt();
			this.currentTurret = input.readUnsignedInt();
			this._purchases = input.readObject();
		}
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUnsignedInt(credits);
			output.writeUnsignedInt(levelsBeaten);
			output.writeUnsignedInt(currentPlane);
			output.writeUnsignedInt(currentHull);
			output.writeUnsignedInt(currentTurret);
			output.writeObject(_purchases);
		}
		public function owns(partId:String):Boolean { return _purchases[partId]; } 
		public function purchasePart(part:VehiclePart, cost:uint):void
		{
			Util.ASSERT(!_purchases[part.id]);
			Util.ASSERT(cost <= credits);
			
			_purchases[part.id] = true;
			credits -= cost;
			
			var so:SharedObject = SharedObject.getLocal("store.PlanevTank.UserData");
			so.data.userData = this;
			so.flush();
		}
	}
}
