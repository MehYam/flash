package gameData
{
	public class BaseStats
	{
		public var ammo:Object;
		public var armor:Number;
		public var damage:Number;
		public var fireRate:Number;
		public var speed:Number;
		
		public var cost:uint;

		public function BaseStats(armor:Number, damage:Number, fireRate:Number, speed:Number, cost:uint)
		{
			this.armor = armor;
			this.damage = damage;
			this.fireRate = fireRate;
			this.speed = speed;
			this.cost = cost;
		}
	}
}