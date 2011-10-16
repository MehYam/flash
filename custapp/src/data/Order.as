package data
{
	import mx.collections.ArrayCollection;

	// a p.o.d
	public class Order
	{
		public var id:int;
		public var creationTime:Number = new Date().time;
		
		public var customerID:int;
		public var pickupTime:Number = creationTime;
		public var ready:Boolean;
		public var pickedUp:Boolean;
		public var paid:Number = 0;

		// serialized out manually in the writeOrder call
		public const items:ArrayCollection = new ArrayCollection([]);
		public const deletedItems:Vector.<LineItem> = new Vector.<LineItem>;

		// serialized in lazily
		public const history:ArrayCollection = new ArrayCollection([]);

		// works, but isn't used
//		public function compare(rhs:Order):Boolean
//		{
//			return rhs.id == id &&
//				rhs.creationTime == creationTime &&
//				rhs.customerID == customerID &&
//				rhs.pickupTime == pickupTime &&
//				rhs.ready == ready &&
//				rhs.pickedUp == pickedUp &&
//				rhs.paid == paid &&
//				compareItems(rhs);
//		}
//		public function deepCopy():Order
//		{
//			var newOrder:Order = new Order;
//			newOrder.creationTime = creationTime;
//			newOrder.customerID = customerID;
//			newOrder.history.source = history.source.slice();
//			newOrder.id = id;
//			newOrder.paid = paid;
//			newOrder.pickedUp = pickedUp;
//			newOrder.pickupTime = pickupTime;
//			newOrder.ready = ready;
//			for each (var lineItem:LineItem in items)
//			{
//				newOrder.items.addItem(lineItem.deepCopy());
//			}
//			return newOrder;
//		}

		public function get total():Number
		{
			var retval:Number = 0;
			for each (var item:LineItem in items)
			{
				retval += (item.price * item.quantity);
			}
			return retval;
		}
		public function get numItems():Number
		{
			var retval:Number = 0;
			for each (var item:LineItem in items)
			{
				retval += item.quantity;
			}
			return retval;
		}
		public function addProperty(itemIndex:int, prop:String):void
		{
			var item:LineItem = LineItem(items.getItemAt(itemIndex));
			if (item.description)
			{
				if (item.description.indexOf(prop) == -1)
				{
					item.description += ", " + prop;
				}
			}
			else
			{
				item.description = prop;
			}
			items.refresh();
		}
		public function addLineItem(itemID:int):void
		{
			const rawItem:Object = Data.instance.getInventoryItem(itemID);
			var lineItem:LineItem = Data.instance.createLineItem(itemID, id, rawItem.name, rawItem.price);

			items.addItem(lineItem);
			items.refresh();
		}
		public function incItem(index:int):void
		{
			var item:LineItem = LineItem(items.getItemAt(index));
			++item.quantity;

			items.refresh();
		}
		public function decItem(index:int):void
		{
			var item:LineItem = LineItem(items.getItemAt(index));
			--item.quantity;
		
			if (item.quantity <= 0)
			{
				items.removeItemAt(index);
				deletedItems.push(item);
			}
			items.refresh();
		}
	}
}