package scripts
{
	import behaviors.ActorAttrs;
	import behaviors.BehaviorFactory;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class SmallExplosionActor extends Actor
	{
		static private const s_attrs:ActorAttrs = new ActorAttrs(0, 2, 0, 0.4, 0, 0, null, 2000);

		//KAI: major copy pasta between this and ExplosionActor.  We need to have better actor management
		// so that it's easier to wire up actors, assets, and behaviors in a data-driven fashion
		private var _flash:DisplayObject;
		public function SmallExplosionActor()
		{
			var parent:Sprite = new Sprite;
			super(parent, s_attrs);
			
			behavior = BehaviorFactory.speedDecay; 
				
			_flash = ActorAssetManager.createSmallExplosion(Math.random() * 2);
			parent.addChild(_flash);
			
			reset();
		}
		public override function reset():void
		{
			super.reset();
			
			if (_flash)
			{
				_flash.scaleX = _flash.scaleY = 0;
				_flash.alpha = 0.75;
				displayObject.rotation = Math.random() * 360;
			}
		}
		public override function onFrame(game:IGame):void
		{
			super.onFrame(game);
			
			if (_flash.scaleX < 1)
			{
				_flash.scaleX += 0.05;
				_flash.scaleY += 0.05;
			}
			else
			{
				alive = false;
			}
		}
		//KAI: "launch" could actually be a static utility in Actor itself 
		static public function launch(game:IGame, worldPos:Point, initialSpeed:Point):void
		{
			var e:Actor = ActorPool.instance.getOrCreate(SmallExplosionActor);
			
			e.worldPos.x = worldPos.x;
			e.worldPos.y = worldPos.y;
			e.speed.x = initialSpeed.x;
			e.speed.y = initialSpeed.y;
			
			game.addEffect(e);
		}	
	}
}