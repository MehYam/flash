package
{
	import karnold.utils.Bounds;
	import karnold.utils.Input;

	public interface IGame
	{
		function addEnemy(actor:Actor):void;
		function addEnemyAmmo(actor:Actor):void;
		function addPlayerAmmo(actor:Actor):void;
		function addEffect(actor:Actor):void;
		function showPlayer(actor:Actor):void;
		function killActor(actor:Actor):void;
		function centerPrint(text:String):void;

		function start():void;
		function stop():void;

		function set tiles(str:String):void;

		function get running():Boolean;
		function get worldBounds():Bounds;
		function get input():Input;
		function get player():Actor;
		function get playerShooting():Boolean;
		function get scoreBoard():ScoreBoard;
	}
}