package scripts
{
	public interface IGameScript extends IGameEvents
	{
		function begin(game:IGame):void;
	}
}