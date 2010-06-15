package 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class First extends Sprite
	{
		private static var _xaxis:IAxis;
		private static var _yaxis:IAxis;

		private var _keyboard:Keyboard = null;
		public function First()
		{
			if (!_xaxis)
			{
				_xaxis = new XAxis;
				_yaxis = new YAxis;
			}
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			this.opaqueBackground = 0;

			var loader:URLLoader = new URLLoader;
			
			loader.load(new URLRequest("tileset.xml"));
			loader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);

			_keyboard = new Keyboard(stage);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			stage.frameRate = Consts.FRAME_RATE;
			
			x = Consts.TOP_LEFT;
			y = Consts.TOP_LEFT;
			
			drawWall();
			addDebugField();
		}
		private var _gameXML:XML;
		private function xmlLoaded(e:Event):void
		{
			const loader:URLLoader = e.target as URLLoader;
			if (loader)
			{
				_gameXML = new XML(loader.data);
			}
			
			const imgLoader:Loader = new Loader();
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded, false, 0, true);
			imgLoader.load(new URLRequest("tileset.png"));
		}
		
		private var _framesBitmapData:BitmapData;
		private function imgLoaded(e:Event):void
		{
			_framesBitmapData = e.target.content.bitmapData;
			
			beginDamnYou();
		}

		static private var s_debugOut:TextField;
		private function addDebugField():void
		{
			s_debugOut = new TextField;
			s_debugOut.x = Consts.TOP_LEFT;
			s_debugOut.y = Consts.TILE_SIZE * Consts.ROWS + Consts.TOP_LEFT;
			s_debugOut.autoSize = TextFieldAutoSize.LEFT;
			s_debugOut.background = true;
			s_debugOut.backgroundColor = 0xffffff;

			stage.addChild(s_debugOut);
			dbg("Debug output initialized");
		}
		static private var _debugOutCount:uint = 0;
		static private function dbg(str:String):void
		{
			s_debugOut.text = ++_debugOutCount + ". " + str;
		}
		static private function tr(str:String):void
		{
			trace(++_debugOutCount + ". " + str);
		}
		
		private var _mobs:Array = [];
		private var _immobs:Array = Utils.create2DArray(Consts.ROWS, Consts.COLS);
		private function beginDamnYou():void
		{
			if (Consts.TEST_MODE)
			{
				addEventListener(Event.ENTER_FRAME, onGameplayFrame, false, 0, true);

				addMob(new TestActor(_framesBitmapData, _gameXML), 0, 0);
	
	var ea:Actor = newEnemy();
				addMob(ea, 5, 5);
	//ea.onEvent(ActorEvent.PAUSE);
				addMob(newEnemy(), 0, 1);
				addMob(newEnemy(), 4, 4);
				addMob(newEnemy(), Consts.ROWS - 1, Consts.COLS - 1);
	
				addImmob(newBlock(), 1, 1);
				addImmob(newBlock(), 1, 2);
				addImmob(newBlock(), 1, 3);
				addImmob(newBlock(), 1, 4);
				addImmob(newBlock(), 1, 5);
				addImmob(newBlock(), 1, 6);
				addImmob(newBlock(), 2, 6);
				addImmob(newBlock(), 3, 6);
				addImmob(newBlock(), 4, 6);
				addImmob(newBlock(), 5, 6);
				addImmob(newBlock(), 6, 6);
				
				addImmob(newBlock(), 6, 8);
				addImmob(newBlock(), 6, 9);
				addImmob(newBlock(), 6, 10);
				
				addImmob(newBlock(), 9, 4);
			}
			else
			{
				addEventListener(Event.ENTER_FRAME, onInitLevelFrame, false, 0, true);
			}
		}

		private function checkInput():void
		{
			var actor:Actor = Actor(_mobs[0]);
			if (actor.state == ActorState.PAUSED)
			{
				return;
			}
			const col:int = xToCol(actor.displayObject.x);
			const row:int = yToRow(actor.displayObject.y);
			const cursor:uint = _keyboard.cursorKey;

			if (_keyboard.spaceKey)
			{
				if (actor.velocity.y == 0 && actor.velocity.x == 0 && cursor != Keyboard.KEY_NONE)
				{
					pushInDirection(row, col, cursor);
					return; // process no more input
				}
			}

			switch(cursor) {
			case Keyboard.KEY_LEFT:
			case Keyboard.KEY_RIGHT:
				//
				// Limit movement to one axis at a time.
				if (actor.velocity.y == 0)
				{				
					actor.velocity.x = (cursor == Keyboard.KEY_LEFT) ? -Consts.PENGO_WALK_SPEED : Consts.PENGO_WALK_SPEED;
					actor.onEvent(ActorEvent.CHANGE_VELOCITY);
				}					
				break;
			case Keyboard.KEY_UP:
			case Keyboard.KEY_DOWN:
				if (actor.velocity.x == 0)
				{
					actor.velocity.y = (cursor == Keyboard.KEY_UP) ? -Consts.PENGO_WALK_SPEED : Consts.PENGO_WALK_SPEED;
					actor.onEvent(ActorEvent.CHANGE_VELOCITY);
				}					
				break;
			}
		}

		//
		// Returns false if space occupied by an immob or is out of bounds
		static private function isValid(row:int, col:int):Boolean
		{
			return row >= 0 && row < Consts.ROWS && col >= 0 && col < Consts.COLS; 
		}
		private function isEmpty(row:int, col:int):Boolean
		{
			 return !_immobs[row][col]; 
		}
	
		//KAI: this is where we depart from object-oriented to old-style.  The alternative would be to send a "push" event to the block
		private function pushInDirection(row:int, col:int, key:uint):void  
		{
			var rowTarget:int = row;
			var colTarget:int = col;
			var velocity:Point = new Point;
			switch(key) {
			case Keyboard.KEY_LEFT:
				--colTarget;
				break;
			case Keyboard.KEY_RIGHT:
				++colTarget;
				break;
			case Keyboard.KEY_UP:
				--rowTarget;
				break;
			case Keyboard.KEY_DOWN:
				++rowTarget;
				break;
			}
			
			if (isValid(rowTarget, colTarget))
			{
				if (!isEmpty(rowTarget, colTarget))
				{
					pushBlock(_mobs[0], row, col, rowTarget, colTarget);
				}
			}
			else
			{
				tickleWall(rowTarget, colTarget);
			}
		}
		private function pushBlock(actor:Actor, row:int, col:int, rowTarget:int, colTarget:int):void
		{
			var block:BlockActor = _immobs[rowTarget][colTarget] as BlockActor;

			if (row != rowTarget)
			{
				const deltaRow:int = rowTarget - row;
				
				if (!(actor is EnemyActor) && isValid(rowTarget + deltaRow, colTarget) && isEmpty(rowTarget + deltaRow, colTarget))
				{
					// push!
					block.velocity.y = deltaRow * Consts.BLOCK_PUSH_SPEED;
					block.velocity.x = 0;

					block.onEvent(ActorEvent.CHANGE_VELOCITY);

//					block.streak = new StreakEffect;
//					addMob(block.streak, ((block.velocity.y < 0) ? (rowTarget + 1) : rowTarget), col, 0);
//					block.streak.velocity.y = block.velocity.y; 
				}
				else
				{
					// die!
					block.onEvent(ActorEvent.DEATH);
				}
			}
			else
			{
				if (col == colTarget) throw Error;
				
				const deltaCol:int = colTarget - col;
				
				if (!(actor is EnemyActor) && isValid(rowTarget, colTarget + deltaCol) && isEmpty(rowTarget, colTarget + deltaCol))
				{
					block.velocity.x = deltaCol * Consts.BLOCK_PUSH_SPEED;
					block.velocity.y = 0;

					actor.onEvent(ActorEvent.CHANGE_VELOCITY);
					
//					block.streak = new StreakEffect;
//					addMob(block.streak, row, ((block.velocity.x < 0) ? (colTarget + 1) : colTarget), 0);
//					block.streak.velocity.x = block.velocity.x; 
				}
				else
				{
					// die!
					block.onEvent(ActorEvent.DEATH);
				}
			}

			_mobs.push(block);
			_immobs[rowTarget][colTarget] = null;
			
			//
			// A brief pause in motion after pushing
			actor.onEvent(ActorEvent.PUSHING);
		}
		private var _sides:Object =
		{
			top:
			{
				start: new Point(0, 0),
				end:   new Point(Consts.COLS * Consts.TILE_SIZE, 0),
				tickles: 0				
			},
			bottom:
			{
				start: new Point(0, Consts.ROWS * Consts.TILE_SIZE),
				end:   new Point(Consts.COLS * Consts.TILE_SIZE, Consts.ROWS * Consts.TILE_SIZE),
				tickles: 0
			},
			left:
			{
				start: new Point(0, 0),
				end:   new Point(0, Consts.ROWS * Consts.TILE_SIZE),
				tickles: 0
			},
			right:
			{
				start: new Point(Consts.COLS * Consts.TILE_SIZE, 0),
				end:   new Point(Consts.COLS * Consts.TILE_SIZE, Consts.ROWS * Consts.TILE_SIZE),
				tickles: 0
			}
		};
		private function tickleWall(row:int, col:int):void
		{
			var side:Object;
			if (row < 0)
			{
				side = _sides.top;
			}
			else if (row >= Consts.ROWS)
			{
				side = _sides.bottom;
			}
			else if (col < 0)
			{
				side = _sides.left;
			}
			else
			{
				side = _sides.right;
			}

			if (side.tickles <= 0)
			{
				side.tickles = Consts.WALL_TICKLE_FRAMES;
			}
			
			//
			// Detect enemy wall collisions
			var rect:Rectangle = new Rectangle;
			rect.topLeft = side.start;
			rect.bottomRight = side.end;
			rect.inflate(1, 1);
			for each (var actor:Actor in _mobs)
			{
				if (actor is EnemyActor)
				{
					if (actor.bounds.intersects(rect))
					{
						actor.onEvent(ActorEvent.PAUSE);
					}	
				}
			}
		}
		private function drawWall():void
		{
			graphics.lineStyle(2, Consts.WALL_COLOR);
			graphics.drawRect(_sides.left.start.x, _sides.left.start.y, _sides.right.end.x, _sides.right.end.y);
		}
		private function animateWallTickles():void
		{
			for each (var side:Object in _sides)
			{
				if (side.tickles >= 0)
				{
					graphics.lineStyle(2, ((side.tickles % 2) == 0 ? Consts.WALL_COLOR : Consts.WALL_TICKLE_COLOR));
					graphics.moveTo(side.start.x, side.start.y);
					graphics.lineTo(side.end.x, side.end.y);
					--side.tickles;
				}
			}
		}

		static private function rowToY(row:int):Number
		{
			return row * Consts.TILE_SIZE;
		}
		static private function colToX(col:int):Number
		{
			return col * Consts.TILE_SIZE;
		}
		static private function yToRow(y:Number):int
		{
			return Math.floor(y / Consts.TILE_SIZE);  //KAI: have to floor in order to make -ve's work.  Is that right?  Do you have to do this in c++?!  What effect will this have on efficiency.... 	
		}
		static private function xToCol(x:Number):int
		{
			return Math.floor(x / Consts.TILE_SIZE);	
		}
		private function newAnimator(which:String):FrameAnimator
		{
			return new FrameAnimator(_framesBitmapData, _gameXML.tile.(@name==which)[0]);
		}
		private function newEnemy():Actor
		{
			return new EnemyActor(_framesBitmapData, _gameXML);
		}
		private function newBlock():Actor
		{
			return new BlockActor(_framesBitmapData, _gameXML);
		}
		private function addMob(actor:Actor, row:int, col:int, index:int = -1):void
		{
			addActor(actor, colToX(col), rowToY(row), new Point(0, 0), index);
		}
		private function addImmob(actor:Actor, row:int, col:int):void
		{
			var obj:DisplayObject = actor.displayObject;
			obj.x = colToX(col);
			obj.y = rowToY(row);

			_immobs[row][col] = actor;
			this.addChild(obj);
		}
		private function addActor(actor:Actor, x:Number, y:Number, vel:Point, index:int):void
		{
			var obj:DisplayObject = actor.displayObject;
			obj.x = x;
			obj.y = y;
			actor.velocity = vel;
			actor.onEvent(ActorEvent.CHANGE_VELOCITY);

			_mobs.push(actor);

			if (index == -1)
			{
				this.addChild(obj);
			}
			else
			{
				this.addChildAt(obj, index);
			}
		}

		static private function haltActor(actor:Actor, x:Number, y:Number):void
		{
			actor.displayObject.x = x - (x % Consts.TILE_SIZE);
			actor.displayObject.y = y - (y % Consts.TILE_SIZE);
			actor.velocity.x = 0;
			actor.velocity.y = 0;
			actor.onEvent(ActorEvent.CHANGE_VELOCITY);
			actor.onEvent(ActorEvent.HALT);
		}
		private function mouseDown(event:MouseEvent):void
		{
			if (event.eventPhase == EventPhase.AT_TARGET)
			{
				haltActor(_mobs[0], event.stageX, event.stageY);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);
			}
		}
		private function mouseMove(event:MouseEvent):void
		{
			if (event.buttonDown)
			{
				haltActor(_mobs[0], event.stageX, event.stageY);
			}
			else
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			}
		}

		private function detectMobCollisions(actor:Actor):void
		{
			if (actor is BlockActor && (actor.velocity.x != 0 || actor.velocity.y != 0))
			{
				// We have a moving block.  See if it's colliding with any other mobs
				const actorRect:Rectangle = actor.bounds;
				const length:uint = _mobs.length;
				for (var i:uint = 0; i < length; ++i)
				{
					var candidate:Actor = _mobs[i];
					if (candidate is EnemyActor && (candidate.state != ActorState.DYING))
					{
						//KAI: maybe have more arrays - i.e. one for dying actors...
						const candidateRect:Rectangle = candidate.bounds;

						if (actorRect.intersects(candidateRect))
						{
							// die!
							candidate.onEvent(ActorEvent.DEATH);

							// align the victim in front of the moving block (it may have just caught an edge)							
							candidate.velocity.x = actor.velocity.x;
							candidate.velocity.y = actor.velocity.y;

							candidate.displayObject.x = actor.displayObject.x + Utils.normalizeDirection(actor.velocity.x)*Consts.TILE_SIZE;
							candidate.displayObject.y = actor.displayObject.y + Utils.normalizeDirection(actor.velocity.y)*Consts.TILE_SIZE;

							//
							// We may have just pushed the enemy outside the bounds, fix
							candidate.displayObject.x = Utils.restrictToRange(candidate.displayObject.x, 0, Consts.TILE_SIZE * (Consts.COLS - 1));
							candidate.displayObject.y = Utils.restrictToRange(candidate.displayObject.y, 0, Consts.TILE_SIZE * (Consts.ROWS - 1));

							candidate.onEvent(ActorEvent.CHANGE_VELOCITY);
						} 
					}
				}
			}
		}

		static private function bumpActor(actor:Actor, row:int, col:int):void
		{
			actor.velocity.x = 0;
			actor.velocity.y = 0;
			actor.displayObject.x = colToX(col);
			actor.displayObject.y = rowToY(row);

			actor.onEvent(ActorEvent.CHANGE_VELOCITY);
			actor.onEvent(ActorEvent.BUMP);
		}
		private function bumpAndImmobilizeActor(actorIndex:uint, row:int, col:int):void
		{
			var actor:Actor = _mobs[actorIndex];
			bumpActor(actor, row, col);

			if (actor.canImmobilize)
			{
				 makeImmob(actor);
				_mobs[actorIndex] = null;
			}
		}

		private var _frameNum:Number = 0;  // framerate dependency for now;  I don't care
