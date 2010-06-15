package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class RasterTextField extends Bitmap
	{
		[Embed(source="chars_courier_new_10.png")]
		private static var Glyphs:Class;
		private static var s_glyphImage:Bitmap;

		private static const CHAR_WIDTH:uint = 8;
		private static const CHAR_HEIGHT:uint = 16;
		private static const CHARS_PER_ROW:uint = 15;
		private static const FIRST_CHAR_CODE:uint = " ".charCodeAt(0); 
		private static const DIGIT_ZERO_CHAR_CODE:uint = "0".charCodeAt(0);
		public function RasterTextField()
		{
		}
		
		private var _integer:int;
		private var _charsArray:ByteArray;
		private var _suffix:String;
		private static function simpleAbs(num:int):int
		{
			return (num < 0) ? -num : num;
		}
		public function set integer(newInteger:int):void
		{
			//
			// Record the digits
			if (!_charsArray)
			{
				_charsArray = new ByteArray();
			}
			else if (_integer == newInteger)
			{
				return;
			}

			_integer = newInteger;
			_charsArray.position = 0;
			
			while (newInteger)
			{
				_charsArray.writeByte((simpleAbs(newInteger) % 10) + DIGIT_ZERO_CHAR_CODE);
				newInteger /= 10;
			}

			render();
		}
		public function set suffix(sfx:String):void
		{
			if (_suffix != sfx)
			{
				_suffix = sfx;
				render();
			}
		}

		private static var s_sourceReuse:Rectangle = new Rectangle;
		private static var s_destReuse:Point = new Point;
		private function printChar(charCode:int, pos:int):void
		{
			const ithChar:uint = charCode - FIRST_CHAR_CODE;
			
			s_sourceReuse.left = (ithChar % CHARS_PER_ROW) * CHAR_WIDTH;
			s_sourceReuse.top = uint(ithChar / CHARS_PER_ROW) * CHAR_HEIGHT;
			s_sourceReuse.width = CHAR_WIDTH;
			s_sourceReuse.height = CHAR_HEIGHT;
			
			s_destReuse.x = pos * CHAR_WIDTH;
			s_destReuse.y = 0;
			
			this.bitmapData.copyPixels(s_glyphImage.bitmapData, s_sourceReuse, s_destReuse);
		}
		//
		// EFFICIENCY NOTE: as it stands, this is roughly as efficient (in wall-clock time) as setting a number into a TextField.
		// This can be made up to two orders of magnitude more efficient if we save the value of the number and only do the render
		// in the RENDER or ENTER_FRAME event (i.e. add and remove ENTER_FRAME as necessary)
		private var _lastRenderedCharCount:int = -1;
		private function render():void
		{
			//
			// Render them
			if (!s_glyphImage)
			{
				s_glyphImage = new Glyphs();
			}
			
			const charCount:int = (_charsArray.position + (_suffix ? _suffix.length : 0));
			if (!this.bitmapData || charCount > _lastRenderedCharCount)
			{
				this.bitmapData = new BitmapData(CHAR_WIDTH * charCount, CHAR_HEIGHT);
			}
			for (var i:int = _charsArray.position - 1; i >= 0; --i)
			{
				// this is a generalized algorithm for any chars, not just numbers
				printChar(_charsArray[i], _charsArray.position - i - 1);
			}

			if (_suffix && _lastRenderedCharCount != charCount)
			{
				const length:int = _suffix.length;
				for (var s:int = 0; s < length; ++s)
				{
					printChar(_suffix.charCodeAt(s), s + _charsArray.position);
				} 
			}

			//
			// Clear any previous chars
			if (charCount < _lastRenderedCharCount)
			{
				for (var c:int = charCount; c < _lastRenderedCharCount; ++c)
				{
					printChar(FIRST_CHAR_CODE, c);
				}
			}
			_lastRenderedCharCount = charCount;
		}
	}
}