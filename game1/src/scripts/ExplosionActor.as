package scripts
{
	import behaviors.ActorAttrs;
	import behaviors.BehaviorFactory;
	import behaviors.CompositeBehavior;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import karnold.utils.MathUtil;
	
	public final class ExplosionActor extends Actor
	{
		static private const s_attrs:ActorAttrs = new ActorAttrs(0, 2, 0, 0.05, 0, 0, null, 2000);
		
		private var _flash:DisplayObject;
		private var _smoke:Vector.<DisplayObject> = new Vector.<DisplayObject>;
		private var _velocities:Vector.<Number> = new Vector.<Number>;
		public function ExplosionActor()
		{
			// KAI: would be a lot better to spawn these all off as separate actors?
			// yes - then we could get rid of SmallExplosionActor
			var parent:Sprite = new Sprite;
			super(parent, s_attrs);
			
			for (var i:uint = 0; i < 4; ++i)
			{
				var obj:DisplayObject = ActorAssetManager.createSmoke(0);
				_smoke.push(obj);
				
				parent.addChild(obj);
			}
			_smoke.push(ActorAssetManager.createSmoke(1));
			_smoke.push(ActorAssetManager.createSmoke(1));
			parent.addChild(_smoke[_smoke.length-2]);
			parent.addChild(_smoke[_smoke.length-1]);
			
			_flash = ActorAssetManager.createExplosion(Math.random() * 5);
			parent.addChild(_flash);
//			behavior = BehaviorFactory.createExpire(s_attrs.LIFETIME);
			reset();
		}
		public override function reset():void
		{
			super.reset();
			
			if (_flash)
			{
				_flash.scaleX = _flash.scaleY = 0;
				_flash.alpha = 0.25;
				
				var i:uint = 0;
				for each (var smoke:DisplayObject in _smoke)
				{
					smoke.x = 0;
					smoke.y = 0;
					smoke.alpha = 1;
					
					_velocities[i++] = Math.random() * 4;
				}
				displayObject.rotation = Math.random() * 360;
			}
		}
		public override function onFrame(game:IGame):void
		{
			super.onFrame(game);
			
			if (_flash.scaleX < 1)
			{
				_flash.scaleX += 0.1;
				_flash.scaleY += 0.1;
				_flash.alpha += 0.1; 
			}
			else
			{
				_flash.alpha = 0;
			}
			_smoke[0].x -= _velocities[0];
			_smoke[0].y -= _velocities[0];
			_smoke[1].x += _velocities[1];
			_smoke[1].y -= _velocities[1];
			_smoke[2].x += _velocities[2];
			_smoke[2].y += _velocities[2];
			_smoke[3].x -= _velocities[3];
			_smoke[3].y += _velocities[3];
			_smoke[4].y -= _velocities[4];
			_smoke[5].y += _velocities[5];
			for each (var smoke:DisplayObject in _smoke)
			{
				smoke.alpha -= 0.035;
			}
			if (smoke.alpha < 0.1)
			{
				alive = false;
			}
		}
		static public function launch(game:IGame, worldX:Number, worldY:Number):void
		{
			var e:Actor = ActorPool.instance.getOrCreate(ExplosionActor);
			
			e.worldPos.x = worldX;
			e.worldPos.y = worldY;
			game.addEffect(e);
		}
	}
}