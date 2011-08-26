package scripts
{
	import behaviors.ActorAttrs;
	import behaviors.AmmoFireSource;
	import behaviors.AmmoType;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	
	public class TankActor extends Actor
	{
		private var _leftTrack:DisplayObjectContainer;
		private var _rightTrack:DisplayObjectContainer;
		private var _turret:DisplayObject;
		public function TankActor(MustUseFactoryFunction:MUSTUSEFACTORYFUNCTION, 
								  dobj:DisplayObject,
								  leftTrack:DisplayObjectContainer,
								  rightTrack:DisplayObjectContainer,
								  turret:DisplayObject,
								  bc:ActorAttrs)
		{
			super(dobj, bc);
			
			_leftTrack = leftTrack;
			_rightTrack = rightTrack;
			_turret = turret;
		}

		public function set turretRotation(degrees:Number):void
		{
			const realTurretRotation:Number = degrees - displayObject.rotation
			if (realTurretRotation != _turret.rotation)
			{
				_turret.rotation = realTurretRotation;
			}
		}
		public function get turretRotation():Number
		{
			return _turret.rotation + displayObject.rotation;
		}
		// useful because it's more realistic to rotate a turret in terms of its hull when swivelling it
		public function set turretRotationRelativeToHull(degrees:Number):void
		{
			_turret.rotation = degrees;
		}
		public function get turretRotationRelativeToHull():Number
		{
			return _turret.rotation;
		}
		public override function getBaseFiringAngle(source:AmmoFireSource):Number
		{
			return source.turret ? turretRotation : displayObject.rotation;
		}

		private var _muzzleFlashes:Dictionary;
		private var _muzzleFlash:MuzzleFlash;
		public override function isFiring(source:AmmoFireSource):void
		{
			// sucks.  as an alternative this could be an actor, and could use behaviors
			if (source.type == AmmoType.CANNON)
			{
				if (!_muzzleFlashes)
				{
					_muzzleFlashes = new Dictionary(true);
				}
				var muzzleFlash:MuzzleFlash = _muzzleFlashes[source];
				if (!muzzleFlash)
				{
					_muzzleFlashes[source] = muzzleFlash = new MuzzleFlash;
				}
				muzzleFlash.fire(source, DisplayObjectContainer(_turret));
			}
		}

		private var _trackRunning:Boolean = true;
		public override function onFrame(gameState:IGame):void
		{
			super.onFrame(gameState);
			if (speed.x == 0 && speed.y == 0)
			{
				if (_trackRunning)
				{
					_trackRunning = false;
				}
			}
			else if (!_trackRunning)
			{
				_trackRunning = true;
			}
			if (_muzzleFlashes)
			{
				for each (var mf:MuzzleFlash in _muzzleFlashes)
				{
					mf.onFrame(gameState, this);
				}
			}
			treadFrame();
		}
		
		private var _treadOffset:Number = 0;
		public function treadFrame():void
		{
			if (speed.x != 0 || speed.y != 0)
			{
				var leftTread:DisplayObject = _leftTrack.getChildAt(1);
				var rightTread:DisplayObject= _rightTrack.getChildAt(1);
				
				leftTread.y = _treadOffset;
				rightTread.y = _treadOffset;
	
				_treadOffset -= .1;
				if (_treadOffset < -5)
				{
					_treadOffset = 0;
				}
			}
		}

		//KAI: this is all kinds of ugliness
		public static function createTankActor( hullIndex:uint,
												turretIndex:uint,
												bc:ActorAttrs):TankActor
		{
			var parent:Sprite = new Sprite;
			
			var hull:DisplayObject = ActorAssetManager.createHull(hullIndex);
			var turret:DisplayObject = ActorAssetManager.createTurret(turretIndex);
			var track:DisplayObjectContainer = ActorAssetManager.createTrack();
			var track2:DisplayObjectContainer = ActorAssetManager.createTrack();
			
			const width:Number = track.width + hull.width;
			const height:Number = hull.height;
			const spec:HullSpec = HullSpec.LIST[hullIndex];
			
			track.scaleX = track2.scaleX = spec.trackScaleX;
			track.x = -width/2 + spec.trackOffsetX;
			hull.x  = -hull.width/2;
			track2.x = hull.x + hull.width - track.width/2 - spec.trackOffsetX;
			
			track.scaleY = track2.scaleY = spec.trackScaleY;
			hull.y = spec.hullOffsetY - height/2;
			track.y = track2.y = hull.y + spec.trackOffsetY;
			
			var turretParent:Sprite = new Sprite;
			turret.x = -turret.width/2;
			turret.y = -TurretSpec(TurretSpec.LIST[turretIndex]).turretOffsetY;
			turretParent.addChild(turret);

			parent.addChild(track);
			parent.addChild(track2);
			parent.addChild(hull);
			parent.addChild(turretParent);
			parent.filters = ActorAssetManager.tankDropShadow;

			return new TankActor(MUSTUSEFACTORYFUNCTION.instance, parent, track, track2, turretParent, bc);
		}
	}
}
import behaviors.AmmoFireSource;
import behaviors.IBehavior;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;

