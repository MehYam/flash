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
		private var _progress:ProgressMeter;
		private var _earnings:ShadowTextField;
		private var _comboIndicator:ShadowTextField;
		private var _fusionIndicator:LabelAndMeter;
		private var _shieldIndicator:LabelAndMeter;
		public function ScoreBoard()
		{
			super();
			
			mouseEnabled = false;
			mouseChildren = false;

			const radioStars24:TextFormat = AssetManager.instance.createFont(AssetManager.FONT_RADIOSTARS, 24);
			
			var labelField:ShadowTextField = new ShadowTextField;
			AssetManager.instance.assignTextFormat(labelField, radioStars24);
			labelField.text = "Health:";
			labelField.cacheAsBitmap = true;
			addChild(labelField);

			_health = new ProgressMeter(120, 18, 0, 0xff0000);
			_health.pct = .30;
			_health.x = labelField.x + labelField.width + GAP/2;
			_health.y = labelField.y + GAP/2 + 1;
			addChild(_health);

			var horz:Number = _health.x + _health.width + GAP;

			labelField = new ShadowTextField;
			AssetManager.instance.assignTextFormat(labelField, radioStars24);
			labelField.text = "Earnings:";
			labelField.cacheAsBitmap = true;
			labelField.x = horz;
			addChild(labelField);
			
			const robot26:TextFormat = AssetManager.instance.createFont(AssetManager.FONT_ROBOT, 26);
			
			_earnings = new ShadowTextField;
			AssetManager.instance.assignTextFormat(_earnings, robot26);
			_earnings.text = "0";
			_earnings.x = labelField.x + labelField.width + GAP/2;
			_earnings.y = -4;
			addChild(_earnings);

			var vert:Number = labelField.y + labelField.height - 6;

			labelField = new ShadowTextField;
			AssetManager.instance.assignTextFormat(labelField, radioStars24);
			labelField.text = "Level:";
			labelField.x = 0;
			labelField.y = vert;
			labelField.cacheAsBitmap = true;
			addChild(labelField);
			
			_progress = new ProgressMeter(120, 18, 0, 0x0033ff);
			_progress.pct = .5;
			_progress.x = _health.x;
			_progress.y = labelField.y + GAP/2 + 1;
			addChild(_progress);

			const indicatorTextFormat:TextFormat = AssetManager.instance.createFont(AssetManager.FONT_ROBOT, 20);
			_comboIndicator = new ShadowTextField;
			AssetManager.instance.assignTextFormat(_comboIndicator, indicatorTextFormat);
			_comboIndicator.x = _earnings.x -100;
			_comboIndicator.y = _earnings.y + _earnings.height - 9;
			combo = 1;
			addChild(_comboIndicator);

			vert = labelField.y + labelField.height;
			labelField = new ShadowTextField;
			AssetManager.instance.assignTextFormat(labelField, indicatorTextFormat);
			labelField.text = "FUSION:";
			labelField.fgColor = 0xff00ff;
			var meter:ProgressMeter = new ProgressMeter(80, 10, 0, 0xff00ff);
			_fusionIndicator = new LabelAndMeter(labelField, meter);
			_fusionIndicator.y = vert;

			labelField = new ShadowTextField;
			AssetManager.instance.assignTextFormat(labelField, indicatorTextFormat);
			labelField.text = "SHIELD:";
			labelField.fgColor = 0x0000ff;
			meter = new ProgressMeter(80, 10, 0, 0x0000ff);
			_shieldIndicator = new LabelAndMeter(labelField, meter);
			_shieldIndicator.y = _fusionIndicator.y;
			
			_fusionIndicator.pct = .01;
			_shieldIndicator.pct = 1; //lame
		}
		
		public function set showFusion(b:Boolean):void
		{
			if (!b && _fusionIndicator.parent)
			{
				_fusionIndicator.parent.removeChild(_fusionIndicator);
				_fusionIndicator.x = 0;
			}
			else if (b && !_fusionIndicator.parent)
			{
				if (_shieldIndicator.parent)
				{
					_fusionIndicator.x = _shieldIndicator.width + 5;
				}
				addChild(_fusionIndicator);
			}
		}
		public function set showShield(b:Boolean):void
		{
			if (!b && _shieldIndicator.parent)
			{
				_shieldIndicator.parent.removeChild(_shieldIndicator);
				_shieldIndicator.x = 0;
			}
			else if (b && !_shieldIndicator.parent)
			{
				if (_fusionIndicator.parent)
				{
					_shieldIndicator.x = _fusionIndicator.width + 5;
				}
				addChild(_shieldIndicator);
				pctShield = 1;
			}
		}
		public function set pctFusion(p:Number):void
		{
			_fusionIndicator.pct = p;
		}
		public function set pctShield(p:Number):void
		{
			_shieldIndicator.pct = p;
		}
		public function set pctLevel(p:Number):void
		{
			_progress.pct = p;
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
import flash.display.DisplayObject;
import flash.display.Sprite;

import karnold.ui.ProgressMeter;

final internal class LabelAndMeter extends Sprite
{
	private var _label:DisplayObject;
	private var _meter:ProgressMeter;
	
	public function LabelAndMeter(label:DisplayObject, meter:ProgressMeter)
	{
		super();
		_label = label;
		_meter = meter;
		_meter.x = _label.x + _label.width + 5;
		_meter.y = _label.y + (_label.height - _meter.height)/2;
		
		addChild(_label);
		addChild(_meter);
	}
	public function set pct(p:Number):void
	{
		_meter.pct = p;
	}
}