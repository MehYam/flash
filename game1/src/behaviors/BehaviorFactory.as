package behaviors
{
	import flash.geom.Point;
	
	import karnold.utils.RateLimiter;

	final public class BehaviorFactory
	{
		static private var _accelerator:IBehavior;
		static private var _faceForward:IBehavior;
		static private var _facePlayer:IBehavior;
		static private var _faceMouse:IBehavior;
		static private var _gravityPush:IBehavior;
		static private var _gravityPull:IBehavior;
		static private var _follow:IBehavior;
		static private var _fade:IBehavior;
		static private var _fadeIn:IBehavior;
		static private var _fadeFast:IBehavior;
		static private var _speedDecay:IBehavior;
		static private var _shadowPlayer:IBehavior;
		static private var _strafe:IBehavior;
		static private var _standardSpinCW:IBehavior;
		static private var _standardSpinCCW:IBehavior;
		static private var _turret:IBehavior;
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
				_fade = new FadeBehavior(0.005);
			}
			return _fade;
		}
		static public function get fadeFast():IBehavior
		{
			if (!_fadeFast)
			{
				_fadeFast = new FadeBehavior(0.01);
			}
			return _fadeFast;
		}
		static public function get fadeIn():IBehavior
		{
			if (!_fadeIn)
			{
				_fadeIn = new FadeInBehavior;
			}
			return _fadeIn;
		}
		static public function get accelerator():IBehavior
		{
			if (!_accelerator)
			{
				_accelerator = new Accelerator;
			}
			return _accelerator;
		}
		static public function get speedDecay():IBehavior
		{
			if (!_speedDecay)
			{
				_speedDecay = new SpeedDecayBehavior;
			}
			return _speedDecay;
		}
		static public function get shadowPlayer():IBehavior
		{
			if (!_shadowPlayer)
			{
				_shadowPlayer = new ShadowPlayerBehavior;
			}
			return _shadowPlayer;
		}
		static public function get turret():IBehavior
		{
			if (!_turret)
			{
				_turret = new CompositeBehavior(facePlayer, speedDecay);
			}
			return _turret;
		}
		static public function get spinCW():IBehavior
		{
			if (!_standardSpinCW)
			{
				_standardSpinCW = new SpinBehavior;
			}
			return _standardSpinCW;
		}
		static public function get spinCCW():IBehavior
		{
			if (!_standardSpinCCW)
			{
				_standardSpinCCW = new SpinBehaviorCCW;
			}
			return _standardSpinCCW;
		}
		// Non-singletons
		// source - is either an AmmoFireSource or array of them
		static public function createAutofire(source:*, msRateMin:uint, msRateMax:uint = 0):IBehavior
		{
			if (msRateMax < msRateMin)
			{
				msRateMax = msRateMin;
			}
			return new AutofireBehavior(source, new RateLimiter(msRateMin, msRateMax));
		}
		// source - is either an AmmoFireSource or array of them
		static public function createChargedFire(source:*, chargeSteps:uint, msStepDuration:uint, damageAtFull:Number):IBehavior
		{
			return new ChargedFireBehavior(source, chargeSteps, msStepDuration, damageAtFull);
		}
		static public function createExpire(lifetime:int):IBehavior
		{
			return new ExpireBehavior(lifetime);
		}
		static public function createPulse(speed:Number):IBehavior
		{
			return new Pulse(speed);
		}
		static public function createShake():IBehavior
		{
			return new ShakeBehavior;
		}
		static public function createSpinDrift():IBehavior
		{
			return new CompositeBehavior((Math.random() < 0.5) ? spinCW : spinCCW, speedDecay, new Pulse, new ExpireBehavior(3000));
		}
	}
}
import behaviors.ActorAttrs;
import behaviors.AmmoFireSource;
import behaviors.BehaviorFactory;
import behaviors.CompositeBehavior;
import behaviors.IBehavior;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.utils.getTimer;

import karnold.utils.MathUtil;
import karnold.utils.RateLimiter;
import karnold.utils.Util;

import scripts.TankActor;

final class Accelerator implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		// get the current rotation, find the speed, and see what the new speed should be
		var speed:Number = MathUtil.magnitude(actor.speed.x, actor.speed.y);
		if (speed < actor.attrs.MAX_SPEED)
		{
			const radians:Number = MathUtil.getRadiansRotation(actor.speed.x, actor.speed.y);

			speed += actor.attrs.ACCELERATION;
			actor.speed.x = speed * Math.sin(radians);
			actor.speed.y = speed * -Math.cos(radians);
		}
	}
}

final class FaceForwardBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (actor.underForce && (actor.speed.x != 0 || actor.speed.y != 0))
		{
			actor.displayObject.rotation = MathUtil.getDegreesRotation(actor.speed.x, actor.speed.y);
		}
	}
}

final class FacePlayerBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		actor.displayObject.rotation = MathUtil.getDegreesBetweenPoints(game.player.worldPos, actor.worldPos); 
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
		const radians:Number = MathUtil.getRadiansBetweenPoints(actor.worldPos, game.player.worldPos);
		
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
		const radians:Number = MathUtil.getRadiansBetweenPoints(actor.worldPos, game.player.worldPos);
		
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
		const radians:Number = MathUtil.getRadiansBetweenPoints(actor.worldPos, game.player.worldPos);
		
		actor.speed.x = actor.attrs.MAX_SPEED * -Math.sin(radians);
		actor.speed.y = actor.attrs.MAX_SPEED * Math.cos(radians);
	}
}

