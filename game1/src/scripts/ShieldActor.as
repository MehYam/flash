package scripts
{
	import behaviors.ActorAttrs;
	import behaviors.AmmoFireSource;
	import behaviors.BehaviorFactory;
	import behaviors.CompositeBehavior;
	import behaviors.IBehavior;
	
	import flash.display.DisplayObject;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	
	public final class ShieldActor extends Actor
	{
		static public function create():Actor
		{
			var shield:Actor = ActorPool.instance.get(ShieldActor) || new ShieldActor();
			return shield;
		}
		static public function createActivator(source:AmmoFireSource, attrs:ActorAttrs):IBehavior
		{
			return new ShieldActivatorBehavior(source, attrs, 1000);
		}

		// sucks the way this is done a little.  Something broken in our design here.
		static private var s_holding:IBehavior;
		public function ShieldActor()
		{
			//KAI: hide constructor
			super(ActorAssetManager.createShield(), null); // hack - behavior's going to plug this in for us
			if (!s_holding)
			{
				s_holding = new CompositeBehavior(new PlayerShadow, BehaviorFactory.fadeIn);
			}
			behavior = s_holding;
		}
		private var _released:Boolean = false;
		public function release(game:IGame):void
		{
			_released = true;
			
			// release self
			Util.setPoint(speed, game.player.speed);
			BehaviorFactory.faceForward.onFrame(game, this);
			
			displayObject.alpha = 1;
			behavior = new CompositeBehavior(BehaviorFactory.createExpire(attrs.LIFETIME), BehaviorFactory.fade, BehaviorFactory.speedDecay);
		}
		public override function registerHit(game:IGame, hard:Boolean):void
		{
			super.registerHit(game, hard);
			if (!_released)
			{
				game.scoreBoard.pctShield = health / attrs.MAX_HEALTH;
			}
		}
		public var offsetY:Number; // hack
		public override function reset():void
		{
			super.reset();
			_released = false;
			displayObject.alpha = 0;
			offsetY = 0;
			
			behavior = s_holding;
		}
		public function positionAt(actor:Actor):void
		{
			Util.setPoint(worldPos, actor.worldPos);
			if (offsetY != 0)
			{
				worldPos.y += offsetY;
				MathUtil.rotatePoint(actor.worldPos, worldPos, actor.displayObject.rotation);
			}
			displayObject.rotation = actor.displayObject.rotation;
		}
	}
}
import behaviors.ActorAttrs;
import behaviors.AmmoFireSource;
import behaviors.IBehavior;

import flash.display.DisplayObjectContainer;

import karnold.utils.RateLimiter;

import scripts.ShieldActor;

final internal class ShieldActivatorBehavior implements IBehavior  
{
	private var _source:AmmoFireSource;
	private var _attrs:ActorAttrs;
	private var _limiter:RateLimiter;
	public function ShieldActivatorBehavior(source:AmmoFireSource, attrs:ActorAttrs, msRecharge:uint):void
	{
		_source = source;
		_limiter = new RateLimiter(msRecharge, msRecharge);
		_attrs = attrs;
	}
	private var _shield:ShieldActor;
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (actor)
		{
			if (_shield && (!_shield.alive || !game.playerShooting))
			{
				// launch if the user's launched a ready shield, or if a ready shield has died
				_shield.release(game);
				_shield = null;
				_limiter.reset();
				
				game.scoreBoard.pctShield = 0.01;
				game.globalBehavior = this;
			}
			else if (!_shield && game.playerShooting && _limiter.now)
			{
				_shield = ShieldActor(_source.fire(game, actor));
				
				// this seriously seriously needs a redesign
				_shield.attrs = _attrs;
//DisplayObjectContainer(_shield.displayObject).addChild(ActorAssetManager.createReticle(_shield.attrs.RADIUS));
				_shield.reset();
				_shield.offsetY = _source.offsetY;
				_shield.damage = _source.damage;
				_shield.healthMeterEnabled = false;
			}
		}
		else
		{
			// UI code....
			const charge:Number = 1 - _limiter.remaining / _limiter.minRate;
			game.scoreBoard.pctShield = charge;
			if (charge == 1)
			{
				game.globalBehavior = null;
			}
		}
	}
}

final internal class PlayerShadow implements IBehavior
{
	public function onFrame(game:IGame, actor:Actor):void
	{
		const player:Actor = game.player;
		var shield:ShieldActor = ShieldActor(actor);
		shield.positionAt(player);
	}
}
