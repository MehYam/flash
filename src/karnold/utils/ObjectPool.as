package karnold.utils
{
	public class ObjectPool
	{
		private var _pool:Array = [];
		public function ObjectPool()
		{
		}
		
		public function put(obj:Object):void
		{
			_pool.push(obj);
		}
		public function get():Object
		{
			return _pool.shift();
		}
		public function get size():uint
		{
			return _pool.length;
		}
	}
}