package scripts
{
	public interface IPenetratingAmmo // that's what SHE implemented
	{
		function strikeActor(actor:Actor):void;
		function isActorStruck(actor:Actor):Boolean;
	}
}