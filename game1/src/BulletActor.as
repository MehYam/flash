package
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	import behaviors.CompositeBehavior;

	public final class BulletActor extends Actor // this type exists only so that we know we can pool it
	{
		public function BulletActor(dobj:DisplayObject)
		{
			super(dobj, BehaviorConsts.BULLET);
		}
		static public function create():Actor
		{
			var bullet:Actor = ActorPool.instance.get(BulletActor) as BulletActor;
			if (!bullet)
			{
				//KAI: I really really don't like this.  There was something nice about making Actor final,
				// see if there's an alternative to using type this way.  Think about object pooling some more,
				// there are a variety of choices to be made about who does the pooling, who implements the
				// interfaces, etc.  Instead of giving the class a type, it could be given a reference to
				// a memory manager, so that it recycles itself.  Then, when you want the instance of some
				// object "type", you go to the right provider to get it.  IObjectPoolable, etc.
				bullet = new BulletActor(SimpleActorAsset.createBullet());
				bullet.behavior = new CompositeBehavior(BehaviorFactory.fade, BehaviorFactory.createExpire(BehaviorConsts.BULLET_LIFETIME));
			}
			return bullet;
		}
	}
}