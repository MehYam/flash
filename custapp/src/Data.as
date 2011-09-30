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

		public const orders:ArrayCollection = new ArrayCollection([]);
		public const customers:ArrayCollection = new ArrayCollection([]);
		public const items:ArrayCollection = new ArrayCollection([]);
		public const colors:ArrayList = new ArrayList([]);
		public const patterns:ArrayList = new ArrayList([]);

		static public const ORDER_STATE_NEW:int = 1;
		static public const ORDER_STATE_READY:int = 2;
		static public const ORDER_STATE_PAID:int = 3;
		static public const ORDER_STATE_PICKED_UP:int = 4;
		static public const ORDER_STATE_COMPLETE:int = 5;
		public function createOrder(customerID:int, date:Number, time:String, items:Array):Object
		{
			var retval:Object =
			{
				id: nextID,
				customerID: customerID,
				date: date,
				time: time,
				creationTime: new Date().date,

				ready: false,
				paid: false,
				pickedUp: false,
				
				items: items
			};
			return retval;
		}

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
			addCustomer("Joe", "Smith", "6509966759", "joe@yahoo.com", null);
			addCustomer("Sandra", "Jones", "4155556666", "sandra@foo.com", null);
			addCustomer("Joe", "Somebody", "2342345", null, null);
			addCustomer("Steve", "Nobody", "2123334444", null, null);
			addCustomer("Captain", "Ahab", "6508876655", null, null);
			addCustomer("The", "Dude", "3412543123", "lebowsky@bowling.com", "Frequent rug cleanings");
			addCustomer("Abraham", "Lincoln", "6509966710", "joe@joe.com", null);
			addCustomer("Green", "Lantern", "4155556677", "green@blah.com", null);
			addCustomer("Steve", "Vai", "2342356", null, null);
			addCustomer("George", "Hung", "2123334488", null, null);
			addCustomer("Dave", "Letterman", "6508876622", null, null);
			addCustomer("Johnny", "Carson", "3412543124", "lebowsky@bowling.com", "Frequent rug cleanings");
			addCustomer("", "Foo", "12345678", null, null);

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
			
			for (var i:uint = 0; i < 10; ++i)
			{
				var order:Object = createOrder(Math.random() * customers.length, new Date().date + (Math.random() * 10), "12pm", []);
				orders.addItem(order);
			}
		}
		public function getCustomer(customerID:int):Object
		{
			// KAI: replace w/ constant-time lookup
			for each (var customer:Object in customers)
			{
				if (customer.id == customerID)
				{
					return customer;
				}
			}
			return null;
		}
	}
}