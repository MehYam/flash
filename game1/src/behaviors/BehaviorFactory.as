package behaviors
{
	import flash.geom.Point;
	
	import karnold.utils.RateLimiter;

	final public class BehaviorFactory
	{
		static private var _faceForward:IBehavior;
		static private var _facePlayer:IBehavior;
		static private var _faceMouse:IBehavior;
		static private var _gravityPush:IBehavior;
		static private var _gravityPull:IBehavior;
		static private var _strafe:IBehavior;
		static private var _follow:IBehavior;
		static private var _fade:IBehavior;
		static public function get faceForward():IBehavior
		{
			if (!_faceForward)
			{
				_faceForward = new FaceForwardBehavior;
			}
			return _faceForward;
		}
		static public function get facePlayer():IBehavior
		{
			if (!_facePlayer)
			{
				_facePlayer = new FacePlayerBehavior;
			}
			return _facePlayer;
		}
		static public function get faceMouse():IBehavior
		{
			if (!_faceMouse)
			{
				_faceMouse = new FaceMouseBehavior;
			}
			return _faceMouse;
		}
		static public function get gravityPush():IBehavior
		{
			if (!_gravityPush)
			{
				_gravityPush = new GravityPush;
			}
			return _gravityPush;
		}
		static public function get gravityPull():IBehavior
		{
			if (!_gravityPull)
			{
				_gravityPull = new GravityPullBehavior;
			}
			return _gravityPull;
		}
		static public function get strafe():IBehavior
		{
			if (!_strafe)
			{
				_strafe = new StrafeBehavior;
			}
			return _strafe;
		}
		static public function get follow():IBehavior
		{
			if (!_follow)
			{
				_follow = new FollowBehavior;
			}
			return _follow;
		}
		static public function get fade():IBehavior
		{
			if (!_fade)
			{
				_fade = new FadeBehavior;
			}
			return _fade;
		}

		// Non-singletons
		static public function createAutofire(source:AmmoFireSource, msRateMin:uint, msRateMax:uint):IBehavior
		{
			return new AutofireBehavior(source, new RateLimiter(msRateMin, msRateMax));
		}
		static public function createExpire(lifetime:int):IBehavior
		{
			return new ExpireBehavior(lifetime);
		}
	}
}
import behaviors.AmmoFireSource;
import behaviors.AmmoType;
import behaviors.ActorAttrs;
import behaviors.IBehavior;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.utils.getTimer;

import karnold.utils.MathUtil;
import karnold.utils.RateLimiter;
import karnold.utils.Util;

import scripts.TankActor;

final class FaceForwardBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (actor.speed.x != 0 || actor.speed.y != 0)
		{
			actor.displayObject.rotation = MathUtil.getDegreesRotation(actor.speed.x, actor.speed.y);
		}
	}
}

final class FacePlayerBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		const deltaX:Number = game.player.worldPos.x - actor.worldPos.x;
		const deltaY:Number = game.player.worldPos.y - actor.worldPos.y;
		actor.displayObject.rotation = MathUtil.getDegreesRotation(deltaX, deltaY);
	}
}

final class FaceMouseBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		var player:Actor = game.player;
		const degrees:Number = MathUtil.getDegreesRotation(game.input.lastMousePos.x - player.displayObject.x, game.input.lastMousePos.y - player.displayObject.y);
		if (player is TankActor)
		{
			TankActor(player).turretRotation = degrees;
		}
		else
		{
			player.displayObject.rotation = degrees;
		}
	}
}
final class GravityPush implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = MathUtil.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * actor.attrs.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * actor.attrs.ACCELERATION;
		
		actor.speed.x += accelX;
		actor.speed.y += accelY;
		
		actor.speed.x = MathUtil.constrainAbsoluteValue(actor.speed.x, actor.attrs.MAX_SPEED);
		actor.speed.y = MathUtil.constrainAbsoluteValue(actor.speed.y, actor.attrs.MAX_SPEED);
	}
};

