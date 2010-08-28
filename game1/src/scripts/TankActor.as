package scripts
{
	import behaviors.ActorAttrs;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
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
			treadFrame();
		}
		
		private var _treadOffset:Number = 0;
		public function treadFrame():void
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

			return new TankActor(MUSTUSEFACTORYFUNCTION.instance, parent, track, track2, turretParent, bc);
		}
	}
}

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
		new HullSpec(1.6, 1.3, 0, 12)
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