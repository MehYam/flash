package scripts
{
	import behaviors.IBehavior;

	public class GameScriptPlayerVehicle
	{
		public var actor:Actor;
		public var weapon:IBehavior;
		public var usingShield:Boolean;
		public var usingFusion:Boolean;
		public function GameScriptPlayerVehicle(actor:Actor, weapon:IBehavior, shield:Boolean, fusion:Boolean)
		{
			this.actor = actor;
			this.weapon = weapon;
			this.usingShield = shield;
			this.usingFusion = fusion;
		}
	}
}