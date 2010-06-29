package scripts
{
	public class GameScriptFactory
	{
		public function GameScriptFactory()
		{
		}

		static public function get testScript1():IGameScript
		{
			return new TestScript(1);
		}
		static public function get testScript2():IGameScript
		{
			return new TestScript(10);
		}
	}
}
import behaviors.AlternatingBehavior;
import behaviors.CompositeBehavior;

import karnold.utils.Bounds;
import karnold.utils.MathUtil;

import scripts.IGameScript;

final class Utils
{
	//KAI: maybe move these to BehaviorFactory.  Doing this here leaks the creation policy knowledge out of the factory
	static private const FLEE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPush, BehaviorFactory.faceForward);
	static private const CHASE:CompositeBehavior = new CompositeBehavior(BehaviorFactory.gravityPull, BehaviorFactory.faceForward);
	static private const HOME:CompositeBehavior = new CompositeBehavior(BehaviorFactory.follow, BehaviorFactory.facePlayer);
	static public function attackAndFlee(actor:Actor):void
	{
		actor.behavior = new AlternatingBehavior
		(
			FLEE,
			CHASE,
			new CompositeBehavior(BehaviorFactory.strafe, BehaviorFactory.autofire)
		);
	}
	static public function placeAtRandomEdge(actor:Actor, bounds:Bounds):void
	{
		actor.worldPos.x = MathUtil.random(bounds.left, bounds.right);
		actor.worldPos.y = MathUtil.random(bounds.top, bounds.bottom);
		switch(int(Math.random() * 4)) {
		case 0:
			actor.worldPos.x = bounds.left;
			break;
		case 1:
			actor.worldPos.x = bounds.right;
			break;
		case 2:
			actor.worldPos.y = bounds.top;
			break;
		case 3:
			actor.worldPos.y = bounds.bottom;
			break;
		}
	}
	static public function addRedRogue(game:IGame):void
	{
		var a:Actor = new Actor(SimpleActorAsset.createRedShip(), BehaviorConsts.RED_SHIP);
		attackAndFlee(a);
		placeAtRandomEdge(a, game.worldBounds);
		game.addEnemy(a);
	}
	static public function addGreenSuicider(game:IGame):void
	{
		var a:Actor = new Actor(SimpleActorAsset.createGreenShip(), BehaviorConsts.GREEN_SHIP);
		a.behavior = HOME;
		a.worldPos.offset(MathUtil.random(game.worldBounds.left, game.worldBounds.right), MathUtil.random(game.worldBounds.top, game.worldBounds.bottom));
		game.addEnemy(a);
	}
}

final class TestScript implements IGameScript
{
	private var _actors:int;
	public function TestScript(actors:int)
	{
		_actors = actors;
	}

	public function begin(game:IGame):void
	{
		game.tiles = GrassTiles.data;
		game.showPlayer();
		game.start();
		game.centerPrint("Level 1");
		
		for (var i:int = 0; i < _actors; ++i)
		{
			addTestActors(game);
		}
	}
	
	private function addTestActors(game:IGame):void
	{
		Utils.addRedRogue(game);
		Utils.addGreenSuicider(game);
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

final class Level1Script implements IGameScript
{
	public function Level1Script()
	{
	}
	
	public function begin(game:IGame):void
	{
		game.showPlayer();
		game.tiles = GrassTiles.data;
		game.start();
		game.centerPrint("Level 1");
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

final class GrassTiles
{
	[Embed(source="assets/level1.txt", mimeType="application/octet-stream")]
	static private const Level1Data:Class;
	static public function get data():String
	{
		return (new Level1Data).toString();
	}
}