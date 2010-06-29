package
{
	public interface IGameEvents
	{
		function onCenterPrintDone(text:String):void;
		function onEnemyDeath(actor:Actor):void;
		function onPlayerDeath():void;
	}
}