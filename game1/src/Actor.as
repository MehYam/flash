package
{
	import behaviors.ActorAttrs;
	import behaviors.AmmoFireSource;
	import behaviors.BehaviorFactory;
	import behaviors.CompositeBehavior;
	import behaviors.IBehavior;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.geom.Point;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;

	public class Actor implements IResettable
	{
		private var _alive:Boolean = true;

		public var displayObject:DisplayObject;
		public var speed:Point = new Point();
		public var worldPos:Point = new Point();
		public var attrs:ActorAttrs;

		// meta-data that really doesn't belong here
		public var health:Number;
		public var name:String;
		public var value:uint;

		public function Actor(dobj:DisplayObject, consts:ActorAttrs = null)
		{
			displayObject = dobj;
			if (displayObject is InteractiveObject)
			{
				InteractiveObject(dobj).mouseEnabled = false;
				if (displayObject is DisplayObjectContainer)
				{
					DisplayObjectContainer(dobj).mouseChildren = false;
				}
			}

			this.attrs = consts;
			
			health = ActorAttrs.MAX_HEALTH;
			value = ActorAttrs.DEFAULT_VALUE;
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
		public function onFrame(game:IGame):void
		{
			worldPos.offset(speed.x, speed.y);
			MathUtil.constrain(game.worldBounds, worldPos, 0, 0, speed);

			if (_behavior)
			{
				_behavior.onFrame(game, this);
			}
		}
		private function launchHelper(start:Point, radians:Number):void
		{
			Util.setPoint(worldPos, start);
			speed.x = Math.sin(radians) * attrs.MAX_SPEED;
			speed.y = -Math.cos(radians) * attrs.MAX_SPEED;
		}
		public function launchDegrees(start:Point, degrees:Number):void
		{
			launchHelper(start, MathUtil.degreesToRadians(degrees));
		}
		public function launch(start:Point, deltaX:Number, deltaY:Number):void
		{
			launchHelper(start, MathUtil.getRadiansRotation(deltaX, deltaY));
		}
		static private var s_bulletLevels:Array; 
		static public function createBullet(level:uint):Actor
		{
			if (!s_bulletLevels)
			{
				s_bulletLevels = [BulletActor0, BulletActor1, BulletActor2, BulletActor3, BulletActor4];
			}
			const type:Class = s_bulletLevels[level];
			var bullet:Actor = ActorPool.instance.get(type) as Actor;
			return bullet || new type;
		}
		static private var s_explLevels:Array;
		static public function createLaser(level:uint):Actor
		{
			if (!s_explLevels)
			{
				s_explLevels = [LaserActor0, LaserActor1, LaserActor2, LaserActor3, LaserActor4]; 
			}
			const type:Class = s_explLevels[level];
			var laser:Actor = ActorPool.instance.get(type) as Actor;
			return laser || new type;
		}
		static private var s_levels:Array; 
		static public function createExplosion(game:IGame, worldPos:Point, numParticles:uint, level:uint):void
		{
			if (!s_levels)
			{
				s_levels = [ExplosionParticleActor0, ExplosionParticleActor1, ExplosionParticleActor2];
			}
			const colorClass:Class = s_levels[level];
			for (var i:uint = 0; i < numParticles; ++i)
			{
				var actor:Actor = ActorPool.instance.get(colorClass) as Actor;
				if (!actor)
				{
					actor = new colorClass();
				}
				actor.displayObject.alpha = Math.random();
				Util.setPoint(actor.worldPos, worldPos);
				actor.speed.x = MathUtil.random(-10, 10);
				actor.speed.y = MathUtil.random(-10, 10);
				
				game.addEffect(actor);
			}
		}
		static public function createRocket():Actor
		{
			var rocket:Actor = ActorPool.instance.get(RocketActor);
			return rocket || new RocketActor(3);
		}
		static public function createFusionBlast():Actor
		{
			var blast:Actor = ActorPool.instance.get(FusionBlastActor);
			return blast || new FusionBlastActor;
		}
	}
}
import behaviors.ActorAttrs;
import behaviors.BehaviorFactory;
import behaviors.CompositeBehavior;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.utils.Dictionary;

import karnold.utils.Util;

import org.osmf.traits.DownloadableTrait;

import scripts.IPenetratingAmmo;

class BulletActor extends Actor
{
	public function BulletActor(color:uint):void
	{
		super(ActorAssetManager.createBullet(color), ActorAttrs.BULLET);
		behavior = new CompositeBehavior(BehaviorFactory.fade, BehaviorFactory.createExpire(ActorAttrs.BULLET.LIFETIME));
	}
}
class LaserActor extends Actor
{
	public function LaserActor(color:uint):void
	{
		super(ActorAssetManager.createLaser(color), ActorAttrs.LASER);
		behavior = new CompositeBehavior(BehaviorFactory.createExpire(ActorAttrs.LASER.LIFETIME), BehaviorFactory.faceForward);
	}
}
class ExplosionParticleActor extends Actor
{
	public function ExplosionParticleActor(color:uint):void
	{
		super(ActorAssetManager.createExplosionParticle(color), ActorAttrs.EXPLOSION);
		behavior = new CompositeBehavior(BehaviorFactory.createExpire(ActorAttrs.EXPLOSION.LIFETIME), BehaviorFactory.fade);
	}
}
class RocketActor extends Actor
{
	static private function composeRocket(index:uint):DisplayObject
	{
		var parent:Sprite = new Sprite;
		
		var rocket:DisplayObject = ActorAssetManager.createRocket(index);
		var plume:DisplayObject = ActorAssetManager.createFlame();
		
		Util.centerChild(rocket, parent);
		Util.centerChild(plume, parent);
		plume.y = rocket.y + rocket.height;
		
		parent.addChild(plume);
		parent.addChild(rocket);
		return parent;
	}
	
	private var _plume:DisplayObject;
	public function RocketActor(rocket:uint)
	{
		super(composeRocket(rocket), ActorAttrs.ROCKET);
		behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.createExpire(ActorAttrs.BULLET.LIFETIME));
		
		_plume = DisplayObjectContainer(displayObject).getChildAt(0);
		displayObject.scaleX = 0.5;
		displayObject.scaleY = 0.5;
	}
	public override function onFrame(game:IGame):void
	{
		_plume.scaleY = Math.random()*0.7 + 0.3;
		super.onFrame(game);
	}
}
class FusionBlastActor extends Actor implements IPenetratingAmmo
{
	public function FusionBlastActor()
	{
		super(ActorAssetManager.createFusionBlast(), ActorAttrs.FUSIONBLAST);
		behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.createExpire(ActorAttrs.BULLET.LIFETIME));
	}
	private var _struckActors:Dictionary = new Dictionary(true);
	public function strikeActor(actor:Actor):void
	{
		_struckActors[actor] = true;
	}
	public function isActorStruck(actor:Actor):Boolean
	{
		return _struckActors[actor];
	}
	public override function reset():void
	{
		super.reset();
		_struckActors = new Dictionary(true);
	}
}

