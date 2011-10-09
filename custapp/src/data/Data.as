package data
{
	import karnold.utils.SQLHelper;
	import karnold.utils.Util;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;

	//
	// KAI: fundamental flaw here is that ID key management is not handled by the database, but this code itself.
	// Are you supposed to look up the key that the database generated after creating a new record?  In any case,
	// this current scheme would break if multiple instances of the program were being used concurrently.
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
		public function createOrder(customerID:int, pickupDate:Number, pickupTime:String):Order
		{
			var retval:Order = new Order;
			retval.id = nextID;
			retval.customerID = customerID;
			retval.pickupDate = pickupDate;
			retval.pickupTime = pickupTime;
			return retval;
		}
		public function createLineItem(itemID:int, orderID:int, name:String, price:Number):LineItem
		{
			var retval:LineItem = new LineItem;
			retval.id = nextID;
			retval.itemID = itemID;
			retval.orderID = orderID;
			retval.price = price;
			retval.name = name;
			retval.quantity = 1;
			return retval;
		}

		private var _id:int = 0;
		public function get nextID():int { return _id++; }
		public function writeCustomer(customer:Object):void
		{
			writeRecord(CUSTOMER_TABLE, customers, customer);
		}
		public function writeOrder(order:Order):void
		{
			writeRecord(ORDER_TABLE, orders, order);
			for each (var lineItem:LineItem in order.items)
			{
				//KAI: alternative is to read to/write from the line item list separately, which would make it
				// easier to implement partial saving of orders-in-progress
				_sql.writeRecord(ORDER_ITEMS_TABLE, lineItem);
			}
		}
		public function getCustomer(customerID:int):Object
		{
			return lookupObjectByID(customers, customerID);
		}
		public function getRawItem(itemID:int):Object
		{
			return lookupObjectByID(items, itemID);
		}
		static private function lookupObjectByID(collection:IList, id:int):Object
		{
			const index:int = lookupIndexByID(collection, id);
			return index >= 0 ? collection.getItemAt(index) : null;
		}
		static private function lookupIndexByID(collection:IList, id:int):int
		{
			for (var i:int = 0; i < collection.length; ++i)
			{
				const o:Object = collection.getItemAt(i);
				if (o.id == id)
				{
					return i;
				}
			}
			return -1;
		}
		private function writeRecord(table:String, collection:IList, obj:Object):void
		{
			const index:int = lookupIndexByID(collection, obj.id);
			if (index == -1)
			{
				collection.addItem(obj);
			}
			else
			{
				collection.setItemAt(obj, index);
			}
			_sql.writeRecord(table, obj); 
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
		
		/// Database table descriptions ///////////////////////////////////////////////////////
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
			{ name: "customerID", type: SQLHelper.TYPE_INTEGER },
			{ name: "pickupDate", type: SQLHelper.TYPE_REAL },
			{ name: "pickupTime", type: SQLHelper.TYPE_TEXT },
			{ name: "ready", type: SQLHelper.TYPE_BOOLEAN },
			{ name: "pickedUp", type: SQLHelper.TYPE_BOOLEAN },
			{ name: "paid", type: SQLHelper.TYPE_REAL }
		];
		static private const ORDER_ITEMS_TABLE:String = "order_items";
		static private const ORDER_ITEM_FIELDS:Array =
		[
			{ name: "itemID", type: SQLHelper.TYPE_INTEGER },
			{ name: "orderID", type: SQLHelper.TYPE_INTEGER },
			{ name: "price", type: SQLHelper.TYPE_REAL },
			{ name: "quantity", type: SQLHelper.TYPE_INTEGER },
			{ name: "description", type: SQLHelper.TYPE_TEXT }
		];
		
		private var _sql:SQLHelper = new SQLHelper;
		public function Data(singletonClass:Class)
		{
			if (singletonClass != SingletonClass) throw "hey this is a singleton";

			_sql.createTable(CUSTOMER_TABLE, CUSTOMER_FIELDS);
			_sql.createTable(ITEM_TABLE, ITEM_FIELDS);
			_sql.createTable(ORDER_TABLE, ORDER_FIELDS);
			_sql.createTable(ORDER_ITEMS_TABLE, ORDER_ITEM_FIELDS);

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

			_sql.readTable(CUSTOMER_TABLE, onCustomers);
			_sql.readTable(ITEM_TABLE, onItems);
			_sql.readTable(ORDER_TABLE, onOrders);
	
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
		}
		private function loadDataToCollection(collection:ArrayCollection, data:Array, tableName:String):void
		{
			Util.ASSERT(collection.length == 0, "Table '" + tableName + "' being read twice?");
			if (data)
			{
				for each (var record:Object in data)
				{
					if (record.id >= _id)
					{
						_id = record.id + 1;
					}
				}
				collection.source = data;
			}
			else
			{
				trace("No data for table '" + tableName + "'");
			}
		}
		private function loadTypedDataToCollection(collection:ArrayCollection, data:Array, tableName:String, fields:Array, classForTypedObject:Class):void
		{
			//KAI: some copy pasta here
			Util.ASSERT(collection.length == 0, "Table '" + tableName + "' being read twice?");
			if (data)
			{
				var hydratedObjects:Array = [];
				for each (var record:Object in data)
				{
					if (record.id >= _id)
					{
						++_id;
					}
					var typed:Object = new classForTypedObject;
					typed.id = record.id;
					for each (var field:Object in fields)
					{
						typed[field.name] = record[field.name]; 
					}
					hydratedObjects.push(typed);
				}
				collection.source = hydratedObjects;
			}
			else
			{
				trace("No data for table '" + tableName + "'");
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
		private function onOrders(data:Array):void
		{
			loadTypedDataToCollection(orders, data, ORDER_TABLE, ORDER_FIELDS, Order);
			for each (var order:Order in orders)
			{
				_sql.readTableForColumn(ORDER_ITEMS_TABLE, "orderID", order.id, onOrderItems);
			}
		}
		private function onOrderItems(d:Array):void
		{
			if (d && d.length)
			{
				const orderID:int = d[0].orderID;
				const order:Order = lookupObjectByID(orders, orderID) as Order;
				if (order)
				{
					loadTypedDataToCollection(order.items, d, ORDER_ITEMS_TABLE, ORDER_ITEM_FIELDS, LineItem);
				}
				else
				{
					trace("no order for items with orderID", orderID);
				}
			}
		}
	}
}

internal final class SingletonClass {}