package
{
	import mx.collections.ArrayCollection;

	public class Data
	{
		static private var s_instance:Data = new Data;
		static public function get instance():Data
		{
			return s_instance;
		}

		public const customers:ArrayCollection = new ArrayCollection;
		
		private var _id:int = 0;
		private function add(first:String, last:String, phone:String, notes:String):void
		{
			customers.addItem({ first:first, last:last, phone:phone, notes:notes, id:_id++});
		}
		public function Data()
		{
			customers.source = [];
			add("Joe", "Smith", "6509966759", null);
			add("Sandra", "Jones", "4155556666", null);
			add("Joe", "Everybody", "2342345", null);
			add("Steve", "Nobody", "2123334444", null);
			add("Captain", "America", "6508876655", null);
			add("The", "Dude", "3412543123", "Frequent rug cleanings");
			add("", "Foo", "1231234", null);
		}
	}
}