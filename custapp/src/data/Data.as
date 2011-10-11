package data
{
	import karnold.utils.SQLHelper;
	import karnold.utils.Util;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;

	//
	// KAI: fundamental flaw here is that we're helping the database out too much (assigning our own IDs, 
	// caching too much, etc).  Would have been easier if we had just let the database do everything, and
	// gone with more of a write->read->dataProvider model.
	//
	// Also, we're not doing things atomically enough (i.e. purging line items after writing record changes)
	//
	// Also, we're modifying internal data because of binding but not immediately reflecting those changes
	// back to the database in the Order/OrderEditor case.  Seems rickety.
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
		public function createOrder(customerID:int, pickupTime:Number):Order
		{
			var retval:Order = new Order;
			retval.id = nextID;
			retval.customerID = customerID;
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
			writeRecordAndCache(CUSTOMER_TABLE, customers, customer);
		}
		public function writeOrder(order:Order):void
		{
			writeRecordAndCache(ORDER_TABLE, orders, order);
			for each (var lineItem:LineItem in order.items)
			{
				//KAI: alternative is to read to/write from the line item list separately, which would make it
				// easier to implement partial saving of orders-in-progress
				_sql.writeRecord(ORDER_ITEMS_TABLE, lineItem);
			}
			if (order.lineItemRecordsToPurge)
			{
				for each (var lineItemID:int in order.lineItemRecordsToPurge)
				{
					deleteLineItem(lineItemID);
				}
				order.lineItemRecordsToPurge.length = 0;
			}
		}
		public function writeOrderHistory(order:Order, message:String):void
		{
			const obj:Object =
			{
				orderID: order.id,
				date:    new Date().time,
				action:  message
			}
			writeRecordAndCache(ORDER_HISTORY_TABLE, order.history, obj);
			
		}
		public function loadOrderHistory(order:Order):void
		{
			if (!order.history.length)
			{
				_sql.readTableForColumn(ORDER_HISTORY_TABLE, "orderID", order.id, 
					function(result:Array):void
					{
						if (result)
						{
							order.history.source = result.concat(order.history.source);
							order.history.refresh();
						}
					}
				);
			}
		}
		private function deleteLineItem(lineItemID:int):void
		{
			_sql.deleteRecord(ORDER_ITEMS_TABLE, lineItemID);
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
		private function writeRecordAndCache(table:String, collection:IList, obj:Object):void
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
			{ name: "phone", type: SQLHelper.TYPE_TEXT },
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
			{ name: "creationTime", type: SQLHelper.TYPE_INTEGER },
			{ name: "pickupTime", type: SQLHelper.TYPE_INTEGER },
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
		static private const ORDER_HISTORY_TABLE:String = "order_history";
		static private const ORDER_HISTORY_FIELDS:Array = 
		[
			{ name: "orderID", type: SQLHelper.TYPE_INTEGER },
			{ name: "date", type: SQLHelper.TYPE_INTEGER },
			{ name: "action", type: SQLHelper.TYPE_TEXT }
		];
		private var _sql:SQLHelper = new SQLHelper;
		public function Data(singletonClass:Class)
		{
			if (singletonClass != SingletonClass) throw "hey this is a singleton";

			_sql.createTable(CUSTOMER_TABLE, CUSTOMER_FIELDS, false);
			_sql.createTable(ITEM_TABLE, ITEM_FIELDS, false);
			_sql.createTable(ORDER_TABLE, ORDER_FIELDS, false);
			_sql.createTable(ORDER_ITEMS_TABLE, ORDER_ITEM_FIELDS, false);
			_sql.createTable(ORDER_HISTORY_TABLE, ORDER_HISTORY_FIELDS, true);

//			addItem("Custom", 1);
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