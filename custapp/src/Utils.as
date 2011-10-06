package
{
	import spark.formatters.CurrencyFormatter;

	public class Utils
	{
		public function Utils()
		{
		}
		static public function matches(item:String, pattern:String):Boolean
		{
			return item && (item.toUpperCase().indexOf(pattern) >= 0);
		}
		static private var s_cf:CurrencyFormatter;
		static public function get currencyFormatter():CurrencyFormatter
		{
			if (!s_cf)
			{
				s_cf = new CurrencyFormatter;
				s_cf.useCurrencySymbol = true;
			}
			return s_cf;
		}
	}
}