package
{
	import behaviors.CompositeBehavior;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	import behaviors.IBehavior;
	import behaviors.BehaviorConsts;
	import behaviors.BehaviorFactory;

	public class Actor implements IResettable
	{
		private var _alive:Boolean = true;

		public var name:String;
		public var displayObject:DisplayObject;
		public var speed:Point = new Point();
		public var worldPos:Point = new Point();
		public var consts:BehaviorConsts;
		public var health:Number;
		public function Actor(dobj:DisplayObject, consts:BehaviorConsts = null)
		{
			displayObject = dobj;
			this.consts = consts;
			
			health = BehaviorConsts.PLAYER_HEALTH;
		}
		
		private var _behavior:IBehavior;
		public function set behavior(b:IBehavior):void
		{
			_behavior = b;
		}
		public function reset():void  // IResettable
		{
			var resettableBehavior:IResettable = _behavior as IResettable;
			if (resettableBehavior)
			{
				resettableBehavior.reset();
			}
			displayObject.alpha = 1;
			_alive = true;
		}
		public function get alive():Boolean
		{
			return _alive;
		}
		public function set alive(b:Boolean):void
		{
			if (_alive != b && !b)
			{
				Util.stopAllMovieClips(displayObject);

				if (displayObject.parent)
				{
					displayObject.parent.removeChild(displayObject);
				}
			}
			_alive = b;
		}
		public function onFrame(gameState:IGame):void
		{
			if (_behavior)
			{
				_behavior.onFrame(gameState, this);
			}
		}
		private function launchHelper(start:Point, radians:Number):void
		{
			Util.setPoint(worldPos, start);
			speed.x = Math.sin(radians) * consts.MAX_SPEED;
			speed.y = -Math.cos(radians) * consts.MAX_SPEED;
		}
		public function launchDegrees(start:Point, degrees:Number):void
		{
			launchHelper(start, MathUtil.degreesToRadians(degrees));
		}
		public function launch(start:Point, deltaX:Number, deltaY:Number):void
		{
			launchHelper(start, MathUtil.getRadiansRotation(deltaX, deltaY));
		}

		static public function createBullet():Actor
		{
			var bullet:Actor = ActorPool.instance.get(BulletActor) as BulletActor;
			if (!bullet)
			{
				bullet = new BulletActor(SimpleActorAsset.createBullet());
				bullet.behavior = new CompositeBehavior(BehaviorFactory.fade, BehaviorFactory.createExpire(BehaviorConsts.BULLET_LIFETIME));
			}
			return bullet;
		}
		static public function createLaser():Actor
		{
			var laser:Actor = ActorPool.instance.get(LaserActor) as LaserActor
			if (!laser)
			{
				laser = new LaserActor(SimpleActorAsset.createLaser());
				laser.behavior = new CompositeBehavior(BehaviorFactory.createExpire(BehaviorConsts.LASER_LIFETIME), BehaviorFactory.faceForward);
			}
			return laser;
		}
		static public function createExplosion(game:IGame, worldPos:Point, numParticles:uint):void
		{
			for (var i:uint = 0; i < numParticles; ++i)
			{
				var actor:Actor = ActorPool.instance.get(ExplosionParticleActor) as ExplosionParticleActor;
				if (!actor)
				{
					actor = new ExplosionParticleActor(SimpleActorAsset.createExplosionParticle(0xffff00));
				}
				actor.displayObject.alpha = Math.random();
				Util.setPoint(actor.worldPos, worldPos);
				actor.speed.x = MathUtil.random(-10, 10);
				actor.speed.y = MathUtil.random(-10, 10);
				actor.behavior = new CompositeBehavior(BehaviorFactory.createExpire(BehaviorConsts.EXPLOSION_LIFETIME), BehaviorFactory.fade);
				
				game.addEffect(actor);
			}
		}
	}
}
import behaviors.BehaviorConsts;

import flash.display.DisplayObject;

final class BulletActor extends Actor
{
	public function BulletActor(dobj:DisplayObject)
	{
		super(dobj, BehaviorConsts.BULLET);
	}
}
final class ExplosionParticleActor extends Actor
{
	public function ExplosionParticleActor(dobj:DisplayObject):void
	{
		super(dobj, BehaviorConsts.EXPLOSION);
	}
}
final class CriticalExplosionParticleActor extends Actor
{
	public function CriticalExplosionParticleActor(dobj:DisplayObject):void
	{
		super(dobj, BehaviorConsts.EXPLOSION);
	}
}
final class LaserActor extends Actor
{
	public function LaserActor(dobj:DisplayObject):void
	{
		super(dobj, BehaviorConsts.LASER);
	}
}
final class HighLaserActor extends Actor
{
	public function HighLaserActor(dobj:DisplayObject):void
	{
		super(dobj, BehaviorConsts.LASER);
	}
}