///START level birth

		private var initStuff:Object =
		{
			currentRow: 0,
			currentFrame: 0 
		};
		private function onInitLevelFrame(event:Event):void
		{
			if (initStuff.currentRow < Consts.ROWS)
			{
				for (var j:uint = 0; j < Consts.COLS; ++j)
				{
					addImmob(newBlock(), initStuff.currentRow, j);
				}
				++initStuff.currentRow;
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, onInitLevelFrame);
				addEventListener(Event.ENTER_FRAME, onCarvePathsFrame, false, 0, true);
			}
		}
		
		private var _carveState:Object = 
		{
			row: 0,
			col: 0,
			direction: null, 
			nextLineIndex: 0,
			lineLengthRemaining: 0
		};
		private function carveBlock(row:int, col:int):void
		{
			if (isValid(row, col) && !isEmpty(row, col))
			{
				this.removeChild(Actor(_immobs[row][col]).displayObject);
				_immobs[row][col] = null;
			}
		}
		
		// some of this pathing logic might be good for the enemyactor
		private function onCarvePathsFrame(event:Event):void
		{
			if (_carveState.lineLengthRemaining > 0)
			{
				carveBlock(_carveState.row, _carveState.col);
				
				_carveState.row += _carveState.direction.row;
				_carveState.col += _carveState.direction.col;
				--_carveState.lineLengthRemaining;
			}
			else if (_carveState.nextLineIndex < _gameXML.levels.level[2].path.length())
			{
				//
				// Find the next line
				const path:XML = _gameXML.levels.level[2].path[_carveState.nextLineIndex];
				++_carveState.nextLineIndex;

				_carveState.row = int(path.@row);
				_carveState.col = int(path.@col);
				_carveState.direction =
				{
					row: int(path.@rd),
					col: int(path.@cd)
				};
				_carveState.lineLengthRemaining = int(path.@len);
			}
			else
			{
				carveBlock(Consts.ROWS/2, Consts.COLS/2);
				addMob(new TestActor(_framesBitmapData, _gameXML), 6, 6);

carveBlock(5, 5);
addMob(newEnemy(), 5, 5);
carveBlock(0, 1);
addMob(newEnemy(), 0, 1);
carveBlock(4, 4);
addMob(newEnemy(), 4, 4);
carveBlock(Consts.ROWS - 1, Consts.COLS - 1);
addMob(newEnemy(), Consts.ROWS - 1, Consts.COLS - 1);

				removeEventListener(Event.ENTER_FRAME, onCarvePathsFrame);
				addEventListener(Event.ENTER_FRAME, onGameplayFrame, false, 0, true);
				
			}
		}