final class StrafeBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		const radians:Number = MathUtil.getRadiansBetweenPoints(actor.worldPos, game.player.worldPos);
		
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
	private var _rate:Number;
	public function FadeBehavior(rate:Number):void
	{
		_rate = rate;
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (actor.displayObject.alpha > 0)
		{
			actor.displayObject.alpha -= _rate;
		}
	}
}
final class FadeInBehavior implements IBehavior  //KAI: unnecessary and dumb
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (actor.displayObject.alpha < 1)
		{
			actor.displayObject.alpha += 0.1;
		}
	}
}

final class FireHelper
{
	static public function fireAsArrayOrSource(game:IGame, actor:Actor, source:*, step:Number = 1):void
	{
		const sourceAsArray:Array = source as Array;
		if (sourceAsArray)
		{
			for each (var thisSource:AmmoFireSource in sourceAsArray)
			{
				thisSource.fire(game, actor, step);
			}
			if (sourceAsArray.length)
			{
				AmmoFireSource(sourceAsArray[0]).playSound();
			}
		}
		else
		{
			AmmoFireSource(source).fire(game, actor, step);
			AmmoFireSource(source).playSound();
		}
	}
}
final class AutofireBehavior implements IBehavior
{
	private var _source:*;
	private var _rate:RateLimiter;
	public function AutofireBehavior(source:*, rate:RateLimiter):void
	{
		_source = source;
		_rate = rate;
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (!_rate || _rate.now)
		{
			// This sucks a little bit, but the game script must ensure that this only gets called while the player's
			// shooting
			FireHelper.fireAsArrayOrSource(game, actor, _source);
		}
	}
}

final class ChargedFireBehavior implements IBehavior
{
	private var _source:*;
	private var _stepRate:RateLimiter;
	private var _chargeSteps:uint;
	private var _selfDamage:Number;
	private var _shake:IBehavior;
	public function ChargedFireBehavior(source:*, chargeSteps:uint, msStepDuration:uint, selfDamage:Number):void
	{
		_source = source;
		_stepRate = new RateLimiter(msStepDuration, msStepDuration);
		_chargeSteps = chargeSteps;
		_selfDamage = selfDamage;
		_shake = BehaviorFactory.createShake();
	}
	private var _charging:Boolean = false;
	private var _currentStep:uint = 0;
	private function incStep(scoreBoard:ScoreBoard):void
	{
		Util.ASSERT(_charging);
		Util.ASSERT(_currentStep <= _chargeSteps);
		++_currentStep;
		scoreBoard.pctFusion = _currentStep/_chargeSteps;
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		// This sucks a little bit, but the game script must ensure that this only gets called while the player's
		// shooting (and once after they stop)
		if (game.playerShooting)
		{
			if (_stepRate.now)
			{
				if (!_charging)
				{
					_charging = true;
					incStep(game.scoreBoard);
				}
				else
				{
					if (_currentStep < _chargeSteps)
					{
						incStep(game.scoreBoard);
					}
					else if (_currentStep == _chargeSteps)
					{
						game.script.damageActor(game, game.player, _selfDamage, true, true);
					}
				}
			}
			if (_charging)
			{
				_shake.onFrame(game, actor);
			}
		}
		else
		{
			if (_charging)
			{
				_charging = false;
				_stepRate.reset();

				FireHelper.fireAsArrayOrSource(game, actor, _source, _currentStep);
				_currentStep = 0;
				game.scoreBoard.pctFusion = .01;
			}
		}
	}
}

final class ShadowPlayerBehavior implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		const player:Actor = game.player;
		Util.setPoint(actor.worldPos, player.worldPos);
		actor.displayObject.rotation = player.displayObject.rotation;
	}	
}

final class ShakeBehavior implements IBehavior
{
	static private const MAGNITUDE:Number = 1.5;

	private var _rate:RateLimiter = new RateLimiter(10, 100);
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (_rate.now)
		{
			if (Math.random() < 0.5)
			{
				actor.worldPos.offset(MathUtil.random(-MAGNITUDE, MAGNITUDE), MathUtil.random(-MAGNITUDE, MAGNITUDE));
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
		if (actor.speed.x)
		{
			actor.speed.x = MathUtil.speedDecay(actor.speed.x, actor.attrs.SPEED_DECAY);
		}
		if (actor.speed.y)
		{
			actor.speed.y = MathUtil.speedDecay(actor.speed.y, actor.attrs.SPEED_DECAY);
		}
	}
}
final class ExpireBehavior implements IBehavior, IResettable
{
	private var frames:int = 0;
	private var lifetime:int;
	public function ExpireBehavior(msLifeTime:int):void
	{
		lifetime = Consts.millisecondsToFrames(msLifeTime);
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		++frames;
		if (frames > lifetime)
		{
			game.killActor(actor);
		}
	}
	public function reset():void
	{
		frames = 0;
	}
}

final class SpinBehavior implements IBehavior
{
	static public const SPIN:Number = 2;
	public function onFrame(game:IGame, actor:Actor):void
	{
		actor.displayObject.rotation += SPIN;
	}
}
final class SpinBehaviorCCW implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		actor.displayObject.rotation -= SpinBehavior.SPIN;
	}
}
final class Pulse implements IBehavior
{
	static private const MAX:Number = 1;
	static private const MIN:Number = 0.2;
	private var _direction:Number = -1;
	private var _speed:Number;
	public function Pulse(speed:Number = 0.1):void
	{
		_speed = speed;
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (actor.displayObject.alpha < MIN)
		{
			_direction = 1;
		}
		else if (actor.displayObject.alpha >= 1)
		{
			_direction = -1;
		}
		actor.displayObject.alpha += _direction * _speed;
	}
}