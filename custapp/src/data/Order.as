package data
{
	import mx.collections.IList;
	import mx.collections.ListCollectionView;

	public class Order
	{
		public var creationTime:Number = new Date().date;

		public var id:int;
		public var customerID:int;
		public var date:Number = creationTime;
		public var time:String;
		public var ready:Boolean;
		public var pickedUp:Boolean;

		public var items:ListCollectionView;
		public var paid:Number = 0;
		
		public function get total():Number
		{
			var retval:Number = 0;
			for each (var item:Object in items)
			{
				retval += (item.price * item.count);
			}
			return retval;
		}
		public function get numItems():Number
		{
			var retval:Number = 0;
			for each (var item:Object in items)
			{
				retval += item.count;
			}
			return retval;
		}
		public function addProperty(itemIndex:int, prop:String):void
		{
			var item:Object = items.getItemAt(itemIndex);
			if (item.colors)
			{
				if (item.colors.indexOf(prop) == -1)
				{
					item.colors += ", " + prop;
				}
			}
			else
			{
				item.colors = prop;
			}
			items.refresh();
		}
		public function addItem(item:Object):void
		{
			// increment the number on the last item if it's the same
			var copy:Object =  // KAI: better way to do this, in my library
				{
					name: item.name,
						id: item.id,
						count: 1,
						price: item.price
				};
			items.addItem(copy);
			items.refresh();
		}
		public function incItem(index:int):void
		{
			var item:Object = items.getItemAt(index);
			++item.count;
			
			items.refresh();
		}
		public function decItem(index:int):void
		{
			var item:Object = items.getItemAt(index);
			--item.count;
			
			if (item.count <= 0)
			{
				items.removeItemAt(index);
			}
			items.refresh();
		}
	}
}