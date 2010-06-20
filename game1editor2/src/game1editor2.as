package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	public class game1editor2 extends Sprite
	{
		public function game1editor2()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			var imageSelect:DisplayObject = new ImageSelect;
			imageSelect.scaleX = 1.5;
			imageSelect.scaleY = 1.5;
			addChild(imageSelect);			
		}
	}
}