///END level birth

		private const _maxEmpties:uint = 10;
		private function onGameplayFrame(event:Event):void 
		{
			checkInput();

			++_frameNum;
	
			animateWallTickles();

			const length:uint = _mobs.length;
			var edgeOffset:Point = new Point;
			var empties:uint = 0;
			for (var i:uint = 0; i < length; ++i)
			{
				var actor:Actor = _mobs[i];
				if (!actor)
				{
					++empties;
					continue;
				}
				if (actor.state == ActorState.DEAD)
				{
					this.removeChild(actor.displayObject);
					_mobs[i] = null;
					continue;
				}

				actor.onFrame(_frameNum);

				if (actor is EnemyActor)
				{
					enemyAI(EnemyActor(actor));
				}

				//
				// See if this actor's crossing a tile boundary.  Direction of movement
				// matters, from that we determine which edge to collision detect.
				//
				// This whole rigamarole is really an efficiency step to collision detect blocks
				// with the _immob array instead of doing rect intersections against every block
				edgeOffset.x = edgeOffset.y = 0;
				if (actor.velocity.x > 0)
				{
					edgeOffset.x = Consts.TILE_SIZE - 1;
				}
				else if (actor.velocity.y > 0)
				{
					edgeOffset.y = Consts.TILE_SIZE - 1;
				}

				const row:int = yToRow(actor.leadingEdgeY);
				const col:int = xToCol(actor.leadingEdgeX);

				actor.applyVelocity();

				const newRow:int = yToRow(actor.leadingEdgeY);
				const newCol:int = xToCol(actor.leadingEdgeX);

				if (row != newRow || col != newCol)
				{
					//
					// If the actor's encroached on a bad tile or screen edge, bump them back
					if (!isValid(newRow, newCol) || !isEmpty(newRow, newCol))
					{
						if (actor is EnemyActor && EnemyActor(actor).bCrushing && isValid(newRow, newCol) && !isEmpty(newRow, newCol))
						{
							//
							// If they're an enemy bumping into an ice brick, let them break or push it
							pushBlock(actor, row, col, newRow, newCol);
						}
						else
						{
							bumpAndImmobilizeActor(i, row, col);
							
							var block:BlockActor = actor as BlockActor;
							if (block && block.streak)
							{
								block.streak.onEvent(ActorEvent.CHANGE_VELOCITY);
								block.streak.velocity.x = 0;
								block.streak.velocity.y = 0;
								block.streak = null;
							}
						}
					}
					
					//
					// If it's the player and the movement key is still not down for this direction,
					// also bump back
					if (actor is TestActor)
					{
						const cursor:uint = _keyboard.cursorKey;
						if ((actor.velocity.x > 0 && cursor != Keyboard.KEY_RIGHT) ||
						    (actor.velocity.x < 0 && cursor != Keyboard.KEY_LEFT)  ||
						    (actor.velocity.y > 0 && cursor != Keyboard.KEY_DOWN)  ||
						    (actor.velocity.y < 0 && cursor != Keyboard.KEY_UP))
					    {
					    	bumpActor(actor, row, col);
					    } 
					}
				}
				
				detectMobCollisions(actor);
			}
			if (empties > _maxEmpties)
			{
				disposeEmpties();
				dbg("Disposed " + empties + " empties");
			}
		}
		
		private function disposeEmpties():void
		{
			_mobs = _mobs.filter(function(element:*, i:int, a:Array):Boolean { return element != null; }); 			
		}
		private function makeImmob(actor:Actor):Boolean
		{
			if (actor is BlockActor)
			{
				_immobs[yToRow(actor.displayObject.y)][xToCol(actor.displayObject.x)] = actor;
				return true;
			}
			return false;
		}
		
		static private function enemyAI(enemy:EnemyActor):void
		{
			if (enemy.state != ActorState.NORMAL)
			{
				return;
			}

			var obj:DisplayObject = enemy.displayObject;
			if ((enemy.velocity.x > 0 && obj.x >= enemy.destination) ||
			    (enemy.velocity.x < 0 && obj.x <= enemy.destination)) 
			{
				bumpActor(enemy, yToRow(obj.y), xToCol(enemy.destination));				
			}
			else if ((enemy.velocity.y > 0 && obj.y >= enemy.destination) ||
			         (enemy.velocity.y < 0 && obj.y <= enemy.destination))
			{
				bumpActor(enemy, yToRow(enemy.destination), xToCol(obj.x));	
			}

			//
			// Pick a new destination if ones already been reached, or we bumped into something
			if (enemy.velocity.x == 0 && enemy.velocity.y == 0)
			{
				if (Math.random() > 0.5)
				{
					do
					{
						enemy.destination = Utils.randomInt(0, Consts.COLS - 1) * Consts.TILE_SIZE;
					} while (enemy.destination == obj.x);
					
					enemy.velocity.x = enemy.walkSpeed * ((enemy.destination > obj.x) ? 1 : -1);
					enemy.onEvent(ActorEvent.CHANGE_VELOCITY);
					//dbg("horz with destination " + enemy.destination);
				}
				else
				{
					do
					{
						enemy.destination = Utils.randomInt(0, Consts.ROWS - 1) * Consts.TILE_SIZE;
					} while(enemy.destination == obj.y);
					
					enemy.velocity.y = enemy.walkSpeed * ((enemy.destination > obj.y) ? 1 : -1);
					enemy.onEvent(ActorEvent.CHANGE_VELOCITY);
					//dbg("vert with destination " + enemy.destination);
				}
			}
		}
		
	} // class
	
}
	import flash.display.DisplayObject;
	 // package

