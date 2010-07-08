package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import karnold.ui.ProgressMeter;
	
	public class ScoreBoard extends Sprite
	{
		public function ScoreBoard()
		{
			super();
			
			var labelFormat:TextFormat = new TextFormat("Impact", 24);
			var labelField:ShadowTextField = new ShadowTextField(labelFormat);
			labelField.text = "Health:";
			addChild(labelField);

			var health:ProgressMeter = new ProgressMeter(150, 18, 0, 0xff0000);
			health.pct = .30;
			health.x = labelField.x + labelField.width + 10;
			health.y = labelField.y + 10;
			addChild(health);

			var vert:Number = health.x + health.width + 5;

			labelField = new ShadowTextField(labelFormat);
			labelField.text = "Level:";
			labelField.x = vert;
			addChild(labelField);
			
			var progress:ProgressMeter = new ProgressMeter(150, 18, 0, 0x0033ff);
			progress.pct = .5;
			progress.x = labelField.x + labelField.width + 10;
			progress.y = health.y;
			addChild(progress);

			var horz:Number = labelField.y + labelField.height;
			addChild(labelField);
			
			labelField = new ShadowTextField(labelFormat);
			labelField.text = "Earnings:";
			labelField.y = horz;
			addChild(labelField);
			
		}
	}
}