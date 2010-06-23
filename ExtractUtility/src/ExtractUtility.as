package
{
	import flash.display.Sprite;
	
	public class ExtractUtility extends Sprite
	{
		public function ExtractUtility()
		{
			scriptPrologue();
//			generateShapesExtractScript();
			generateMovieClipsExtractScript();
			scriptEpilogue();
		}
		
		private static const FILE:String = "metalarena3.swf";
		private static const OUTPUT_DIR:String = "out";
		private static const SHAPES:String = "1, 17-19, 21, 62-65, 68, 70, 72, 74, 76-79, 81-98, 101,103, 105, 107, 109, 111, 113, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134,136, 138, 140, 142, 144, 146, 205, 206, 212, 226, 230, 232, 234, 244, 247, 252,255, 257, 261, 267, 270, 273, 278, 281, 283, 285, 287, 289, 294, 296, 299, 301,303, 305, 307, 309, 311, 315, 338, 343, 348, 352, 354, 357, 366, 368, 370, 547,549, 551, 553, 558-560, 565, 566, 575, 598, 608, 625, 629";
		private static const MOVIECLIPS:String = "3, 5, 6, 8, 10, 14, 22-25, 49, 51, 55-58, 60, 99, 114, 147, 148, 150, 152, 154, 156, 157, 159, 160, 162, 163, 165, 166, 168, 169, 171, 172, 174, 175, 177, 179, 181, 182, 184, 186, 187, 189, 190, 192, 193, 195, 196, 198, 199, 201-203, 207, 211, 213, 215, 216, 218, 221, 222, 263, 265, 268, 271, 274, 276, 277, 279, 280, 282, 284, 286, 288, 290-293, 295, 297, 298, 300, 302, 304, 306, 308, 310, 312, 313, 320, 322, 325, 334, 336, 341, 345, 346, 350, 355, 359, 362, 364, 365, 367, 369, 371, 372, 375, 377, 378, 381, 383, 384, 387, 389, 390, 393, 395, 396, 399, 401-403, 406, 408, 409, 412, 414, 415, 418, 420, 421,424, 426, 427, 430, 432, 433, 436, 438-441, 449-456, 460-465, 487, 489, 493, 494, 497, 504, 535, 537, 538, 540, 542, 544, 548, 552, 554-556, 564, 568, 574, 576, 583, 586, 587, 589, 593, 594, 599, 602-605, 609, 622, 626, 639, 642";
		private static const JPGS:String = "11, 100, 102, 104, 106, 108, 110, 112, 115, 117, 119, 121, 123, 125, 127, 129, 131, 133, 135, 137, 139, 141, 143, 145, 204, 223, 225, 229, 231, 233, 243, 246, 251, 254, 266, 269, 272, 342, 347, 351, 353, 442, 550, 607";
		private static const PNGS:String = "256, 260, 314, 326, 337, 628";
		
		private static function extractIDs(str:String):Array
		{
			var retval:Array = [];
			for each (var sub:String in str.split(","))
			{
				var range:Array = sub.split("-");
				if (range.length == 2)
				{
					for (var i:uint = parseInt(range[0]); i < parseInt(range[1]); ++i)
					{
						retval.push(i);
					}
				}
				else
				{
					retval.push(parseInt(sub));
				}
			}
			return retval;
		}
		private static function scriptPrologue():void
		{
			trace("----------------- SCRIPT BEGIN ----------------");
			trace("@echo off");
		}
		private static function scriptEpilogue():void
		{
			trace("----------------- SCRIPT END ----------------");
		}
		private static function generateShapesExtractScript():void
		{
			var ids:Array = extractIDs(SHAPES);
			for each (var id:String in ids)
			{
				trace("swfextract -i", id, FILE, "-o", OUTPUT_DIR + "\\shape_" + id + ".swf");
			}
		}
		private static function generateMovieClipsExtractScript():void
		{
			var ids:Array = extractIDs(MOVIECLIPS);
			for each (var id:String in ids)
			{
				trace("swfextract -i", id, FILE, "-o", OUTPUT_DIR + "\\mc_" + id + ".swf");
			}
		}
	}
}