package
{
	import flash.geom.Point;

	public interface IGameEvents
	{
		function onCenterPrintDone(text:String):void;
		
		function onPlayerStruckByEnemy(game:IGame, enemy:Actor):void;
		function onPlayerStruckByAmmo(game:IGame, ammo:Actor):void;
		function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void;
		
		function onPlayerShootForward(game:IGame):void;
		function onPlayerShootTo(game:IGame, to:Point):void;
	}
}