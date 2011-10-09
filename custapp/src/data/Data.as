package data
{
	import karnold.utils.SQLHelper;
	import karnold.utils.Util;
	
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
				s_instance = new Data(SingletonClass);
			}
			return s_instance;
		}

		public const customers:ArrayCollection = new ArrayCollection([]);
		public const items:ArrayCollection = new ArrayCollection([]);
		public const orders:ArrayCollection = new ArrayCollection([]);
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
			_sql.writeRecord(ITEM_TABLE, { name:name, price:price, id:nextID });
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
		static private const ITEM_TABLE:String = "items";
		static private const ITEM_FIELDS:Array = 
		[
			{ name: "name", type: SQLHelper.TYPE_TEXT },
			{ name: "price", type: SQLHelper.TYPE_REAL }
		];
		static private const ORDER_TABLE:String = "orders";
		static private const ORDER_FIELDS:Array =
		[
		];
		static private const ORDER_ITEMS_TABLE:String = "order_items";
		static private const ORDER_ITEM_FIELDS:Array =
		[
		];
		
		private var _sql:SQLHelper = new SQLHelper;
		public function Data(singletonClass:Class)
		{
			if (singletonClass != SingletonClass) throw "hey this is a singleton";

			_sql.createTable(CUSTOMER_TABLE, CUSTOMER_FIELDS);
			_sql.createTable(ITEM_TABLE, ITEM_FIELDS);

			_sql.readTable(CUSTOMER_TABLE, onCustomers);
			
//			addItem("Misc.", 1);
//			addItem("Tee Shirt", 5);
//			addItem("Pants", 7);
//			addItem("Vest", 10);
//			addItem("Jacket", 9.50);
//			addItem("Coat", 10.50);
//			addItem("Suit, 3pc", 27.50);
//			addItem("Socks", 2.50);
//			addItem("Scarf", 5.50);
//			addItem("Tie", 3.00);

			_sql.readTable(ITEM_TABLE, onItems);

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
		private function loadDataToCollection(collection:ArrayCollection, data:Array, name:String):void
		{
			Util.ASSERT(collection.length == 0, "Table '" + name + "' being read twice?");
			if (data)
			{
				for each (var record:Object in data)
				{
					if (record.id >= _id)
					{
						++_id;
					}
				}
				collection.source = data;
			}
			else
			{
				trace("No data for table '" + name + "'");
			}
		}
		private function onCustomers(data:Array):void
		{
			loadDataToCollection(customers, data, CUSTOMER_TABLE);
		}
		private function onItems(data:Array):void
		{
			loadDataToCollection(items, data, ITEM_TABLE);
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

internal final class SingletonClass {}