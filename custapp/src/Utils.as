package
{
	import spark.formatters.CurrencyFormatter;
	import spark.formatters.NumberFormatter;

	final public class Utils
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
		static private var s_pf:NumberFormatter;
		static public function get phoneFormatter():NumberFormatter
		{
			if (!s_pf)
			{
				s_pf = new NumberFormatter();
				s_pf.groupingPattern = "4;3;3";
				s_pf.groupingSeparator = "-";
				s_pf.fractionalDigits = 0;
			}
			return s_pf;
		}
		static public function extractDigits(str:String):String
		{
			return str.replace(/[^0-9]/g, "");
		}
		static public function daysToTime(days:Number):Number
		{
			return days * 24 * 60 * 60 * 1000;
		}
		static public function customerMatchesPattern(customer:Object, pattern:String):Boolean
		{
			return matches(customer.first, pattern) || 
				matches(customer.last, pattern) || 
				matches(customer.id, pattern) || 
				matches(customer.phone, pattern) || 
				matches(customer.email, pattern);
		}
	}
}