final class GravityPullBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = MathUtil.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * actor.attrs.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * actor.attrs.ACCELERATION;
		
		actor.speed.x -= accelX;
		actor.speed.y -= accelY;
		
		actor.speed.x = MathUtil.constrainAbsoluteValue(actor.speed.x, actor.attrs.MAX_SPEED);
		actor.speed.y = MathUtil.constrainAbsoluteValue(actor.speed.y, actor.attrs.MAX_SPEED);
	}
};

final class FollowBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = MathUtil.getRadiansRotation(deltaX, deltaY);
		
		actor.speed.x = actor.attrs.MAX_SPEED * -Math.sin(radians);
		actor.speed.y = actor.attrs.MAX_SPEED * Math.cos(radians);
	}
}

final class StrafeBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		const deltaX:Number = actor.worldPos.x - game.player.worldPos.x;
		const deltaY:Number = actor.worldPos.y - game.player.worldPos.y;
		const radians:Number = MathUtil.getRadiansRotation(deltaX, deltaY);
		
		const accelX:Number = Math.sin(radians) * actor.attrs.ACCELERATION;
		const accelY:Number = -Math.cos(radians) * actor.attrs.ACCELERATION;
		
		actor.speed.x -= accelX;
		actor.speed.y -= accelY;
		
		actor.speed.x = MathUtil.constrainAbsoluteValue(actor.speed.x, actor.attrs.MAX_SPEED);
		actor.speed.y = MathUtil.constrainAbsoluteValue(actor.speed.y, actor.attrs.MAX_SPEED);
		
		actor.displayObject.rotation = MathUtil.getDegreesRotation(-accelX, -accelY);
	}
}

final class FadeBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		actor.displayObject.alpha -= 0.005;
	}
}

final class AutofireBehavior implements IBehavior
{
	private var _source:AmmoFireSource;
	private var _rate:RateLimiter;
	public function AutofireBehavior(source:AmmoFireSource, rate:RateLimiter):void
	{
		_source = source;
		_rate = rate;
	}
 	static private var po_tmp:Point = new Point;

	public function onFrame(game:IGame, actor:Actor):void
	{
		if (_rate.now)
		{
			AssetManager.instance.laserSound();
			var ammo:Actor;
			switch(_source.ammoType) {
				case AmmoType.BULLET:
					ammo = Actor.createBullet();
					break;
				case AmmoType.LASER:
				case AmmoType.HIGHLASER:
					ammo = Actor.createLaser();
					break;
			}
			const angle:Number = actor is TankActor ? (TankActor(actor).turretRotation) : actor.displayObject.rotation;
			if (_source)
			{
				Util.setPoint(po_tmp, actor.worldPos);
				po_tmp.offset(_source.offsetX, _source.offsetY);
				
				MathUtil.rotatePoint(actor.worldPos, po_tmp, angle);
				ammo.launchDegrees(po_tmp, angle);
			}
			else
			{
				ammo.launchDegrees(actor.worldPos, angle);
			}
			if (game.player == actor)
			{
				game.addPlayerAmmo(ammo);
			}
			else
			{
				game.addEnemyAmmo(ammo);
			}
		}
	}
}

final class SpeedDecayBehavior implements IBehavior
{
	static private var _instance:SpeedDecayBehavior;
	static public function get instance():SpeedDecayBehavior
	{
		if (!_instance)
		{
			_instance = new SpeedDecayBehavior;
		}
		return _instance;
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		actor.speed.x = MathUtil.speedDecay(actor.speed.x, actor.attrs.SPEED_DECAY);
		actor.speed.y = MathUtil.speedDecay(actor.speed.y, actor.attrs.SPEED_DECAY);
	}
}
final class ExpireBehavior implements IBehavior, IResettable
{
	private var start:int = getTimer();
	private var lifetime:int;
	public function ExpireBehavior(msLifeTime:int):void
	{
		lifetime = msLifeTime;
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		if ((getTimer() - start) > lifetime)
		{
			game.killActor(actor);
		}
	}
	public function reset():void
	{
		start = getTimer();
	}
}