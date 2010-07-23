package ui
{
	import behaviors.BehaviorConsts;
	
	import flash.display.Sprite;
	
	import karnold.utils.FrameTimer;
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	
	import scripts.TankActor;

	public class TestDialog extends GameDialog
	{
		private var _frameTimer:FrameTimer = new FrameTimer(onFrame);
		public function TestDialog(inner:Boolean=true)
		{
			super(inner);

			title = "TEST";
			addBottom();
			render();

			addTank();
			
			Util.traceDisplayList(this);
		}
		
		private var _actor:TankActor;
		private function addTank():void
		{
			_actor = TankActor.createTankActor(Math.random()*5, Math.random()*5, BehaviorConsts.TEST_TANK);
			
			_actor.displayObject.x = width /2;
			_actor.displayObject.y = height /2;
			
			addChild(_actor.displayObject);
			
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
	}
}