// ActionScript file
package
{
	public class Consts
	{
		public static const TEST_MODE:Boolean = false;
		public static const FRAME_RATE:int = 32;

		public static const TOP_LEFT:uint = 20;
		public static const ROWS:uint = 15;
		public static const COLS:uint = 13;
		public static const TILE_SIZE:uint = 32;
		public static const ACTOR_PADDING:uint = 0;
		public static const SPEED_SCALE:Number = 0.4;

		public static const WALL_COLOR:uint = 0xffffff;
		public static const WALL_TICKLE_COLOR:uint = 0xafaf00;
		public static const WALL_TICKLE_FRAMES:uint = 15;

		public static const LEVEL_BIRTH_FILL_RATE:uint = 1;
		public static const PENGO_WALK_SPEED:Number = 8 * SPEED_SCALE;
		public static const POST_PUSH_PAUSE_FRAMES:uint = 8;

		public static const ENEMY_WALK_SPEED:Number = 5 * SPEED_SCALE;
		public static const ENEMY_WALK_SPEED_SLOWED:Number = 0.5 * ENEMY_WALK_SPEED;
		public static const ENEMY_SLOWED_FRAMES:uint = 40;
		public static const ENEMY_ALPHA:Number = 0.8;
		public static const ENEMY_COLOR:uint = 0xff0f0f;  
		public static const ENEMY_DEATH_FRAMES:uint = 40;
		public static const ENEMY_DEATH_COLOR:uint = 0xff00;
		public static const ENEMY_TICKLE_FRAMES:uint = 60;
		public static const ENEMY_TICKLE_COLOR:uint = 0xff00;
		public static const ENEMY_PUSH_ODDS:Number = 0.2;
		public static const ENEMY_MIN_CRUSHING_FRAMES:uint = 120;
		public static const ENEMY_MAX_CRUSHING_FRAMES:uint = 600;
		public static const ENEMY_MAX_NON_CRUSHING_FRAMES:uint = ENEMY_MAX_CRUSHING_FRAMES; 
		
		public static const BLOCK_ALPHA:Number = 0.8;
		public static const BLOCK_DEATH_FRAMES:uint = 20;
		public static const BLOCK_COLOR:uint = 0xff;
		public static const BLOCK_DEATH_COLOR:uint = 0xffffff;
		public static const BLOCK_PUSH_SPEED:Number = 20;
		
		public static const STREAK_COLOR:uint = 0xffffff;
		public static const STREAK_FADE_FRAMES:uint = 10;
		public static const STREAK_BREADTH:uint = TILE_SIZE - ACTOR_PADDING*2;
		public static const STREAK_LENGTH:uint = TILE_SIZE * 5; 
	}
}