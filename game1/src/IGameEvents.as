package
{
	import flash.geom.Point;

	public interface IGameEvents
	{
		function onCenterPrintDone():void;
		
		function onOpposingCollision(game:IGame, friendly:Actor, enemy:Actor):void;
		function onFriendlyStruckByAmmo(game:IGame, friendly:Actor, ammo:Actor):void;
		function onEnemyStruckByAmmo(game:IGame, enemy:Actor, ammo:Actor):void;
		
		function onPlayerShooting(game:IGame, mouse:Boolean):void;
		function onPlayerStopShooting(game:IGame, mouse:Boolean):void;
	}
}