//
// This abstracts away the axis such that the typical x2 duplication of logic for each axis can
// be folded into a single block of code.  The cost comes in extra function calls
internal interface IAxis
{
	function set actor(a:Actor):void;
	function get x():Number;
	function set x(_x:Number):void;
	function get y():Number;
	function set y(_y:Number):void;
	function get COLS():uint;
	function get ROWS():uint;
	function get velocityX():Number;
	function set velocityX(_x:Number):void;
	function get velocityY():Number;
	function set velocityY(_x:Number):void;
}

internal class AxisBaseImpl
{
	protected var _actor:Actor;
	protected var _do:DisplayObject;
	public function set actor(a:Actor):void
	{
		_actor = a;
		_do = a.displayObject;
	}
}
internal final class XAxis extends AxisBaseImpl implements IAxis
{
	public function get x():Number
	{
		return _do.x;
	}
	public function set x(_x:Number):void
	{
		_do.x = _x;
	}
	public function get y():Number
	{
		return _do.y;	
	}
	public function set y(_y:Number):void
	{
		_do.y = _y;	
	}
	public function get COLS():uint
	{
		return Consts.COLS;
	}
	public function get ROWS():uint
	{
		return Consts.ROWS;
	}
	public function get velocityX():Number
	{
		return _actor.velocity.x;
	}
	public function set velocityX(_x:Number):void
	{
		_actor.velocity.x = _x;
	}
	public function get velocityY():Number
	{
		return _actor.velocity.y;
	}
	public function set velocityY(_y:Number):void
	{
		_actor.velocity.y = _y;
	}
}

internal final class YAxis extends AxisBaseImpl implements IAxis
{
	public function get x():Number
	{
		return _do.y;
	}
	public function set x(_x:Number):void
	{
		_do.y = _x;
	}
	public function get y():Number
	{
		return _do.x;
	}
	public function set y(_y:Number):void
	{
		_do.x = _y;
	}
	public function get COLS():uint
	{
		return Consts.ROWS;
	}
	public function get ROWS():uint
	{
		return Consts.COLS;
	}
	public function get velocityX():Number
	{
		return _actor.velocity.y;
	}
	public function set velocityX(_x:Number):void
	{
		_actor.velocity.y = _x;
	}
	public function get velocityY():Number
	{
		return _actor.velocity.x;
	}
	public function set velocityY(_y:Number):void
	{
		_actor.velocity.x = _y;	
	}
}