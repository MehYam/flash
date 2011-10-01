package data
{
	public class Order
	{
		public var creationTime:Number = new Date().date;

		public var id:int;
		public var customerID:int;
		public var date:Number = creationTime;
		public var time:String;
		public var ready:Boolean;
		public var paid:Boolean;
		public var pickedUp:Boolean;
		public var items:Array;
	}
}