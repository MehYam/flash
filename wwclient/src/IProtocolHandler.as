package
{
	public interface IProtocolHandler
	{
		function scoreWord(player:String, word:String, points:int):void;
		function addPlayer(player:String, points:int):void;
		function removePlayer(player:String, points:int):void;
//		function chatText(...);
//		function startGame(...);
//		function endGame(...);
//		function startRound(...);
//		function endRound(...);
	}
}