package scripts
{
	public class GameScriptFactory
	{
		public function GameScriptFactory()
		{
		}
		
		static public function get level1():IGameScript
		{
			return new Level1;
		}
	}
}
import behaviors.AlternatingBehavior;
import behaviors.CompositeBehavior;

import karnold.utils.MathUtil;

import scripts.IGameScript;

final class Level1 implements IGameScript
{
	public function begin(game:IGame):void
	{
		game.showPlayer();
		game.tiles = SampleData.level1;
		game.start();
		game.centerPrint("Level 1");
		
		addTestActors(game);
	}
	
	private function addTestActors(game:IGame):void
	{
		var testenemy:Actor = new Actor(SimpleActorAsset.createRedShip(), BehaviorConsts.RED_SHIP);
		testenemy.worldPos = game.worldBounds.middle;
		testenemy.worldPos.offset(MathUtil.random(-100, 100), MathUtil.random(-100, 100));
		testenemy.behavior = new AlternatingBehavior
			(
				new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward),
				new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward),
				new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.autofire)
			);
		game.addEnemy(testenemy);
		
		testenemy = new Actor(SimpleActorAsset.createGreenShip(), BehaviorConsts.GREEN_SHIP);
		testenemy.behavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
		testenemy.worldPos.offset(MathUtil.random(game.worldBounds.left, game.worldBounds.right), MathUtil.random(game.worldBounds.top, game.worldBounds.bottom));
		game.addEnemy(testenemy);
	}
	
	// IGameEvents
	public function onCenterPrintDone(text:String):void
	{
		
	}
	public function onEnemyDeath(actor:Actor):void
	{
		
	}
	public function onPlayerDeath():void
	{
		
	}
}

final class SampleData
{
	[Embed(source="assets/level1.txt", mimeType="application/octet-stream")]
	static private const Level1Data:Class;
	static public function get level1():String
	{
		return (new Level1Data).toString();
	}
}