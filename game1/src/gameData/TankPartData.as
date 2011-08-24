package gameData
{
	import flash.utils.ByteArray;

	public class TankPartData extends VehiclePart
	{
		private var _upgrades:Vector.<String> = new Vector.<String>;
		
		// asset index goes into the ID, they must line up
		public function TankPartData(lock:Class, id:String, name:String, assetIndex:uint, baseStats:VehiclePartStats, radius:Number, upgradeA:String, upgradeB:String)
		{
			super(id, name, assetIndex, baseStats);

			if (lock != INTERNALFACTORY) throw "you can't construct these!";
			
			_upgrades[0] = upgradeA;
			_upgrades[1] = upgradeB;
			this.radius = radius;
		}
		public function getUpgrade(index:uint):TankPartData
		{
			return s_upgrades[_upgrades[index]];
		}
		static private var s_hulls:Vector.<TankPartData> = new Vector.<TankPartData>;
		static private var s_turrets:Vector.<TankPartData> = new Vector.<TankPartData>;
		static private var s_upgrades:Object = {};

		[Embed(source="assets/tanks.xml", mimeType="application/octet-stream")] static private const TANKXML:Class;
		static public function init(hulls:Vector.<Object>, turrets:Vector.<Object>, hullups:Vector.<Object>, turretups:Vector.<Object>):void
		{	
			var i:uint = 0;
			var tmp:Vector.<TankPartData> = new Vector.<TankPartData>;
			for each (var hullup:Object in hullups)
			{
				var hup:HullUpgrade = new HullUpgrade(i++, hullup.name, new VehiclePartStats(hullup.armor, hullup.damage, hullup.rate, hullup.speed, hullup.cost));
				tmp.push(hup);
				s_upgrades[hup.id] = hup;
			}
			for each (var hull:Object in hulls)
			{
				var h:Hull = new Hull(hull.name, hull.iAsset, new VehiclePartStats(hull.armor, hull.damage, hull.rate, hull.speed, hull.cost),
				                      hull.radius, tmp[parseInt(hull.up1)].id, tmp[parseInt(hull.up2)].id);
				s_hulls.push(h);
			}
			i = 0;
			tmp.length = 0;
			for each (var turretup:Object in turretups)
			{
				var tup:TurretUpgrade = new TurretUpgrade(i++, turretup.name, new VehiclePartStats(turretup.armor, turretup.damage, turretup.rate, turretup.speed, turretup.cost));
				tmp.push(tup);
				s_upgrades[tup.id] = tup;
			}
			for each (var turret:Object in turrets)
			{
				var t:Turret = new Turret(turret.name, turret.iAsset, new VehiclePartStats(0, turret.damage, turret.rate, 0, turret.cost),
					tmp[parseInt(turret.up1)].id, tmp[parseInt(turret.up2)].id);
				
				s_turrets.push(t);
			}
			// descriptions
			var byteArray:ByteArray = new TANKXML;
			const xml:XML = new XML(byteArray.readUTFBytes(byteArray.length));		
			var desc:XML;
			for each (desc in xml.descs.hulls.children())
			{
				var hullD:VehiclePart = getHull(desc.@part);
				hullD.description = desc.text();
			}
			for each (desc in xml.descs.turret.children())
			{
				var turretD:VehiclePart = getTurret(desc.@part);
				turretD.description = desc.text();
			}
		}
		static public function get hulls():Vector.<TankPartData> {	return s_hulls;	}
		static public function get turrets():Vector.<TankPartData>	{	return s_turrets;	}
		//KAI: would be better to replace index with the VehiclePart.id
		static public function getHull(index:uint):TankPartData { return s_hulls[ index ]; }
		static public function getTurret(index:uint):TankPartData { return s_turrets[ index ]; }

	}
}
import gameData.TankPartData;
import gameData.VehiclePartStats;

import karnold.utils.Util;

final internal class INTERNALFACTORY {}
final internal class Hull extends TankPartData
{
	public function Hull(name:String, assetIndex:uint, baseStats:VehiclePartStats, radius:Number, upgradeA:String, upgradeB:String)
	{
		Util.ASSERT(upgradeA && upgradeB);
		super(INTERNALFACTORY, "h" + assetIndex, name, assetIndex, baseStats, radius, upgradeA, upgradeB);
	}
}
final internal class Turret extends TankPartData
{
	public function Turret(name:String, assetIndex:uint, baseStats:VehiclePartStats, upgradeA:String, upgradeB:String)
	{
		Util.ASSERT(upgradeA && upgradeB);
		super(INTERNALFACTORY, "t" + assetIndex, name, assetIndex, baseStats, 0, upgradeA, upgradeB);
	}
}
final internal class HullUpgrade extends TankPartData
{
	public function HullUpgrade(index:uint, name:String, baseStats:VehiclePartStats)
	{
		super(INTERNALFACTORY, "hu" + index, name, assetIndex, baseStats, 0, null, null);
	}
}
final internal class TurretUpgrade extends TankPartData
{
	public function TurretUpgrade(index:uint, name:String, baseStats:VehiclePartStats)
	{
		super(INTERNALFACTORY, "tu" + index, name, assetIndex, baseStats, 0, null, null);
	}
}
