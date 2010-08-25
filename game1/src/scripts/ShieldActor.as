package scripts
{
	import behaviors.ActorAttrs;
	import behaviors.BehaviorFactory;
	import behaviors.CompositeBehavior;
	import behaviors.IBehavior;
	
	import flash.display.DisplayObject;
	
	import karnold.utils.Util;
	
	public final class ShieldActor extends Actor
	{
		static public function create(attrs:ActorAttrs):Actor
		{
			var shield:Actor = ActorPool.instance.get(ShieldActor) || new ShieldActor();
			shield.attrs = attrs;
			shield.reset(); // hack hack hack hack hack..... this to get recycled ShieldActors to have the right stats
			return shield;
		}

		// sucks the way this is done.  Half is in BehaviorFactory and the other half here.  Totally un-reusable for enemies
		static private var s_trackingBehavior:IBehavior;
		public function ShieldActor()
		{
			//KAI: hide constructor
			super(ActorAssetManager.createShield(), null); // hack ahckka hkshadchakhck
			if (!s_trackingBehavior)
			{
				s_trackingBehavior = new CompositeBehavior(BehaviorFactory.shadowPlayer, BehaviorFactory.fadeIn);
			}
			behavior = s_trackingBehavior;
		}
		private var _released:Boolean = false;
		public function release(game:IGame):void
		{
			_released = true;
			
			// release self
			Util.setPoint(speed, game.player.speed);
			BehaviorFactory.faceForward.onFrame(game, this);
			
			displayObject.alpha = 1;
			behavior = new CompositeBehavior(BehaviorFactory.createExpire(1000), BehaviorFactory.fade);
		}
		public override function registerHit(game:IGame, hard:Boolean):void
		{
			super.registerHit(game, hard);
			if (!_released)
			{
				game.scoreBoard.pctShield = health / attrs.MAX_HEALTH;
			}
		}
		public override function reset():void
		{
			super.reset();
			_released = false;
			displayObject.alpha = 0;
			behavior = s_trackingBehavior;
		}
	}
}