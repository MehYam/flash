package
{
	public class Utils
	{
		public function Utils()
		{
		}
		static public function matches(item:String, pattern:String):Boolean
		{
			return item && (item.toUpperCase().indexOf(pattern) >= 0);
		}
	}
}