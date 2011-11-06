package data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.globalization.CurrencyParseResult;
	import flash.net.SharedObject;
	
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
	// Also, we're not doing things atomically enough, splitting updates into multiple DB calls, etc
	final public class Data
	{
		static public const BAR_HEIGHT:Number = 40;
		static public function get settings():SharedObject
		{
			return SharedObject.getLocal("custapp.0");
		}
		
		static private var s_instance:Data;
		static public function get instance():Data
		{
			if (!s_instance)
			{
				s_instance = new Data(SingletonClass);
			}
			return s_instance;
		}

		static public const EVENT_ORDERS_LOADED:String = "custapp.ui.data.EventOrdersLoaded";
		static public const EVENT_INVENTORY_LOADED:String = "custapp.ui.data.EventInventoryLoaded";
		// dispatches ORDERS_LOADED once all Orders are created so that we know when it's safe to start
		// allocating id's for them.  This is entirely a hack due to the fact that we're trying to make
		// id's unique on the database's behalf instead of asking it to do that for us.
		public const events:EventDispatcher = new EventDispatcher;

		// Collections for UI components to bind to
		public const customers:ArrayCollection = new ArrayCollection([]);
		public const inventoryItems:ArrayCollection = new ArrayCollection([]);
		public const inventoryItemCats:ArrayList = new ArrayList(["Dry Clean", "Laundry", "Alteration"]);
		public const orders:ArrayCollection = new ArrayCollection([]);
		public const colors:ArrayList = new ArrayList([]);
		public const patterns:ArrayList = new ArrayList([]);

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
		static private const INVENTORY_ITEMS_TABLE:String = "items";
		static private const INVENTORY_ITEM_FIELDS:Array = 
		[
			{ name: "name", type: SQLHelper.TYPE_TEXT },
			{ name: "price", type: SQLHelper.TYPE_REAL },
			{ name: "category", type: SQLHelper.TYPE_TEXT }
		];
		static private const ORDER_TABLE:String = "orders";
		static private const ORDER_FIELDS:Array =
		[
			{ name: "customerID", type: SQLHelper.TYPE_INTEGER },
			{ name: "creationTime", type: SQLHelper.TYPE_INTEGER },
			{ name: "pickupTime", type: SQLHelper.TYPE_INTEGER },
			{ name: "status", type: SQLHelper.TYPE_TEXT },
			{ name: "paid", type: SQLHelper.TYPE_REAL }
		];
		static private const ORDER_ITEMS_TABLE:String = "order_items";
		static private const ORDER_ITEM_FIELDS:Array =
		[
			{ name: "itemID", type: SQLHelper.TYPE_INTEGER },
			{ name: "orderID", type: SQLHelper.TYPE_INTEGER },
			{ name: "price", type: SQLHelper.TYPE_REAL },
			{ name: "quantity", type: SQLHelper.TYPE_INTEGER },
			{ name: "description", type: SQLHelper.TYPE_TEXT },
			{ name: "category", type: SQLHelper.TYPE_TEXT },
			{ name: "name", type: SQLHelper.TYPE_TEXT }

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
			if (!settings.data.maxTabItems)
			{
				settings.data.maxTabItems = 25;
			}
			if (singletonClass != SingletonClass) throw "hey this is a singleton";
			
			_sql.createTable(CUSTOMER_TABLE, CUSTOMER_FIELDS, false);
			_sql.createTable(INVENTORY_ITEMS_TABLE, INVENTORY_ITEM_FIELDS, false);
			_sql.createTable(ORDER_TABLE, ORDER_FIELDS, false);
			_sql.createTable(ORDER_ITEMS_TABLE, ORDER_ITEM_FIELDS, false);
			_sql.createTable(ORDER_HISTORY_TABLE, ORDER_HISTORY_FIELDS, true);
			
			_sql.readTable(CUSTOMER_TABLE, onCustomers);
			_sql.readTable(INVENTORY_ITEMS_TABLE, onItems);
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
		public function createOrder(customerID:int, pickupTime:Number):Order
		{
			var retval:Order = new Order;
			retval.id = nextID;
			retval.customerID = customerID;
			retval.pickupTime = pickupTime;
			return retval;
		}
		public function createInventoryItem(name:String, price:Number, category:String):InventoryItem
		{
			var retval:InventoryItem = new InventoryItem;
			retval.id = nextID;
			retval.name = name;
			retval.price = price;
			retval.category = category
			return retval;
		}
		public function createLineItem(itemID:int, orderID:int, category:String, name:String, price:Number):LineItem
		{
			var retval:LineItem = new LineItem;
			retval.id = nextID;
			retval.itemID = itemID;
			retval.orderID = orderID;
			retval.price = price;
			retval.name = name;
			retval.quantity = 1;
			retval.category = category;
			return retval;
		}

		private var _id:int = 0;
		public function get nextID():int { return _id++; }
		public function writeCustomer(customer:Object):void
		{
			writeAndCacheRecord(CUSTOMER_TABLE, customers, customer);
		}
		public function writeInventoryItem(item:InventoryItem):void
		{
			writeAndCacheRecord(INVENTORY_ITEMS_TABLE, inventoryItems, item);
			signalInventoryChanged();			
		}
		// hack - alert views (the command buttons) that this has changed
		public function signalInventoryChanged():void
		{
			events.dispatchEvent(new Event(EVENT_INVENTORY_LOADED));
		}
		public function deleteInventoryItems():void
		{
			// nuke our item table
			inventoryItems.removeAll();
			_sql.clearTable(INVENTORY_ITEMS_TABLE);
		}
		public function bulkWriteInventoryItems(encodedItems:String):Boolean
		{
			// do the parsing first - return errors if found
			var parsedItems:Vector.<InventoryItem> = new Vector.<InventoryItem>;
			const lines:Array = encodedItems.split("\n");
			for each (var line:String in lines)
			{
				const columns:Array = line.split("\t");
				if (columns.length >= 3 && columns[2].length)
				{
					const result:CurrencyParseResult = Utils.currencyFormatter.parse(columns[1]);
					if (isNaN(result.value))
					{
						return false;
					}
					parsedItems.push(createInventoryItem(columns[0], result.value, columns[2]));
				}
			}
			
			if (parsedItems.length)
			{
				for each (var item:InventoryItem in parsedItems)
				{
					writeAndCacheRecord(INVENTORY_ITEMS_TABLE, inventoryItems, item);
				}
				// hack - alert views (the command buttons) that this has changed
				signalInventoryChanged();			
				return true;
			}
			return false;
		}
		public function writeOrder(order:Order):void
		{
			// write/rewrite line items
			var lineItemLookup:Object = {};
			for each (var lineItem:LineItem in order.items)
			{
				lineItemLookup[lineItem.id] = true;
				_sql.writeRecord(ORDER_ITEMS_TABLE, lineItem);
			}
			// remove any that were deleted
			for each (var exLineItem:LineItem in order.deletedItems)
			{
				_sql.deleteRecord(ORDER_ITEMS_TABLE, exLineItem.id);
			}
			order.deletedItems.length = 0;

			writeAndCacheRecord(ORDER_TABLE, orders, order);
		}
		static private function createOrderHistory(id:int, time:Number, action:String):Object
		{
			const retval:Object =
			{
				orderID: id,
				date:    time,
				action:  action
			};
			return retval;
		}
		public function writeOrderHistory(order:Order, message:String):void
		{
			const obj:Object = createOrderHistory(order.id, new Date().time, message);
			writeAndCacheRecord(ORDER_HISTORY_TABLE, order.history, obj);
			
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
		public function deleteOrder(order:Order):void
		{
			_sql.deleteRecordsFor(ORDER_ITEMS_TABLE, "orderID", order.id);
			_sql.deleteRecordsFor(ORDER_HISTORY_TABLE, "orderID", order.id);
			_sql.deleteRecord(ORDER_TABLE, order.id);
			
			orders.removeItemAt(lookupIndexByID(orders, order.id));
			orders.refresh();
		}
		public function deleteInventoryItem(inventoryItem:InventoryItem):void
		{
			_sql.deleteRecord(INVENTORY_ITEMS_TABLE, inventoryItem.id);
			
			inventoryItems.removeItemAt(lookupIndexByID(inventoryItems, inventoryItem.id));
			inventoryItems.refresh();
		}
		public function getCustomer(customerID:int):Object
		{
			return lookupObjectByID(customers, customerID);
		}
		public function getInventoryItem(itemID:int):InventoryItem
		{
			return InventoryItem(lookupObjectByID(inventoryItems, itemID));
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
		private function writeAndCacheRecord(table:String, collection:IList, obj:Object):void
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
		private function addColor(name:String, color:uint):void
		{
			colors.addItem({ name:name, color:color });
		}
		private function addPattern(name:String):void
		{
			patterns.addItem(name);
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
				Util.error("No data for table '" + tableName + "'");
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
						_id = record.id + 1;
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
				Util.error("No data for table '" + tableName + "'");
			}
		}
		private function onCustomers(data:Array):void
		{
			loadDataToCollection(customers, data, CUSTOMER_TABLE);
		}
		private function onItems(data:Array):void
		{
			loadTypedDataToCollection(inventoryItems, data, INVENTORY_ITEMS_TABLE, INVENTORY_ITEM_FIELDS, InventoryItem);
			inventoryHasLoaded = true;
			events.dispatchEvent(new Event(EVENT_INVENTORY_LOADED));
		}
		public var ordersHaveLoaded:Boolean = false;  // going to hell
		public var inventoryHasLoaded:Boolean = false;
		private function onOrders(data:Array):void
		{
			loadTypedDataToCollection(orders, data, ORDER_TABLE, ORDER_FIELDS, Order);
			for each (var order:Order in orders)
			{
				// load the items for each order
				_sql.readTableForColumn(ORDER_ITEMS_TABLE, "orderID", order.id, onOrderItems);
			}
			ordersHaveLoaded = true;
			events.dispatchEvent(new Event(EVENT_ORDERS_LOADED));
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
					Util.error("no order for items with orderID", orderID);
				}
			}
		}
	}
}

internal final class SingletonClass {}