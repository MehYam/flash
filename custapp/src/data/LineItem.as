package data
{
	public final class LineItem
	{
		public var id:int;
		public var itemID:int; 
		public var orderID:int;
		
		public var price:Number = 0;  // because the unit price may have been modified
		public var quantity:int;
		public var description:String;
		
		// not serialized, only for UI display
		public var name:String;
		
		public function compare(rhs:LineItem):Boolean
		{
			return rhs.id == id &&
				rhs.itemID == itemID &&
				rhs.orderID == orderID &&
				rhs.price == price &&
				rhs.quantity == quantity &&
				rhs.description == description;
		}
		public function deepCopy():LineItem
		{
			var retval:LineItem = new LineItem;
			retval.id = id;
			retval.itemID = itemID;
			retval.orderID = orderID;
			retval.price = price;
			retval.quantity = quantity;
			retval.description = description;
			retval.name = name;
			return retval;
		}
	}
}