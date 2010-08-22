package scripts
{
	public interface IGameScript extends IGameEvents
	{
		function begin(game:IGame):void;
		
		function damageActor(game:IGame, actor:Actor, damage:Number, actorFriendly:Boolean, wasCollision:Boolean):void;
	}
}