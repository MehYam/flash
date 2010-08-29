package ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import gameData.PlayedLevelStats;
	
	import karnold.ui.ShadowTextField;
	import karnold.utils.MathUtil;
	import karnold.utils.Util;

	public class LevelCompleteDialog extends GameDialog
	{
		public function LevelCompleteDialog(stats:PlayedLevelStats, level:uint)
		{
			super();
			
			title = "STATS - Level " + (level+1);
			
			addFields(stats);
			addBottomStuff();

			render();
		}
		
		private function addFields(stats:PlayedLevelStats):void
		{
			const pct:Number = 100 * stats.enemiesKilledCleanly / stats.enemiesTotal;
			addField("Clean Kills", stats.enemiesKilledCleanly + "/" + stats.enemiesTotal + "(" + MathUtil.round(pct, 2) + "%)");
			addField("Credits Earned", String(stats.creditsEarned), Consts.CREDIT_FIELD_COLOR);
			addField("Max Combo", String(stats.maxCombo));
			
			const seconds:Number = stats.elapsed/1000;
			addField("Time", uint(seconds / 60) + ":" + Math.round(seconds % 60));
			addField("Damage per second", String(MathUtil.round(stats.damageDealt / seconds, 2)));
			addField("DPS received", String(MathUtil.round(stats.damageReceived / seconds, 2)));
		}
		private var _lastFieldBottom:Number = TOP_MARGIN;
		private function addField(label:String, value:String, valueColor:uint = 0xffffff):void
		{
			var tf:TextFormat = new TextFormat("Computerfont", 24);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0xffffff, 0x444444, 1);
			labelField.text = label + ":";
			labelField.x = 20;
			labelField.y = _lastFieldBottom;

			var valueField:ShadowTextField = new ShadowTextField(new TextFormat("SF Transrobotics", 24), 0x555577, valueColor, 1);
			
			valueField.y = labelField.y - 2;
			valueField.x = 250 - valueField.width;
			valueField.text = value;
			
			addChild(labelField);
			addChild(valueField);

			_lastFieldBottom = labelField.y + labelField.height;
		}
		
		private function addBottomStuff():void
		{
			var continueButton:GameButton = GameButton.create("Next", true, 24, 1);
			
			Util.centerChild(continueButton, this);
			continueButton.y = _lastFieldBottom + 20;
			
			addChild(continueButton);
			
			Util.listen(continueButton, MouseEvent.CLICK, onNext);
		}
		
		private function onNext(e:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}