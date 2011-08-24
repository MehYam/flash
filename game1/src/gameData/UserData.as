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
				var so:SharedObject;
				try
				{
					so = SharedObject.getLocal("store.PlanevTank.UserData");
				}
				catch (e:Error)
				{
					trace("could not init SharedObject", e);
				}
				
				// priming
				VehicleData.instance;
//				if (so && so.data.userData)
//				{
//					s_instance = so.data.userData;
//				}
//				else
				{
					s_instance = new UserData;
					if (so)
					{
//						so.data.userData = s_instance;
					}
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
			try
			{
				var so:SharedObject = SharedObject.getLocal("store.PlanevTank.UserData");
				so.clear();
			}
			catch (e:Error)
			{
				trace("could not clear SharedObject", e);
			}
		}
		static private function debug():void
		{
			// TEST DATA BELOW
			s_instance.credits = 100000;
			s_instance.purchasePart(PlaneData.getPlane(1), 0);
			s_instance.purchasePart(PlaneData.getPlane(3), 0);
			s_instance.purchasePart(PlaneData.getPlane(2), 0);
			s_instance.purchasePart(PlaneData.getPlane(6), 0);
			s_instance.purchasePart(PlaneData.getPlane(4), 0);
			s_instance.purchasePart(PlaneData.getPlane(7), 0);
			s_instance.purchasePart(PlaneData.getPlane(5), 0);
			s_instance.purchasePart(PlaneData.getPlane(8), 0);
			
			// second tier
			s_instance.purchasePart(PlaneData.getPlane(34), 0);
			s_instance.purchasePart(PlaneData.getPlane(28), 0);
			s_instance.purchasePart(PlaneData.getPlane(15), 0);
			s_instance.purchasePart(PlaneData.getPlane(12), 0);
			s_instance.purchasePart(PlaneData.getPlane(21), 0);
			s_instance.purchasePart(PlaneData.getPlane(31), 0);
			s_instance.purchasePart(PlaneData.getPlane( 9), 0);
			s_instance.purchasePart(PlaneData.getPlane(25), 0);
			s_instance.purchasePart(PlaneData.getPlane(18), 0);

			s_instance.purchasePart(PlaneData.getPlane(35), 0);
			s_instance.purchasePart(PlaneData.getPlane(29), 0);
			s_instance.purchasePart(PlaneData.getPlane(16), 0);
			s_instance.purchasePart(PlaneData.getPlane(13), 0);
			s_instance.purchasePart(PlaneData.getPlane(22), 0);
			s_instance.purchasePart(PlaneData.getPlane(32), 0);
			s_instance.purchasePart(PlaneData.getPlane(10), 0);
			s_instance.purchasePart(PlaneData.getPlane(26), 0);
			s_instance.purchasePart(PlaneData.getPlane(19), 0);
			
			// final tier testing
			s_instance.purchasePart(PlaneData.getPlane(36), 0);
			s_instance.purchasePart(PlaneData.getPlane(30), 0);
			s_instance.purchasePart(PlaneData.getPlane(17), 0);
			s_instance.purchasePart(PlaneData.getPlane(14), 0);
			s_instance.purchasePart(PlaneData.getPlane(23), 0);
			s_instance.purchasePart(PlaneData.getPlane(33), 0);
			s_instance.purchasePart(PlaneData.getPlane(11), 0);
			s_instance.purchasePart(PlaneData.getPlane(20), 0);
			s_instance.purchasePart(PlaneData.getPlane(27), 0);

			const testHull:uint = 2;
			s_instance.currentHull = testHull;
			s_instance.purchasePart(TankPartData.getHull(testHull).getUpgrade(0), 0);
			s_instance.purchasePart(TankPartData.getHull(testHull).getUpgrade(1), 0);
			const testTurret:uint = 1;
			s_instance.currentTurret = testTurret;
			s_instance.purchasePart(TankPartData.getTurret(testTurret).getUpgrade(0), 0);
			s_instance.purchasePart(TankPartData.getTurret(testTurret).getUpgrade(1), 0);
			for (var i:uint = 1; i < 5; ++i)
			{
				s_instance.purchasePart(TankPartData.getHull(i), 0);
				s_instance.purchasePart(TankPartData.getTurret(i), 0);
			}
			s_instance.currentPlane = 36;
			s_instance.levelsBeaten = 34;
		}
		
		private var _credits:uint;
		private var _levelsBeaten:uint;  // essentially 1-based index, so == 0 means not yet completed any levels
		private var _currentPlane:uint;
		private var _currentHull:uint;
		private var _currentTurret:uint;

		private var _purchases:Object = {}; // key of id => VehiclePartData
		public function readExternal(input:IDataInput):void
		{
			_credits = input.readUnsignedInt();
			_levelsBeaten = input.readUnsignedInt();
			_currentPlane = input.readUnsignedInt();
			_currentHull = input.readUnsignedInt();
			_currentTurret = input.readUnsignedInt();
			_purchases = input.readObject();
		}
		public function writeExternal(output:IDataOutput):void
		{
			output.writeUnsignedInt(_credits);
			output.writeUnsignedInt(_levelsBeaten);
			output.writeUnsignedInt(_currentPlane);
			output.writeUnsignedInt(_currentHull);
			output.writeUnsignedInt(_currentTurret);
			output.writeObject(_purchases);
		}
		public function get currentTurret():uint
		{
			return _currentTurret;
		}
		public function set currentTurret(value:uint):void
		{
			if (value != _currentTurret)
			{
				_currentTurret = value;
				flush();
			}
		}
		public function get currentHull():uint
		{
			return _currentHull;
		}
		public function set currentHull(value:uint):void
		{
			if (value != _currentHull)
			{
				_currentHull = value;
				flush();
			}
		}
		public function get currentPlane():uint
		{
			return _currentPlane;
		}
		public function set currentPlane(value:uint):void
		{
			if (value != _currentPlane)
			{
				_currentPlane = value;
				flush();
			}
				
		}
		public function get levelsBeaten():uint
		{
			return _levelsBeaten;
		}
		public function set levelsBeaten(value:uint):void
		{
			if (_levelsBeaten != value)
			{
				_levelsBeaten = value;
				flush();
			}
		}
		public function get credits():uint
		{
			return _credits;
		}
		public function set credits(value:uint):void
		{
			if (_credits != value)
			{
				_credits = value;
				flush();
			}
		}
		private function flush():void
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal("store.PlanevTank.UserData");
				so.data.userData = this;
				
				try
				{
					so.flush();
				}
				catch (e:Error)
				{
					trace("flush failed", e);
				}
			}
			catch (e:Error)
			{
				trace("getLocal failure", e);
			}
		}
		public function owns(partId:String):Boolean { return _purchases[partId]; } 
		public function purchasePart(part:VehiclePart, cost:uint):void
		{
			Util.ASSERT(!_purchases[part.id]);
			Util.ASSERT(cost <= credits);
			
			_purchases[part.id] = true;
			credits -= cost;
			flush();
		}
	}
}
