package
{
	import flash.utils.Dictionary;
	
	import karnold.utils.ObjectPool;
	import karnold.utils.Util;

	public final class ActorPool
	{
		static private var _instance:ActorPool = new ActorPool;
		static public function get instance():ActorPool
		{
			return _instance;
		}
		private var _pools:Dictionary = new Dictionary;
		private var _pooled:uint = 0;
		public function get(type:Object):Actor
		{
			var pool:ObjectPool = _pools[type] as ObjectPool;
			if (pool)
			{
				var actor:Actor = pool.get() as Actor;
				if (actor)
				{
					--_pooled;
					actor.reset();
					return actor;
				}
			}
			return null;
		}
		public function getOrCreate(clss:Class):Actor
		{
			return Actor(get(clss) || new clss);
		}
		public function recycle(actor:Actor):void
		{
			Util.ASSERT(!actor.alive && !actor.displayObject.parent);
			
			const type:Class = actor["constructor"];
			if (type != Actor)
			{
				var pool:ObjectPool = _pools[type] as ObjectPool;
				if (!pool)
				{
					pool = new ObjectPool;
					_pools[type] = pool;
				}
				
				pool.put(actor);
				++_pooled;
			}
		}
		public function get size():uint
		{
			return _pooled;
		}
	}
}