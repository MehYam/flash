package data
{
	import karnold.utils.SQLHelper;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;

	final public class Data
	{
		static public const BAR_HEIGHT:Number = 40;
		
		static private var s_instance:Data;
		static public function get instance():Data
		{
			if (!s_instance)
			{
				s_instance = new Data;
			}
			return s_instance;
		}

		public const orders:ArrayCollection = new ArrayCollection([]);
		public const customers:ArrayCollection = new ArrayCollection([]);
		public const items:ArrayCollection = new ArrayCollection([]);
		public const colors:ArrayList = new ArrayList([]);
		public const patterns:ArrayList = new ArrayList([]);
		public function createOrder(customerID:int, date:Number, time:String, items:Array):Order
		{
			var retval:Order = new Order;
			retval.id = nextID;
			retval.customerID = customerID;
			retval.date = date;
			retval.time = time;
			retval.items = new ArrayCollection(items);
			return retval;
		}

		static private function findRecordByID(collection:IList, obj:Object):int
		{
			for (var i:int = 0; i < collection.length; ++i)
			{
				const o:Object = collection.getItemAt(i);
				if (o.id == obj.id)
				{
					return i;
				}
			}
			return -1;
		}

		private var _id:int = 0;
		public function get nextID():int { return _id++; }
		public function writeCustomer(customer:Object):void
		{
			const index:int = findRecordByID(customers, customer);
			if (index == -1)
			{
				customers.addItem(customer);
			}
			else
			{
				customers.setItemAt(customer, index);
			}
			_sql.writeRecord(CUSTOMER_TABLE, customer); 
		}
		private function addItem(name:String, price:Number):void
		{
			items.addItem({ name:name, price:price, id:nextID });
		}
		private function addColor(name:String, color:uint):void
		{
			colors.addItem({ name:name, color:color });
		}
		private function addPattern(name:String):void
		{
			patterns.addItem(name);
		}
		
		static private const CUSTOMER_TABLE:String = "customers";
		static private const CUSTOMER_FIELDS:Array = 
		[
			{ name: "first", type: SQLHelper.TYPE_TEXT },
			{ name: "last",  type: SQLHelper.TYPE_TEXT },
			{ name: "phone", type: SQLHelper.TYPE_INTEGER },
			{ name: "email", type: SQLHelper.TYPE_TEXT },
			{ name: "notes", type: SQLHelper.TYPE_TEXT }
		];
		
		private var _sql:SQLHelper = new SQLHelper;
		public function Data()
		{
			_sql.createTable(CUSTOMER_TABLE, CUSTOMER_FIELDS);

//KAI: left off here + handling the 0 phone number issue w/ the table
//			_sql.readTable(CUSTOMER_TABLE, onCustomers);
			
			addItem("Misc.", 1);
			addItem("Tee Shirt", 5);
			addItem("Pants", 7);
			addItem("Vest", 10);
			addItem("Jacket", 9.50);
			addItem("Coat", 10.50);
			addItem("Suit, 3pc", 27.50);
			addItem("Socks", 2.50);
			addItem("Scarf", 5.50);
			addItem("Tie", 3.00);
			
			addColor("Red", 0xbb0000);
			addColor("Green", 0x00bb00);
			addColor("Blue", 0x0000bb);
			addColor("Yellow", 0xcccc00);
			addColor("Purple", 0xbb00bb);
			addColor("Orange", 0xff7700);
			addColor("White", 0xcccccc);
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