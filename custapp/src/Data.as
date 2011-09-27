package
{
	import mx.collections.ArrayCollection;

	public class Data
	{
		static private var s_instance:Data = new Data;
		static public function get instance():Data
		{
			return s_instance;
		}

		public const customers:ArrayCollection = new ArrayCollection([]);
		public const items:ArrayCollection = new ArrayCollection([]);
		public const orders:ArrayCollection = new ArrayCollection([]);
		
		private var _id:int = 0;
		private function addCustomer(first:String, last:String, phone:String, notes:String):void
		{
			customers.addItem({ first:first, last:last, phone:phone, notes:notes, id:_id++});
		}
		private function addItem(name:String, price:Number):void
		{
			items.addItem({ name:name, price:price, id:_id++ });
		}
		public function Data()
		{
			addCustomer("Joe", "Smith", "6509966759", null);
			addCustomer("Sandra", "Jones", "4155556666", null);
			addCustomer("Joe", "Everybody", "2342345", null);
			addCustomer("Steve", "Nobody", "2123334444", null);
			addCustomer("Captain", "America", "6508876655", null);
			addCustomer("The", "Dude", "3412543123", "Frequent rug cleanings");
			addCustomer("", "Foo", "1231234", null);

			addItem("Tee Shirt", 5);
			addItem("Pants", 7);
			addItem("Vest", 10);
			addItem("Jacket", 9.50);
			addItem("Coat", 10.50);
			addItem("Suit, 3pc", 27.50);
		}
	}
}