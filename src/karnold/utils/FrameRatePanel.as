package karnold.utils
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import karnold.utils.FrameTimer;
	import karnold.utils.NumericRasterTextField;
	
	public class FrameRatePanel extends Sprite
	{
		private var _txtFPS:NumericRasterTextField;
		private var _txtTotalMemory:NumericRasterTextField;
		private var _txtTotalMemoryDelta:NumericRasterTextField;

		private var _btn:SimpleButton;
		
		private static const FIELD_LEFT:Number = 10;
		private static const FIELD_HEIGHT:Number = 15;

		private var _frameTimer:FrameTimer = new FrameTimer(onFrame);
		private var _lastAdded:DisplayObject;
		protected function addField(field:DisplayObject, x:Number):void
		{
			field.x = x;
			field.y = _lastAdded.y;
			addChild(field);
			_lastAdded = field;
		}
		protected function addFieldOnNextLine(field:DisplayObject):void
		{
			field.x = FIELD_LEFT;
			field.y = _lastAdded ? (_lastAdded.y + FIELD_HEIGHT) : 5;
			addChild(field);
			_lastAdded = field;
		}
		public function FrameRatePanel()
		{
			tabEnabled = false;
			tabChildren = false;
		
			_txtFPS = new NumericRasterTextField();		
			_txtFPS.suffix = " fps";
			addFieldOnNextLine(_txtFPS);			
			
			_txtTotalMemory = new NumericRasterTextField();		
			_txtTotalMemory.suffix = " KB";	
			_txtTotalMemory.showThousandsSeparator = true;
			addFieldOnNextLine(_txtTotalMemory);	
						
			_txtTotalMemoryDelta = new NumericRasterTextField();		
			_txtTotalMemoryDelta.suffix = " KB";
			_txtTotalMemoryDelta.showSign = true;	
			_txtTotalMemoryDelta.showThousandsSeparator = true;
			addFieldOnNextLine(_txtTotalMemoryDelta);	
			_txtTotalMemoryDelta.x = 15;

			_btn = addButton(100, 20, 0x777700);
			_btn.addEventListener(MouseEvent.CLICK, onBtnClick);	
		}	

		protected function addButton(x:Number, y:Number, color:uint):SimpleButton
		{
			var box:Sprite = new Sprite();
			box.graphics.beginFill(color);
			box.graphics.drawRect(0,0,20,20);
			box.graphics.endFill();
			
			var box2:Sprite = new Sprite();
			box2.graphics.beginFill(color * 2);
			box2.graphics.drawRect(0,0,20,20);
			box2.graphics.endFill();

			var btn:SimpleButton = new SimpleButton(box,box2,box,box2);
			addChild(btn);
			btn.x = x;
			btn.y = y;
			return btn;
		}
		public function set enabled(b:Boolean):void
		{
			if (b)
			{
				_frameTimer.startPerFrame();
			}
			else
			{
				_frameTimer.stop();
			}
		}
		private function onBtnClick(evt:MouseEvent):void{

			if (evt.shiftKey) {
				// toggle the enterframe
				if (_frameTimer.running)
				{
					_frameTimer.stop();
				}
				else
				{
					_frameTimer.startPerFrame();
				}
			}
			else if (evt.ctrlKey && evt.altKey) {
				Util.stopAllMovieClips(stage);
			}
			else if (evt.ctrlKey) {
			}
			else if (evt.altKey) {
				Util.traceDisplayList(stage);
			}
			else {
				onFrame();

				var fn:Function = System["gc"] as Function;
				if (fn != null) {
					fn();
				}
			}
		}
		
		private var _lastRender:int = 0;
		private var _lastTotalMemoryKB:int = 0;
		private var _frameCount:int = 0;
		private function onFrame():void
		{
			++_frameCount;

			const totalMemoryKB:int = System.totalMemory/1024;
			_txtTotalMemory.integer = totalMemoryKB; 

			const time:int = getTimer();
			const periodRender:Boolean = (time - _lastRender) > 2000;
			if (periodRender)
			{			
				_txtTotalMemoryDelta.integer = totalMemoryKB - _lastTotalMemoryKB;
				_lastTotalMemoryKB = totalMemoryKB;
				
				_txtFPS.integer = _frameCount * 1000 / (time - _lastRender);

				if (!_lastRender)
				{
					graphics.beginFill(0xaaaa00, 0.8);
					graphics.drawRect(0, 0, width + 10, height + 10);
					graphics.endFill();
				}
				_lastRender = time;
				_frameCount = 0;
			}
		}	
	}
}
