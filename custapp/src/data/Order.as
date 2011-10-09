package data
{
	import mx.collections.ArrayCollection;

	public class Order
	{
		public var creationTime:Number = new Date().time;

		public var id:int;
		public var customerID:int;
		public var pickupDate:Number = creationTime;
		public var pickupTime:String;
		public var ready:Boolean;
		public var pickedUp:Boolean;

		public var paid:Number = 0;

		public var items:ArrayCollection = new ArrayCollection([]);
		public var history:Array = [];

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
			const rawItem:Object = Data.instance.getRawItem(itemID);
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
			}
			items.refresh();
		}
	}
}