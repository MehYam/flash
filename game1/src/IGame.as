package
{
	public interface IGame
	{
		function get player():Actor
		function addEnemy(actor:Actor):void;
		function addEnemyAmmo(actor:Actor):void;
		function addPlayerAmmo(actor:Actor):void;
		function addEffect(actor:Actor):void;
		
		function togglePause():void;
	}
}