package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import karnold.tile.IBitmapFactory;

	public class AssetManager implements IBitmapFactory
	{
		public function AssetManager()
		{
		}

		//KAI: if this goes in-game, it's better to load it and ditch the loader so that the bitmap data's not duplicated
		// when we copy it out - OR - see if Bitmap is really smart, and just use the tiled thing.  Worth profiling to
		// see what the difference is
		[Embed(source="assets/tiled.png")] static private const TiledImages:Class;
		
		static private var s_instance:AssetManager;
		static public function get instance():AssetManager
		{
			if (!s_instance)
			{
				s_instance = new AssetManager;
			}
			return s_instance;
		}

		static public const TILES:uint = 14;
		static public const TILES_SIZE:uint = 40;
		static private const TILE_COLUMNS:uint = 4;

		private var _cachedTiles:Array;

		public function getBitmap(index:uint):Bitmap
		{
			if (!_cachedTiles)
			{
				_cachedTiles = [];

				var bitmap:Bitmap = new TiledImages;
				var origin:Point = new Point(0, 0);
				for (var i:uint = 0; i < TILES; ++i)
				{
					var tileBMD:BitmapData = new BitmapData(TILES_SIZE, TILES_SIZE, false);
					var srcRect:Rectangle = new Rectangle((i % TILE_COLUMNS) * TILES_SIZE, int(i / TILE_COLUMNS) * TILES_SIZE, TILES_SIZE, TILES_SIZE);

					tileBMD.copyPixels(bitmap.bitmapData, srcRect, origin);
					
					_cachedTiles.push(tileBMD);
				}
			}
			var retval:Bitmap = new Bitmap(_cachedTiles[index]);
//			retval.smoothing = true;
			return retval;
		}

		private var _sounds:Dictionary = new Dictionary;
		private function playSound(sound:Class):void
		{
			var soundInstance:Sound = _sounds[sound];
			if (!soundInstance)
			{
				soundInstance = _sounds[sound] = new sound() as Sound;
			}
			soundInstance.play();
		}

		[Embed(source="assets/sounds/crash1.mp3")] static private const Crash1Sound:Class;
		[Embed(source="assets/sounds/laser1.mp3")] static private const Laser1Sound:Class;
		[Embed(source="assets/sounds/laser2.mp3")] static private const Laser2Sound:Class;
		[Embed(source="assets/sounds/bump1.mp3")] static private const Bump1Sound:Class;
		[Embed(source="assets/sounds/bump2.mp3")] static private const Bump2Sound:Class;
		[Embed(source="assets/sounds/bump3.mp3")] static private const Bump3Sound:Class;
		static private const s_bumpSounds:Array = [Bump1Sound, Bump2Sound, Bump3Sound];
		[Embed(source="assets/sounds/explosion1.mp3")] static private const Explosion1Sound:Class;
		[Embed(source="assets/sounds/explosion2.mp3")] static private const Explosion2Sound:Class;
		[Embed(source="assets/sounds/explosion3.mp3")] static private const Explosion3Sound:Class;
		[Embed(source="assets/sounds/explosion4.mp3")] static private const Explosion4Sound:Class;
		[Embed(source="assets/sounds/explosion5.mp3")] static private const Explosion5Sound:Class;
		[Embed(source="assets/sounds/brush1.mp3")] static private const Explosion6Sound:Class;
		static private const s_explosionSounds:Array = [Explosion1Sound, Explosion2Sound, Explosion3Sound, Explosion4Sound, Explosion6Sound].concat(s_bumpSounds);
		[Embed(source="assets/sounds/click.mp3")] static private const UIClickSound:Class;
		[Embed(source="assets/sounds/fusion1.mp3")] static private const Fusion1Sound:Class;
		[Embed(source="assets/sounds/fusion2.mp3")] static private const Fusion2Sound:Class;
		[Embed(source="assets/sounds/fusion3.mp3")] static private const Fusion3Sound:Class;
		[Embed(source="assets/sounds/fusion4.mp3")] static private const Fusion4Sound:Class;
		static private const s_bulletSounds:Array = [Fusion1Sound, Fusion2Sound, Fusion3Sound, Fusion4Sound];
		[Embed(source="assets/sounds/shot1.mp3")] static private const Shot1Sound:Class;
		[Embed(source="assets/sounds/shot2.mp3")] static private const Shot2Sound:Class;
		[Embed(source="assets/sounds/shot3.mp3")] static private const Shot3Sound:Class;
		static private const s_shotSounds:Array = [Shot1Sound, Shot2Sound, Shot3Sound];
		[Embed(source="assets/sounds/blast1.mp3")] static private const RocketSound:Class;
		[Embed(source="assets/sounds/shieldsorcloak2.mp3")] static private const ShieldSound:Class;
		[Embed(source="assets/sounds/purchase1.mp3")] static private const FusionSound:Class;
		[Embed(source="assets/sounds/bump1.mp3")] static private const Collision1Sound:Class;
		[Embed(source="assets/sounds/bump2.mp3")] static private const Collision2Sound:Class;
		[Embed(source="assets/sounds/bump3.mp3")] static private const Collision3Sound:Class;
		static private const s_collisionSounds:Array = [Collision1Sound, Collision2Sound, Collision3Sound];
		[Embed(source="assets/sounds/laserbounce1.mp3")] static private const LaserBounce1Sound:Class;
		[Embed(source="assets/sounds/laserbounce2.mp3")] static private const LaserBounce2Sound:Class;
		[Embed(source="assets/sounds/laserbounce3.mp3")] static private const LaserBounce3Sound:Class;
		[Embed(source="assets/sounds/laserbounce4.mp3")] static private const LaserBounce4Sound:Class;
		[Embed(source="assets/sounds/laserbounce5.mp3")] static private const LaserBounce5Sound:Class;
		static private const s_laserBounceSounds:Array = [LaserBounce1Sound, LaserBounce2Sound, LaserBounce3Sound, LaserBounce4Sound, LaserBounce5Sound];

		public function laser1Sound():void { playSound(Laser1Sound); }
		public function laser2Sound():void { playSound(Laser2Sound); }
		public function deathSound():void { playSound(Crash1Sound); }
		public function bulletSound(pct:Number):void { playSound(s_bulletSounds[uint(pct * s_bulletSounds.length)]); }
		public function bumpSound():void { playSound(s_bumpSounds[uint(Math.random() * s_bumpSounds.length)]); }
		public function explosionSound():void { playSound(s_explosionSounds[uint(Math.random() * s_explosionSounds.length)]);	}
		public function explosionSoundIndex(index:uint):void { playSound(s_explosionSounds[index]);	}
		public function shotSound(pct:Number):void { playSound(s_shotSounds[uint(pct * s_shotSounds.length)]); }
		public function rocketSound():void { playSound(RocketSound); }
		public function shieldLaunchSound():void { playSound(ShieldSound); }
		public function fusionSound():void { playSound(FusionSound); }
		public function collisionSound():void { deathSound(); }//playSound(s_collisionSounds[uint(Math.random() * s_collisionSounds.length)]); }
		public function laserBounceSound():void { playSound(s_laserBounceSounds[uint(Math.random() * s_laserBounceSounds.length)]); }
		public function uiClick():void { playSound(UIClickSound); }

		static private const s_uiFaceScale9:Rectangle = new Rectangle(10, 10, 30, 30);
		public function uiFace(color:uint):DisplayObject
		{
			var rect:Shape = new Shape;
			
			rect.graphics.lineStyle(1);
			rect.graphics.beginFill(color);
			rect.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
			rect.graphics.endFill();
			
			rect.scale9Grid = s_uiFaceScale9;
			return rect;			
		}
		static private const s_faceFilter:Array = [new BevelFilter(3, 45)]; 
		public function buttonFace(raised:Boolean = true):DisplayObject
		{
			var retval:DisplayObject = uiFace(0x555577);
			if (raised)
			{
				retval.filters = s_faceFilter;
			}
			return retval;
		}
		public function buttonFaceDown():DisplayObject
		{
			var retval:DisplayObject = uiFace(0xa6a6a6); 
			var colorTransform:ColorTransform = retval.transform.colorTransform;
			colorTransform.greenOffset = 10;
			colorTransform.blueOffset = -0xff;
			colorTransform.redOffset = -0xff;
			
			retval.transform.colorTransform = colorTransform;
			return retval;
		}
		static private const s_faceOverFilter:Array = [new BevelFilter(3, 45), new DropShadowFilter(2)];
		public function buttonFaceOver(raised:Boolean = true):DisplayObject
		{
			var retval:DisplayObject = uiFace(0xa6a6a6);
			var colorTransform:ColorTransform = retval.transform.colorTransform;
			colorTransform.greenOffset = 32;
			colorTransform.blueOffset = -0xff;
			colorTransform.redOffset = -0xff;

			retval.transform.colorTransform = colorTransform;
			if (raised)
			{
				retval.filters = s_faceOverFilter;
			}
			return retval;
		}
		static private const s_innerFaceFilter:Array = [new BevelFilter(3, 235)];
		public function innerFace():DisplayObject
		{
			var rect:DisplayObject = uiFace(0xcccccc);
			rect.filters = s_innerFaceFilter
			return rect;
		}

		[Embed(source="assets/master.swf", symbol="checkmark")]		static private const CHECKMARK:Class;
		[Embed(source="assets/master.swf", symbol="arrow")]		static private const ARROW:Class;
		[Embed(source="assets/master.swf", symbol="lock")]		static private const LOCK:Class;
		[Embed(source="assets/master.swf", symbol="question")]		static private const QUESTION:Class;
		[Embed(source="assets/master.swf", symbol="planeIcon")]		static private const PLANEICON:Class;
		[Embed(source="assets/master.swf", symbol="tankIcon")]		static private const TANKICON:Class;
		
		static private const s_uiStuffDropShadow:Array = [new DropShadowFilter(2, 45, 0, 1, 1, 1)];
		public function checkmark():DisplayObject
		{
			var retval:DisplayObject = new CHECKMARK;
			retval.filters = s_uiStuffDropShadow;
			return retval; 
		}
		public function arrow():DisplayObject
		{	
			var retval:DisplayObject = new ARROW;
			retval.scaleX = .5;
			retval.scaleY = .5;
			retval.filters = s_uiStuffDropShadow;
			InteractiveObject(retval).mouseEnabled = false;
			return retval; 
		}
		public function lock():DisplayObject
		{	
			var retval:DisplayObject = new LOCK;
			retval.filters = s_uiStuffDropShadow;
			return retval; 
		}
		public function question():DisplayObject
		{	
			var retval:DisplayObject = new QUESTION;
			retval.filters = s_uiStuffDropShadow;
			return retval; 
		}
		public function planeIcon():DisplayObject
		{
			var retval:DisplayObject = new PLANEICON;
//			retval.filters = s_uiStuffDropShadow;
			return retval; 
		}
		public function tankIcon():DisplayObject
		{
			var retval:DisplayObject = new TANKICON;
//			retval.filters = s_uiStuffDropShadow;
			return retval; 
		}
		
		[Embed(source='assets/fonts/Computerfont.ttf', fontFamily='embeddedComputerfont', mimeType='application/x-font', embedAsCFF='false')]		static private const Computerfont:Class;
		[Embed(source='assets/fonts/RADIOSTA.TTF', fontFamily='embeddedRadiostars', mimeType='application/x-font', embedAsCFF='false')] 		static private const Radiofont:Class;
		[Embed(source='assets/fonts/SF TransRobotics.ttf', fontFamily='embeddedSFT', mimeType='application/x-font', embedAsCFF='false')]		static private const SFTfont:Class;
		
		static public const FONT_COMPUTER:String = "embeddedSFT";//"embeddedComputerfont";
		static public const FONT_RADIOSTARS:String = "embeddedRadiostars";
		static public const FONT_ROBOT:String = "embeddedSFT";
		public function createFont(font:String, size:int, color:Object = null):TextFormat
		{
			var retval:TextFormat = new TextFormat;
			retval.font = font;
			retval.size = size;
			retval.color = color;
			return retval;
		}
		public function assignFont(textFieldObject:Object, font:String, size:int, color:Object = null):void
		{
			assignTextFormat(textFieldObject, createFont(font, size, color));
		}
		public function assignTextFormat(textFieldObject:Object, textFormat:TextFormat):void
		{
			textFieldObject.defaultTextFormat = textFormat;
			textFieldObject.embedFonts = true;
		}
		static private const MBFILTER:Array = [new DropShadowFilter(1, 45, 0xffffff, 1, 0, 0)];
		public function get messageBoxFontShadow():Array
		{
			// start using this in favor of ShadowTextField;
			return MBFILTER;
		}
		public function get messageBoxFont():TextFormat
		{
			return createFont(AssetManager.FONT_COMPUTER, 18, 0);
		}
		
		[Embed(source="assets/instructions1_small.png")] static private const Tutorial2:Class;
		[Embed(source="assets/instructions2_small.png")] static private const Tutorial1:Class;
		static private const TUTIMGS:Array = [Tutorial1, Tutorial2];
		public function getTutorialImage(index:uint):Bitmap
		{
			var bitmap:Bitmap = new TUTIMGS[index];
			bitmap.smoothing = true;
			return bitmap;
		}
	}
}