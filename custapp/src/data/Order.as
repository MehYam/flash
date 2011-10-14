package data
{
	import mx.collections.ArrayCollection;

	public class Order
	{
		public var id:int;
		public var creationTime:Number = new Date().time;
		
		private var _customerID:int;
		private var _pickupTime:Number = creationTime;
		private var _ready:Boolean;
		private var _pickedUp:Boolean;
		private var _paid:Number = 0;

		// serialized out manually in the writeOrder call
		private var _items:ArrayCollection = new ArrayCollection([]);

		// serialized in lazily
		public var history:ArrayCollection = new ArrayCollection([]);
		
		// not serialized
		public var lineItemRecordsToPurge:Vector.<int>; // constructed lazily

		private var _dirty:Boolean = false;
		public function get dirty():Boolean
		{
			return _dirty;
		}
		public function set dirty(b:Boolean):void
		{
			_dirty = b;
		}
		/**
		 *
		 * DO NOT MODIFY THIS DATA DIRECTLY - bad design but I'm forced to expose this for now.  Use the
		 * LineItem methods of Order to modify line items. 
		 * 
		 */
		public function get items():ArrayCollection { return _items; }
		public function get paid():Number
		{
			return _paid;
		}
		public function set paid(value:Number):void
		{
			if (_paid != value)
			{
				_paid = value;
				dirty = true;
			}
		}
		public function get pickedUp():Boolean
		{
			return _pickedUp;
		}
		public function set pickedUp(value:Boolean):void
		{
			if (_pickedUp != value)
			{
				_pickedUp = value;
				dirty = true;
			}
		}
		public function get ready():Boolean
		{
			return _ready;
		}
		public function set ready(value:Boolean):void
		{
			if (_ready != value)
			{
				_ready = value;
				dirty = true;
			}
		}
		public function get pickupTime():Number
		{
			return _pickupTime;
		}
		public function set pickupTime(value:Number):void
		{
			if (_pickupTime != value)
			{
				_pickupTime = value;
				dirty = true;
			}
		}
		public function get customerID():int
		{
			return _customerID;
		}
		public function set customerID(value:int):void
		{
			if (_customerID != value)
			{
				_customerID = value;
				dirty = true;
			}
		}

		public function get total():Number
		{
			var retval:Number = 0;
			for each (var item:LineItem in _items)
			{
				retval += (item.price * item.quantity);
			}
			return retval;
		}
		public function get numItems():Number
		{
			var retval:Number = 0;
			for each (var item:LineItem in _items)
			{
				retval += item.quantity;
			}
			return retval;
		}
		public function addProperty(itemIndex:int, prop:String):void
		{
			var item:LineItem = LineItem(_items.getItemAt(itemIndex));
			if (item.description)
			{
				if (item.description.indexOf(prop) == -1)
				{
					item.description += ", " + prop;
					dirty = true;
				}
			}
			else
			{
				item.description = prop;
				dirty = true;
			}
			_items.refresh();
		}
		public function addLineItem(itemID:int):void
		{
			const rawItem:Object = Data.instance.getRawItem(itemID);
			var lineItem:LineItem = Data.instance.createLineItem(itemID, id, rawItem.name, rawItem.price);

			_items.addItem(lineItem);
			dirty = true;
			_items.refresh();
		}
		public function incItem(index:int):void
		{
			var item:LineItem = LineItem(_items.getItemAt(index));
			++item.quantity;

			dirty = true;
			_items.refresh();
		}
		public function decItem(index:int):void
		{
			var item:LineItem = LineItem(_items.getItemAt(index));
			--item.quantity;
		
			dirty = true;
			if (item.quantity <= 0)
			{
				_items.removeItemAt(index);
				if (!lineItemRecordsToPurge)
				{
					lineItemRecordsToPurge = new Vector.<int>;
				}
				lineItemRecordsToPurge.push(item.id);
			}
			_items.refresh();
		}
	}
}