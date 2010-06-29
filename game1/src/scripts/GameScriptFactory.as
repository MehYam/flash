package scripts
{
	public class GameScriptFactory
	{
		static public function get testScript1():IGameScript
		{
			return new TestScript(1);
		}
		static public function get testScript2():IGameScript
		{
			return new TestScript(10);
		}
		static public function get level1():IGameScript
		{
			return new Level1Script();
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
	static public function getBluePlayer():Actor
	{
		return new Actor(SimpleActorAsset.createBlueShip());
	}
	static private const NAME_RR:String = "Red Rogue";
	static private const NAME_GK:String = "Greenakazi";
	static private var s_enemyNamesThisSucks:Object = {};
	static public function isEnemy(actor:Actor):Boolean
	{
		//KAI: just... ug
		return s_enemyNamesThisSucks[actor.name];
	}
	static public function addRedRogue(game:IGame):void
	{
		var a:Actor = new Actor(SimpleActorAsset.createRedShip(), BehaviorConsts.RED_SHIP);
		a.name = NAME_RR;
		attackAndFlee(a);
		placeAtRandomEdge(a, game.worldBounds);
		game.addEnemy(a);
		
		s_enemyNamesThisSucks[a.name] = 1;
	}
	static public function addGreenSuicider(game:IGame):void
	{
		var a:Actor = new Actor(SimpleActorAsset.createGreenShip(), BehaviorConsts.GREEN_SHIP);
		a.name = NAME_GK;
		a.behavior = HOME;
		placeAtRandomEdge(a, game.worldBounds);
		game.addEnemy(a);

		s_enemyNamesThisSucks[a.name] = 1;
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
		game.tiles = GrassTiles.testLevel;
		game.showPlayer(Utils.getBluePlayer());
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
	public function onCenterPrintDone(text:String):void	{}
	public function onActorDeath(actor:Actor):void {}
}

final class Level1Script implements IGameScript
{
	private var _game:IGame;
	public function begin(game:IGame):void
	{
		_game = game;

		game.tiles = GrassTiles.smallLevel;
		game.showPlayer(Utils.getBluePlayer());
		game.start();
		game.centerPrint("Level 1");
		
		addNextWave();
	}

	private var _level:uint = 0;
	private var _enemies:uint = 0;
	private function addNextWave():void
	{
		const greens:uint = 5 + _level*2;

		var i:uint;
		for (i = 0; i < greens; ++i)
		{
			Utils.addGreenSuicider(_game);
			++_enemies;
		}

		const reds:uint = (_level > 2) ? (_level - 2) : 0;
		for (i = 0; i < reds; ++i)
		{
			Utils.addRedRogue(_game);
			++_enemies;
		}
		
		++_level;
	}
	
	// IGameEvents
	public function onCenterPrintDone(text:String):void	{}
	public function onActorDeath(actor:Actor):void 
	{
		if (Utils.isEnemy(actor))
		{
			if (!--_enemies)
			{
				addNextWave();
			}
		}
	}
}

final class GrassTiles
{
	[Embed(source="assets/level1_small.txt", mimeType="application/octet-stream")]
	static private const SmallLevel:Class;
	static public function get smallLevel():String
	{
		return (new SmallLevel).toString();
	}

	[Embed(source="assets/level1.txt", mimeType="application/octet-stream")]
	static private const TestLevel:Class;
	static public function get testLevel():String
	{
		return (new TestLevel).toString();
	}
}