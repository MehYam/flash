package gameData
{
	final public class PlaneData extends VehiclePart
	{
		public var upgrades:uint;
		public var purchasable:Boolean;
		public var unlock:uint = 0;  // index of PlaneData that unlocks this one

		public function PlaneData(name:String, aindex:uint, baseStats:VehiclePartStats, upgrades:uint = 0, purchasable:Boolean = true)
		{
			super(name, aindex, baseStats);
			this.upgrades = upgrades;
			this.purchasable = purchasable;
		}
		static private var s_entries:Array;
		static public function getPlane(i:uint):PlaneData
		{
			return planes[i];
		}
		static public function get planes():Array
		{
			if (!s_entries)
			{
				s_entries = 
				[
					//KAI: the vehiclepartstats should really be shared with gamescript, somehow
					// ...time for a data refactor?
				new PlaneData("Bee", 0,         new VehiclePartStats(0.05, 0.05, 0.3, 0.4, 1000), 2),
				new PlaneData("Wasp", 1,        new VehiclePartStats(0.05, 0.10, 0.3, 0.5, 2000)),
				new PlaneData("Hornet", 2,      new VehiclePartStats(0.10, 0.15, 0.3, 0.6, 2000)),
				new PlaneData("Jem", 3,         new VehiclePartStats(0.20, 0.10, 0.1, 0.1, 2000), 2),
				new PlaneData("Jem II", 4,      new VehiclePartStats(0.20, 0.15, 0.2, 0.2, 2000)),
				new PlaneData("Jem VSBL", 5,    new VehiclePartStats(0.20, 0.20, 0.3, 0.2, 2000)),
				new PlaneData("Yango", 6,       new VehiclePartStats(0.30, 0.4, 0.3, 0.2, 3000), 2),
				new PlaneData("Yango II", 7,    new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Yango III", 8,   new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Osprey", 9,	    new VehiclePartStats(0.4, 0.4, 0.3, 0.8, 4000), 2),
				new PlaneData("Osprey II", 10,  new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Osprey III", 11, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Diptera", 12, 	new VehiclePartStats(0.5, 0.4, 0.3, 0.8, 5000), 2),
				new PlaneData("Diptera X", 13, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Diptera XI", 14, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Cygnus X-1", 15, new VehiclePartStats(0.3, 0.4, 0.3, 0.8, 6000), 2),
				new PlaneData("Cygnus X-2", 16, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Cygnus X-3", 17, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Ghost", 18, 		new VehiclePartStats(0.6, 0.4, 0.3, 0.8, 7000), 2),
				new PlaneData("Phantom", 19,    new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Spectre", 20,    new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Attacus", 21, 	new VehiclePartStats(0.5, 0.4, 0.3, 0.8, 8000), 2),
				new PlaneData("Attacus 2", 22,  new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Attacus 3", 23,  new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("???", 24, 		new VehiclePartStats(0.1, 0.4, 0.3, 0.8, 9000), 0, false),
				new PlaneData("XStealth", 25, 	new VehiclePartStats(0.02, 0.4, 0.3, 0.8, 10000), 2),
				new PlaneData("YStealth", 26,   new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("ZStealth", 27,   new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Rocinante", 28, 	new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 11000), 2),
				new PlaneData("Rocinante I", 29, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Rocinante II", 30, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Esox", 31, 	new VehiclePartStats(0.5, 0.4, 0.3, 0.8, 12000), 2),
				new PlaneData("Pike", 32, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Musky", 33, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Corvid", 34, 	new VehiclePartStats(0.5, 0.4, 0.3, 0.8, 12000), 2),
				new PlaneData("Corvid X", 35, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000)),
				new PlaneData("Death Bird", 36, new VehiclePartStats(0.2, 0.4, 0.3, 0.8, 2000))
				];
				
				s_entries[0].unlock = 0;
				s_entries[3].unlock = 0;
				s_entries[6].unlock = 1;
				s_entries[9].unlock = 8;
				s_entries[12].unlock = 5;
				s_entries[15].unlock = 2;
				s_entries[18].unlock = 8;
				s_entries[21].unlock = 5;
				s_entries[24].unlock = 0;
				s_entries[25].unlock = 8;
				s_entries[28].unlock = 2;
				s_entries[31].unlock = 5;
				s_entries[34].unlock = 2;
				
				s_entries[0].description = 
					"The Bee is the basic ship in the Stinger line required by all tournament contestants. " +
					"Your... 'new Bee' has been fitted with a low-energy cannon, and like all Rogue-class ships, " +
					"it sacrifices armor for maneuverability.\n\n" +
					"Purchased upgrades to the Bee increase firepower, movement, and a bit of armor, but most importantly, unlock " +
					"the purchase of higher level ships and classes.";
				s_entries[1].description = 
					"The Wasp is a respectable step up from Bee, adding some movement speed and doubling its " +
					"firepower with a second cannon.\n\n" +
					"Purchase of the Wasp also unlocks the Bat, the first in the line of Fighter-class ships.";
				s_entries[2].description =
					"Wowawee\n\n" +
					"Purchasing this vehicle unlocks the Raven, Rocinante, and Cygnus lines Rogue-class ships." 
				s_entries[3].description =
					"The first of the class of Melee ships, the Jems are actually mining and drilling vessels " +
					"repurposed into tournament death machines.  All Melee ships have protective shields that " +
					"can be creatively used to inflict great harm on opponents.  Some ships include conventional weapons as well.\n\n" +
					"The Jem's only weapon is a shield that takes some time to recharge, and is relatively weak, but " +
					"can be flung at opponents at moderate range.  Upgrades to the Jem will unlock other Melee-class ships.";
				s_entries[9].description =
					"Fighter-class ships like those in the Yango line fall in the middle between Rogue and Melee " +
					"ships.  They're generally nimbler than Melees, but slower than Rogues due to added armor and " +
					"armament.  These ships are generally military in origin, and so require little modification to " +
					"be tournament-ready."; 
			}
			return s_entries;
		}
	}
}