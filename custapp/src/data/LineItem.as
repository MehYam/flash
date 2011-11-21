package data
{
	// a p.o.d - mostly
	public final class LineItem
	{
		public var id:int;
		public var itemID:int; 
		public var orderID:int;
		
		public var name:String;
		public var category:String;
		public var price:Number = 0;  // because the unit price may have been modified
		public var description:String;
		
		public var subItem:Boolean = false;
		public var quantity:int;
		public function get pieceQuantity():int
		{
			if( subItem )
				return 0;
			else
				return quantity;
		}
		
	}
}