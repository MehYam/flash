package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import karnold.ui.ProgressMeter;
	
	public class ScoreBoard extends Sprite
	{
		static private const GAP:Number = 10;
		
		private var _health:ProgressMeter;
		private var _level:ProgressMeter;
		private var _earnings:ShadowTextField;
		public function ScoreBoard()
		{
			super();
			
			mouseEnabled = false;
			mouseChildren = false;
			
			var labelFormat:TextFormat = new TextFormat("Radio Stars", 24, null);
			var labelField:ShadowTextField = new ShadowTextField(labelFormat);
			labelField.text = "Health:";
			addChild(labelField);

			_health = new ProgressMeter(120, 18, 0, 0xff0000);
			_health.pct = .30;
			_health.x = labelField.x + labelField.width + GAP/2;
			_health.y = labelField.y + GAP/2 + 2;
			addChild(_health);

			var horz:Number = _health.x + _health.width + GAP;

			labelField = new ShadowTextField(labelFormat);
			labelField.text = "Level:";
			labelField.x = horz;
			addChild(labelField);
			
			_level = new ProgressMeter(120, 18, 0, 0x0033ff);
			_level.pct = .5;
			_level.x = labelField.x + labelField.width + GAP/2;
			_level.y = _health.y;
			addChild(_level);

			var vert:Number = labelField.y + labelField.height;
			addChild(labelField);
			
			labelField = new ShadowTextField(labelFormat);
			labelField.text = "Earnings:";
			labelField.y = vert;
			horz = labelField.x + labelField.width + GAP/2;
			addChild(labelField);
			
			_earnings = new ShadowTextField(labelFormat);
			_earnings.text = "0";
			_earnings.x = horz;
			_earnings.y = vert;
			addChild(_earnings);
		}
		
		public function set pctLevel(p:Number):void
		{
			_level.pct = p;
		}
		public function set pctHealth(p:Number):void
		{
			_health.pct = p;
		}
		public function set earnings(e:uint):void
		{
			_earnings.text = String(e);
		}
	}
}