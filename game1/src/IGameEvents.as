package
{
	import flash.geom.Point;

	public interface IGameEvents
	{
		function onCenterPrintDone():void;
		
		function onPlayerStruckByEnemy(game:IGame, enemy:Actor):void;
		function onPlayerStruckByAmmo(game:IGame, ammo:Actor):void;
		function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void;
		
		function onPlayerShootToMouse(game:IGame):void;
		function onPlayerShootForward(game:IGame):void;
		function onPlayerStopShooting(game:IGame):void;
	}
}