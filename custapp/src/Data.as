package
{
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

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
		public const colors:ArrayList = new ArrayList([]);
		public const patterns:ArrayList = new ArrayList([]);
		
		private var _id:int = 0;
		public function get nextID():int { return _id++; }
		private function addCustomer(first:String, last:String, phone:String, email:String, notes:String):void
		{
			customers.addItem({ first:first, last:last, phone:phone, email:email, notes:notes, id:_id++});
		}
		private function addItem(name:String, price:Number):void
		{
			items.addItem({ name:name, price:price, id:_id++ });
		}
		private function addColor(name:String, color:uint):void
		{
			colors.addItem({ name:name, color:color });
		}
		private function addPattern(name:String):void
		{
			patterns.addItem(name);
		}
		public function Data()
		{
			addCustomer("Joe", "Smith", "6509966759", "joe@joe.com", null);
			addCustomer("Sandra", "Jones", "4155556666", null, null);
			addCustomer("Joe", "Everybody", "2342345", null, null);
			addCustomer("Steve", "Nobody", "2123334444", null, null);
			addCustomer("Captain", "America", "6508876655", null, null);
			addCustomer("The", "Dude", "3412543123", "lebowsky@bowling.com", "Frequent rug cleanings");
			addCustomer("", "Foo", "1231234", null, null);

			addItem("Tee Shirt", 5);
			addItem("Pants", 7);
			addItem("Vest", 10);
			addItem("Jacket", 9.50);
			addItem("Coat", 10.50);
			addItem("Suit, 3pc", 27.50);
			
			addColor("Red", 0xff0000);
			addColor("Green", 0x00ff00);
			addColor("Blue", 0x0000ff);
			addColor("Yellow", 0xffff00);
			addColor("Purple", 0xff00ff);
			addColor("Orange", 0xff7700);
			addColor("White", 0xffffff);
			addColor("Gray", 0x777777);
			addColor("Black", 0x000000);
			
			addPattern("Checkered");
			addPattern("Plaid");
			addPattern("Striped");
			addPattern("Paisely");
			addPattern("Patterned");
		}
	}
}