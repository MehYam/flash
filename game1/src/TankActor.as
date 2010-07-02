package
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import karnold.utils.Util;
	
	public class TankActor extends Actor
	{
		private var _leftTrack:MovieClip;
		private var _rightTrack:MovieClip;
		private var _turret:DisplayObject;
		public function TankActor(MustUseFactoryFunction:MUSTUSEFACTORYFUNCTION, 
								  dobj:DisplayObject,
								  leftTrack:MovieClip,
								  rightTrack:MovieClip,
								  turret:DisplayObject,
								  bc:BehaviorConsts)
		{
			super(dobj, bc);
			
			_leftTrack = leftTrack;
			_rightTrack = rightTrack;
			_turret = turret;
		}

		private var _turretRotation:Number = 0;
		public function set turretRotation(degrees:Number):void
		{
			_turretRotation = degrees;
		}

		private var _trackRunning:Boolean = true;
		public override function onFrame(gameState:IGame):void
		{
			super.onFrame(gameState);
			if (speed.x == 0 && speed.y == 0)
			{
				if (_trackRunning)
				{
					_leftTrack.stop();
					_rightTrack.stop();
					_trackRunning = false;
				}
			}
			else if (!_trackRunning)
			{
				_leftTrack.play();
				_rightTrack.play();
				_trackRunning = true;
			}
			if (_turret.rotation != _turretRotation)
			{
				_turret.rotation = _turretRotation - displayObject.rotation;
			}
		}
		public static function createTankActor( leftTrack:MovieClip,
												rightTrack:MovieClip,
												hull:DisplayObject,
												turret:DisplayObject):TankActor
		{
			var parent:Sprite = new Sprite;
			
			var hull:DisplayObject = SimpleActorAsset.createHull0();
			var turret:DisplayObject = SimpleActorAsset.createTurret0();
			var track:DisplayObject = SimpleActorAsset.createTrack();
			var track2:DisplayObject = SimpleActorAsset.createTrack();
			
			const width:Number = track.width + hull.width;
			const height:Number = hull.height;
			
			track.x = -width/2;
			hull.x  = track.x - 1 +  track.width/2;
			track2.x = hull.x + hull.width - track.width/2;
			
			track.scaleY = track2.scaleY = hull.height / track.height;
			track.y = track2.y = hull.y = -height/2;
			
			var turretParent:Sprite = new Sprite;
			turret.x = -14.5;
			turret.y = -59;
			turretParent.addChild(turret);

			parent.addChild(track);
			parent.addChild(track2);
			parent.addChild(hull);
			parent.addChild(turretParent);

			return new TankActor(MUSTUSEFACTORYFUNCTION.instance, parent, leftTrack, rightTrack, turretParent, null);
		}
	}
}

final class MUSTUSEFACTORYFUNCTION { public static var instance:MUSTUSEFACTORYFUNCTION = new MUSTUSEFACTORYFUNCTION; }