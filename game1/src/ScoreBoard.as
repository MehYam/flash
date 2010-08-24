package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import karnold.ui.ProgressMeter;
	import karnold.ui.ShadowTextField;
	import karnold.utils.FrameTimer;
	
	public class ScoreBoard extends Sprite
	{
		static private const GAP:Number = 10;
		
		private var _health:ProgressMeter;
		private var _wave:ProgressMeter;
		private var _earnings:ShadowTextField;
		private var _comboIndicator:ShadowTextField;
		public function ScoreBoard()
		{
			super();
			
			mouseEnabled = false;
			mouseChildren = false;
			
			var labelFormat:TextFormat = new TextFormat("Radio Stars", 24, null);
			var labelField:ShadowTextField = new ShadowTextField(labelFormat);
			labelField.text = "Health:";
			labelField.cacheAsBitmap = true;
			addChild(labelField);

			_health = new ProgressMeter(120, 18, 0, 0xff0000);
			_health.pct = .30;
			_health.x = labelField.x + labelField.width + GAP/2;
			_health.y = labelField.y + GAP/2 + 1;
			addChild(_health);

			var horz:Number = _health.x + _health.width + GAP;

			labelField = new ShadowTextField(labelFormat);
			labelField.text = "Earnings:";
			labelField.cacheAsBitmap = true;
			labelField.x = horz;
			addChild(labelField);
			
			_earnings = new ShadowTextField(new TextFormat("SF TransRobotics", 26));
			_earnings.text = "0";
			_earnings.x = labelField.x + labelField.width + GAP/2;
			_earnings.y = -4;
			addChild(_earnings);

			var vert:Number = labelField.y + labelField.height - 6;

			labelField = new ShadowTextField(labelFormat);
			labelField.text = "Wave:";
			labelField.x = 0;
			labelField.y = vert;
			labelField.cacheAsBitmap = true;
			addChild(labelField);
			
			_wave = new ProgressMeter(120, 18, 0, 0x0033ff);
			_wave.pct = .5;
			_wave.x = _health.x;
			_wave.y = labelField.y + GAP/2 + 1;
			addChild(_wave);

			_comboIndicator = new ShadowTextField(new TextFormat("SF TransRobotics", 20));
			_comboIndicator.x = _earnings.x + GAP;
			_comboIndicator.y = _earnings.y + _earnings.height - 9;
			combo = 1;
			addChild(_comboIndicator);
		}
		
		public function set pctLevel(p:Number):void
		{
			_wave.pct = p;
		}
		public function set pctHealth(p:Number):void
		{
			_health.pct = p;
			if (p > .33)
			{
				_health.fgColor = 0x00ff00;
			}
			else if (p > .10)
			{
				_health.fgColor = 0xffff00;
			}
			else
			{
				_health.fgColor = 0xff0000;
			}
		}
		public function set earnings(e:uint):void
		{
			_earnings.text = String(e);
		}
		private var _comboAnimate:FrameTimer = new FrameTimer(onComboAnimate);
		private var _lastCombo:uint;
		private var _color:uint = 0xffffff;
		public function set combo(val:uint):void
		{
			if (val > 1)
			{
				_comboIndicator.visible = true;
				_comboIndicator.text = val + "x COMBO";
				
				_comboAnimate.startPerFrame();
				_comboIndicator.alpha = 1;
				
				_comboIndicator.fgColor = val > _lastCombo ? 0xffff00 : 0xff0000;
			}
			else
			{
				_comboIndicator.visible = false;
				
				_comboAnimate.stop();
			}
			_lastCombo = val;
		}
		private function onComboAnimate():void
		{
			if (_comboIndicator.alpha > 0.3)
			{
				_comboIndicator.alpha -= 0.005;
			}
			else
			{
				_comboAnimate.stop();
			}
		}
	}
}