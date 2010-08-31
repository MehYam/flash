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
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import karnold.ui.ProgressMeter;
	import karnold.utils.MathUtil;
	import karnold.utils.ObjectPool;
	import karnold.utils.Util;

	public class Actor implements IResettable
	{
		public var displayObject:DisplayObject;
		public var speed:Point = new Point();
		public var worldPos:Point = new Point();

		// meta-data that maybe doesn't belong here
		public var attrs:ActorAttrs;
		public var health:Number;
		public var damage:Number;
		public var name:String;

		public var healthMeterEnabled:Boolean = true;
		public function Actor(dobj:DisplayObject, attrs:ActorAttrs = null)
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

			this.attrs = attrs;
			reset();
		}
		private var _alive:Boolean = true;
		public function reset():void  // IResettable
		{
			if (attrs)
			{
				health = attrs.MAX_HEALTH;
				damage = attrs.DAMAGE;
			}

			var resettableBehavior:IResettable = _behavior as IResettable;
			if (resettableBehavior)
			{
				resettableBehavior.reset();
			}
			displayObject.alpha = 1;
			_alive = true;
		}
		
		private var _behavior:IBehavior;
		public function set behavior(b:IBehavior):void
		{
			_behavior = b;
		}
		public function get alive():Boolean
		{
			return _alive;
		}
		public function set alive(b:Boolean):void
		{
			if (_alive != b && !b)
			{
				if (displayObject.parent)
				{
					displayObject.parent.removeChild(displayObject);
				}
				cleanupHealthMeter();
			}
			_alive = b;
		}
		private function cleanupHealthMeter():void
		{
			if (_healthMeter)
			{
				_healthMeter.parent.removeChild(_healthMeter);
				s_meterPool.put(_healthMeter);
				
				_healthMeter = null;
				_lastHealth = 0;
			}
		}
		static private var s_normalTint:ColorTransform = new ColorTransform;
		static private var s_hardHitTint:ColorTransform = new ColorTransform(1, 1, 1, 1, 255, 127, 127);
		static private var s_hitTint:ColorTransform = new ColorTransform(1, 1, 1, 1, 127, 0, 0);
		static private var s_meterPool:ObjectPool = new ObjectPool;

		private var _lastFlash:uint;
		private var _lastHealth:uint;
		private var _healthMeter:ProgressMeter;
		public function registerHit(game:IGame, hard:Boolean):void
		{
			if (!_lastFlash)
			{
				displayObject.transform.colorTransform = hard ? s_hardHitTint : s_hitTint;
			}
			if (healthMeterEnabled && !_lastHealth && displayObject is DisplayObjectContainer)
			{
				Util.ASSERT(!_healthMeter);
				
				_healthMeter = (s_meterPool.get() as ProgressMeter) || new ProgressMeter(40, 4, 0, 0xff0000, true);
				DisplayObjectContainer(displayObject).addChild(_healthMeter);
				_healthMeter.rotation = -displayObject.rotation;
			}
			const now:uint = getTimer();
			_lastFlash = now;
			
			if (healthMeterEnabled)
			{
				_lastHealth = now;
				_healthMeter.pct = health / attrs.MAX_HEALTH;
			}
		}
		public function onFrame(game:IGame):void
		{
			worldPos.offset(speed.x, speed.y);
			
			// attrs.SPEED_DECAY would be done here too if I were doing this over again.  Would have to rebalance all the numbers....

			if (attrs.BOUNDED)
			{	
				MathUtil.constrain(game.worldBounds, worldPos, 0, 0, speed);
			}
			if (_behavior)
			{
				_behavior.onFrame(game, this);
			}
			if (_lastHealth)
			{
				Util.ASSERT(_healthMeter && _healthMeter.parent);
				if (getTimer() - _lastHealth > 1500)
				{
					cleanupHealthMeter();
				}
				else
				{
					_healthMeter.rotation = -displayObject.rotation;
				}
			}
			if (_lastFlash)
			{
				if (getTimer() - _lastFlash > 50)
				{
					displayObject.transform.colorTransform = s_normalTint;
					_lastFlash = 0;
				}
				else
				{
					// minor tremble, should be a behavior
					const rnd:Number = MathUtil.random(-1, 1);
					worldPos.x += rnd;
					worldPos.y += rnd;
				}
			}
		}
		protected function launchHelper(start:Point, radians:Number):void
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
				s_bulletLevels = [BulletActor0, BulletActor1, BulletActor2, BulletActor3, BulletActor4, BulletActor5];
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
				s_explLevels = [LaserActor0, LaserActor1, LaserActor2, LaserActor3, LaserActor4, LaserActor5]; 
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
		static public function createRocket(level:uint, homing:Boolean):Actor
		{
			var rocket:RocketActor = RocketActor(ActorPool.instance.get(RocketActor) || new RocketActor(level));
			rocket.homing = homing;
			return rocket;
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
import behaviors.IBehavior;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Point;
import flash.utils.Dictionary;

import karnold.utils.Util;

import org.osmf.traits.DownloadableTrait;

import scripts.IPenetratingAmmo;

class BulletActor extends Actor
{
	public function BulletActor(color:uint):void
	{
		super(ActorAssetManager.createBullet(color), ActorAttrs.BULLET);
//		behavior = new CompositeBehavior(BehaviorFactory.fade, BehaviorFactory.createExpire(ActorAttrs.BULLET.LIFETIME));
		behavior = BehaviorFactory.createExpire(ActorAttrs.BULLET.LIFETIME);
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
final class RocketActor extends Actor
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
	private var _homing:Boolean;
	public function RocketActor(rocket:uint)
	{
		super(composeRocket(rocket), ActorAttrs.ROCKET);
		behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.accelerator, BehaviorFactory.createExpire(ActorAttrs.ROCKET.LIFETIME));
		
		_plume = DisplayObjectContainer(displayObject).getChildAt(0);
		displayObject.scaleX = 0.5;
		displayObject.scaleY = 0.5;
	}
	public override function onFrame(game:IGame):void
	{
		_plume.scaleY = Math.random() + 0.3;
		super.onFrame(game);

		if (_homing)
		{
			BehaviorFactory.strafe.onFrame(game, this);
		}
	}
	public function set homing(b:Boolean):void
	{
		_homing = b;
	}
	public override function reset():void
	{
		super.reset();
		_homing = false;
	}
	protected override function launchHelper(start:Point, radians:Number):void
	{
		super.launchHelper(start, radians);
		
		// slow down the rocket to give the accelerator something to work with.  Kinda a hack,
		// one way to make this cleaner would be to accelerate all objects
		speed.x /= 25;
		speed.y /= 25;
	}
}

class PiercingAmmoActor extends Actor implements IPenetratingAmmo
{
	public function PiercingAmmoActor(dobj:DisplayObject, attrs:ActorAttrs)
	{
		super(dobj, attrs);
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
	
final class FusionBlastActor extends PiercingAmmoActor
{
	public function FusionBlastActor()
	{
		super(ActorAssetManager.createFusionBlast(), ActorAttrs.FUSIONBLAST);
		behavior = new CompositeBehavior(BehaviorFactory.faceForward, BehaviorFactory.createExpire(ActorAttrs.FUSIONBLAST.LIFETIME));
	}
}

// We use actor type as the key to pool with.  So, we have to do this stupid thing below, or else find
// a different pooling mechanism (maybe pooling the display objects separately)
final class BulletActor0 extends BulletActor { public function BulletActor0() { super(0x8888ff); } }
final class BulletActor1 extends BulletActor { public function BulletActor1() { super(0x00ff5d); } }
final class BulletActor2 extends BulletActor { public function BulletActor2() { super(0xeeee00); } }
final class BulletActor3 extends BulletActor { public function BulletActor3() { super(0xff9400); } }
final class BulletActor4 extends BulletActor { public function BulletActor4() { super(0xffffff); } }
final class BulletActor5 extends BulletActor { public function BulletActor5() { super(0xff0000); } }
final class LaserActor0 extends LaserActor { public function LaserActor0() { super(0x90ff); } }
final class LaserActor1 extends LaserActor { public function LaserActor1() { super(0xff5d); } }
final class LaserActor2 extends LaserActor { public function LaserActor2() { super(0xeeee00); } }
final class LaserActor3 extends LaserActor { public function LaserActor3() { super(0xff9400); } }
final class LaserActor4 extends LaserActor { public function LaserActor4() { super(0xffffff); } }
final class LaserActor5 extends LaserActor { public function LaserActor5() { super(0xff0000); } }
final class ExplosionParticleActor0 extends ExplosionParticleActor { public function ExplosionParticleActor0() { super(0xcccccc); } }
final class ExplosionParticleActor1 extends ExplosionParticleActor { public function ExplosionParticleActor1() { super(0xffff00); } }
final class ExplosionParticleActor2 extends ExplosionParticleActor { public function ExplosionParticleActor2() { super(0); } }
