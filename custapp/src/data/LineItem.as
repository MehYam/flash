package data
{
	// a p.o.d
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
	}
}