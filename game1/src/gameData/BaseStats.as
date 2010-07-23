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

		static public const ZERO:BaseStats = new BaseStats(0, 0, 0, 0, 0);
		public function BaseStats(armor:Number, damage:Number, fireRate:Number, speed:Number, cost:uint)
		{
			this.armor = armor;
			this.damage = damage;
			this.fireRate = fireRate;
			this.speed = speed;
			this.cost = cost;
		}
		public function reset():void
		{
			set(ZERO);
		}
		public function set(rhs:BaseStats):void
		{
			ammo = rhs.ammo;
			armor = rhs.armor;
			damage = rhs.damage;
			fireRate = rhs.fireRate;
			speed = rhs.speed;
		}
		public function add(rhs:BaseStats):void
		{
			ammo += rhs.ammo;
			armor += rhs.armor;
			damage += rhs.damage;
			fireRate += rhs.fireRate;
			speed += rhs.speed;
		}
	}
}