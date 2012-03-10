package
{
	import flash.utils.Dictionary;

	public class AssetManager
	{
		
		[Embed("ui/clothing/blouse48.png")] private static const PinkBlouse:Class;
		[Embed("ui/clothing/brown-coat48.png")] private static const BrownCoat:Class;
		[Embed("ui/clothing/suit.png")]	private static const SuitTop:Class;
		[Embed("ui/clothing/blueGown48.png")]	private static const EveningDress:Class;
		[Embed("ui/clothing/littleGirlDress48.png")] private static const GirlDress:Class;
		[Embed("ui/clothing/redSocks48.png")]	private static const RedSocks:Class;
		
		

		public static const clothingLookup:Object =
		{
			"blousePink" : PinkBlouse,
			"coatBrown" : BrownCoat,
			"suitTop" : SuitTop,
			"dressEvening" : EveningDress,
			"dressGirl" : GirlDress,
			"socksRed" : RedSocks
		};

		[Embed("ui/money/100.png")]	public static const ICON100Bill:Class;
		[Embed("ui/money/50.png")] public static const ICON50Bill:Class;
		[Embed("ui/money/20.png")] public static const ICON20Bill:Class;
		[Embed("ui/money/10.png")] public static const ICON10Bill:Class;
		[Embed("ui/money/5.png")] public static const ICON5Bill:Class;
		[Embed("ui/money/1.png")] public static const ICON1Bill:Class;
		[Embed("ui/money/penny.png")] public static const ICONPenny:Class;
		[Embed("ui/money/nickel.png")] public static const ICONNickel:Class;
		[Embed("ui/money/dime.png")] public static const ICONDime:Class;
		[Embed("ui/money/quarter.png")]	public static const ICONQuarter:Class;
		[Embed("ui/money/clear.png")] public static const ICONClear:Class;
		[Embed("ui/money/exact-change.png")] public static const ICONExactChange:Class;
		[Embed("ui/money/cash.png")] public static const ICONCash:Class;
		[Embed("ui/money/check.png")] public static const ICONCheck:Class;
		[Embed("ui/money/credit.png")] public static const ICONCredit:Class;
		
		[Embed("ui/newDoc.png")] public static const ICONNewDoc:Class;
		[Embed("ui/customer.png")] public static const ICONCustomer:Class;
		[Embed("ui/printer.png")] public static const ICONPrinter:Class;
		[Embed("ui/pay.png")] public static const ICONPay:Class;
		
		
		public function AssetManager()
		{			
		}
	}
}