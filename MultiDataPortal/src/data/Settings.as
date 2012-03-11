package data
{
	import flash.net.SharedObject;

	public final class Settings
	{
		static public function get instance():SharedObject
		{
			return SharedObject.getLocal("MDP.1");
		}
	}
}