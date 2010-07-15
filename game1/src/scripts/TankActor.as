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
		static public const TURRET0:Object = { y: 62 };
		static public const TURRET1:Object = { y: 56 };
		static public const TURRET2:Object = { y: 56 };
		static public const TURRET3:Object = { y: 56 };
		static public const TURRET4:Object = { y: 48 };
		static public const HULL0:Object = {};
		static public const HULL1:Object = {};
		static public const HULL2:Object = {};
		static public const HULL3:Object = {};
		static public const HULL4:Object = {};

		//KAI: this is all kinds of ugliness
		public static function createTankActor( hullDesc:Object,
												turretDesc:Object,
												bc:BehaviorConsts):TankActor
		{
			var parent:Sprite = new Sprite;
			
			var hull:DisplayObject;
			switch(hullDesc) {
			case HULL0:	hull = SimpleActorAsset.createHull0();	break;
			case HULL1: hull = SimpleActorAsset.createHull1();  break;
			case HULL2: hull = SimpleActorAsset.createHull2();  break;
			case HULL3: hull = SimpleActorAsset.createHull3();  break;
			case HULL4: hull = SimpleActorAsset.createHull4();  break;
			}
			var turret:DisplayObject;
			switch (turretDesc) {
			case TURRET0: turret = SimpleActorAsset.createTurret0(); break;
			case TURRET1: turret = SimpleActorAsset.createTurret1(); break;
			case TURRET2: turret = SimpleActorAsset.createTurret2(); break;
			case TURRET3: turret = SimpleActorAsset.createTurret3(); break;
			case TURRET4: turret = SimpleActorAsset.createTurret4(); break;
			}

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
			turret.x = -turret.width/2;
			turret.y = -turretDesc.y;
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