// We use actor type as the key to pool with.  So, we have to do this stupid thing below, or else find
// a different pooling mechanism (maybe pooling the display objects separately)
final class BulletActor0 extends BulletActor { public function BulletActor0() { super(0x90ff); } }
final class BulletActor1 extends BulletActor { public function BulletActor1() { super(0xff5d); } }
final class BulletActor2 extends BulletActor { public function BulletActor2() { super(0xeeee00); } }
final class BulletActor3 extends BulletActor { public function BulletActor3() { super(0xff9400); } }
final class BulletActor4 extends BulletActor { public function BulletActor4() { super(0xffffff); } }
final class LaserActor0 extends LaserActor { public function LaserActor0() { super(0x90ff); } }
final class LaserActor1 extends LaserActor { public function LaserActor1() { super(0xff5d); } }
final class LaserActor2 extends LaserActor { public function LaserActor2() { super(0xeeee00); } }
final class LaserActor3 extends LaserActor { public function LaserActor3() { super(0xff9400); } }
final class LaserActor4 extends LaserActor { public function LaserActor4() { super(0xffffff); } }
final class ExplosionParticleActor0 extends ExplosionParticleActor { public function ExplosionParticleActor0() { super(0xff0000); } }
final class ExplosionParticleActor1 extends ExplosionParticleActor { public function ExplosionParticleActor1() { super(0xffff00); } }
final class ExplosionParticleActor2 extends ExplosionParticleActor { public function ExplosionParticleActor2() { super(0xffffff); } }
