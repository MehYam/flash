package ui
{
	import behaviors.BehaviorConsts;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import karnold.utils.FrameTimer;
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	
	import scripts.TankActor;

	public class TestDialog extends GameDialog
	{
		private var _frameTimer:FrameTimer;
		public function TestDialog(inner:Boolean=true)
		{
			super(inner);

			title = "TEST";
			addBottom();
			render();

//			addTank();
			addTurret();

			Util.traceDisplayList(this);
		}
		
		private var _actor:TankActor;
		private function addTank():void
		{
			_actor = TankActor.createTankActor(0, 0, BehaviorConsts.TEST_TANK);
			
			_actor.displayObject.x = width /2;
			_actor.displayObject.y = height /2;
			
			addChild(_actor.displayObject);
			
			_frameTimer = new FrameTimer(onFrame);
			_frameTimer.startPerFrame();
		}
		private var _rotationSpeed:Number = 0;
		private var _turretRotationSpeed:Number = 0;
		private function onFrame():void
		{
			_actor.treadFrame();
			_actor.displayObject.rotation += _rotationSpeed;
			_actor.turretRotation += _turretRotationSpeed;
			
			//KAI: this effect is super awesome and needs to be a behavior
			//KAI: speaking of that - we should be able to do this with Actors and behaviors w/o hacking frames
			if (Math.abs(_turretRotationSpeed) < 0.1)
			{
				_turretRotationSpeed = MathUtil.random(-2, 2);
			}
			_turretRotationSpeed *= 0.99;
			if (Math.abs(_rotationSpeed) < 0.1)
			{
				_rotationSpeed = MathUtil.random(-2, 2);
			}
			_rotationSpeed *= 0.99;
		}
		private function addBottom():void
		{
			var foo:Sprite = new Sprite;
			foo.x = 300;
			foo.y = 300;
			foo.graphics.drawRect(0, 0, 10, 10);
			addChild(foo);
		}
		
		private var _turret:DisplayObjectContainer;
		private function addTurret():void
		{
			_frameTimer = new FrameTimer(onTurretFrame);
			_frameTimer.startPerFrame();

			_turret = new Sprite;

			var asset:DisplayObject = ActorAssetManager.createTurret(4);
			asset.x = -asset.width/2;
			asset.y = -asset.height/2 - 13;
			_turret.addChild(asset);

			var origin:Shape = new Shape;
			origin.graphics.beginFill(0xff0000);
			origin.graphics.drawCircle(0, 0, 3);
			_turret.addChild(origin);

			_turret.x = width/2;
			_turret.y = height/2;
			addChild(_turret);
		}
		private function onTurretFrame():void
		{
			_turret.rotation += 1;
		}
	}
}