import karnold.utils.MathUtil;
import karnold.utils.RateLimiter;
import karnold.utils.Util;

final class MUSTUSEFACTORYFUNCTION { public static var instance:MUSTUSEFACTORYFUNCTION = new MUSTUSEFACTORYFUNCTION; }

final class TurretSpec
{
	static public const LIST:Array = [
		new TurretSpec(67),
		new TurretSpec(67),
		new TurretSpec(67),
		new TurretSpec(67),
		new TurretSpec(43.5)
	];
	public var turretOffsetY:Number;
	public function TurretSpec(turretOffsetY:Number)
	{
		this.turretOffsetY = turretOffsetY * Consts.TANK_SCALE;
	}
}
final class HullSpec
{
	static public const LIST:Array = [
		new HullSpec(1.3, 1.36),
		new HullSpec(1.3, 1, 5, 10),
		new HullSpec(1.3),
		new HullSpec(1.5, 1, 5, 10, -10),
		new HullSpec(1.6, 1.3, 0, 12, -10)
	];
	
	public var turretOffsetY:Number;
	public var trackScaleX:Number;
	public var trackScaleY:Number;
	public var trackOffsetX:Number;
	public var trackOffsetY:Number;
	public var hullOffsetY:Number;
	
	public function HullSpec(trackScaleX:Number = 1, trackScaleY:Number = 1, trackOffsetX:Number = 0, trackOffsetY:Number = 0, hullOffsetY:Number = 0)
	{
		// Because of rasterization, we'll scale the bitmaps beforehand... unfortunately that means we
		// have to apply the scale to everything else after the fact instead of just scaling the tank
		// Sprite container.
		this.turretOffsetY = turretOffsetY * Consts.TANK_SCALE;
		this.trackScaleX = trackScaleX * Consts.TANK_SCALE;
		this.trackScaleY = trackScaleY * Consts.TANK_SCALE;
		this.trackOffsetX = trackOffsetX * Consts.TANK_SCALE;
		this.trackOffsetY = trackOffsetY * Consts.TANK_SCALE;
		this.hullOffsetY = hullOffsetY * Consts.TANK_SCALE;
	}
}

final class MuzzleFlash implements IBehavior
{
	private var _rate:RateLimiter = new RateLimiter(50, 50); 
	private var _flashes:Array = [];
	private var _flash:DisplayObject;
	public function MuzzleFlash():void
	{
		for (var i:uint = 0; i < 3; ++i)
		{
			_flashes.push(ActorAssetManager.createMuzzleFlash(i));
		}
	}
	public function fire(source:AmmoFireSource, parent:DisplayObjectContainer):void
	{
		if (_flash)
		{
			Util.ASSERT(_flash.parent != null);
			_flash.parent.removeChild(_flash);
		}
		const rnd:Number = MathUtil.random(-2, 2);
		_flash = _flashes[uint(Math.random() * _flashes.length)];
		_flash.x = source.offsetX + rnd;
		_flash.y = -_flash.height/2 + source.offsetY + rnd;
		
		parent.addChild(_flash);

		_rate.reset();
	}
	public function onFrame(game:IGame, actor:Actor):void
	{
		if (_flash && _rate.now)
		{
			_flash.parent.removeChild(_flash);
			_flash = null;
		}
	}
}