package scripts
{
	import behaviors.BehaviorConsts;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import karnold.utils.Util;
	
	public class TankActor extends Actor
	{
		private var _leftTrack:DisplayObject;
		private var _rightTrack:DisplayObject;
		private var _turret:DisplayObject;
		public function TankActor(MustUseFactoryFunction:MUSTUSEFACTORYFUNCTION, 
								  dobj:DisplayObject,
								  leftTrack:DisplayObject,
								  rightTrack:DisplayObject,
								  turret:DisplayObject,
								  bc:BehaviorConsts)
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
		}
		// need a list of recipes here - need to know
		// 1) where to center the turret
		// 2) where the tracks go, how much they're scaled
		static private const OFFSETS:Object = 
		{
			turretY: 62
		}
		static private const TURRET_OFFSETS:Array = [62, 56, 56, 56, 48];

		//KAI: this is all kinds of ugliness
		public static function createTankActor( hullIndex:uint,
												turretIndex:uint,
												bc:BehaviorConsts):TankActor
		{
			var parent:Sprite = new Sprite;
			
			var hull:DisplayObject = ActorAssetManager.createHull(hullIndex);
			var turret:DisplayObject = ActorAssetManager.createTurret(turretIndex);
			var track:DisplayObject = ActorAssetManager.createTrack();
			var track2:DisplayObject = ActorAssetManager.createTrack();
			
			const width:Number = track.width + hull.width;
			const height:Number = hull.height;
			
			track.x = -width/2;
			hull.x  = track.x - 1 +  track.width/2;
			track2.x = hull.x + hull.width - track.width/2;
			
			track.scaleY = track2.scaleY = hull.height / track.height;
			track.y = track2.y = hull.y = -height/2;
			
			var turretParent:Sprite = new Sprite;
			turret.x = -turret.width/2;
			turret.y = -TURRET_OFFSETS[turretIndex];
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