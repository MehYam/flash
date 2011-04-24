package scripts
{
	import behaviors.ActorAttrs;
	import behaviors.BehaviorFactory;
	import behaviors.CompositeBehavior;
	import behaviors.IBehavior;
	
	import flash.display.DisplayObject;
	import flash.text.TextFormat;
	
	import karnold.ui.ShadowTextField;
	
	public class BlingActor extends Actor
	{
		static private const s_attrs:ActorAttrs = new ActorAttrs(0, 2, 0, 0.05);
		static private const s_fmt:TextFormat = new TextFormat("Courier New", 10, null, true);
		static private const s_behavior:IBehavior = new CompositeBehavior(BehaviorFactory.fade, BehaviorFactory.speedDecay);
		public function BlingActor()
		{
			var tf:ShadowTextField = new ShadowTextField(0xffff00, 0, 2);
			tf.defaultTextFormat = s_fmt;
			super(tf, s_attrs);
			
			behavior = s_behavior;
		}
		public override function onFrame(game:IGame):void
		{
			super.onFrame(game);
			if (alive && speed.y == 0)
			{
				alive = false;  // game engine will clean us up
			}
		}
		public override function reset():void
		{
			super.reset();
			speed.y = -attrs.MAX_SPEED;
		}
		static public function launch(game:IGame, worldX:Number, worldY:Number, value:uint):void
		{
			var ba:BlingActor = (ActorPool.instance.get(BlingActor) as BlingActor) || new BlingActor; 
			ba.worldPos.x = worldX;
			ba.worldPos.y = worldY;
			
			ShadowTextField(ba.displayObject).text = "+" + value;
			
			game.addEffect(ba);
		}
	}
}