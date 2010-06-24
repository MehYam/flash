package
{
	public interface IGameState
	{
		function get player():Actor
		function addEnemy(actor:Actor):void;
		function addEnemyAmmo(actor:Actor):void;
		function addPlayerAmmo(actor:Actor):void;
	}
}