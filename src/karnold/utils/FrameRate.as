package karnold.utils
{
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
	
	public class FrameRate extends Sprite
	{
		private var _txtFPS:NumericRasterTextField;
		private var _txtTotalMemory:NumericRasterTextField;
		private var _txtTotalMemoryDelta:NumericRasterTextField;

		private var _txt1:NumericRasterTextField;
		private var _txt2:NumericRasterTextField;
		private var _txt3:NumericRasterTextField;
		
		private var _btn:SimpleButton;
		
		private static const FIELD_LEFT:Number = 10;
		private static const FIELD_HEIGHT:Number = 15;

		private var _frameTimer:FrameTimer = new FrameTimer(onFrame);

		//
		// Pass in null for SocketStats to turn off its display
		public function FrameRate()
		{
			tabEnabled = false;
			tabChildren = false;
			
			var format:TextFormat = new TextFormat();
		    format.font = "_myArial";
		    format.size = 12;
		    format.color = 0xFFFFFF;
	
			var currentY:Number = 5;
			_txtFPS = new NumericRasterTextField();		
			_txtFPS.x = FIELD_LEFT;
			_txtFPS.y = currentY;
			_txtFPS.suffix = " fps";
			addChild(_txtFPS);			
			
			currentY += FIELD_HEIGHT;

			_txtTotalMemory = new NumericRasterTextField();		
			_txtTotalMemory.x = FIELD_LEFT;
			_txtTotalMemory.y = currentY;
			_txtTotalMemory.suffix = " KB";	
			_txtTotalMemory.showThousandsSeparator = true;
			addChild(_txtTotalMemory);	
						
			currentY += FIELD_HEIGHT;

			_txtTotalMemoryDelta = new NumericRasterTextField();		
			_txtTotalMemoryDelta.x = 15;
			_txtTotalMemoryDelta.y = currentY;
			_txtTotalMemoryDelta.suffix = " KB";
			_txtTotalMemoryDelta.showSign = true;	
			_txtTotalMemoryDelta.showThousandsSeparator = true;
			addChild(_txtTotalMemoryDelta);	

			currentY += FIELD_HEIGHT;

			_txt1 = new NumericRasterTextField();		
			_txt1.x = FIELD_LEFT;
			_txt1.y = currentY;
			addChild(_txt1);	
			
			_txt2 = new NumericRasterTextField();		
			_txt2.x = 55;
			_txt2.y = currentY;
			addChild(_txt2);	
			
			currentY += FIELD_HEIGHT;

			_txt3 = new NumericRasterTextField();
			_txt3.x = FIELD_LEFT;
			_txt3.y = currentY;
			_txt3.suffix = " cast";
			addChild(_txt3);
			
			currentY += FIELD_HEIGHT;

			var box:Sprite = new Sprite();
			box.graphics.beginFill(0xff0000);
			box.graphics.drawRect(0,0,20,20);
			box.graphics.endFill();
			
			var box2:Sprite = new Sprite();
			box2.graphics.beginFill(0xffff00);
			box2.graphics.drawRect(0,0,20,20);
			box2.graphics.endFill();
			
			_btn = new SimpleButton(box,box,box2,box2);
			addChild(_btn);
			_btn.addEventListener(MouseEvent.CLICK, onBtnClick);	
			_btn.y = 20;
			_btn.x = 100;
		}	

		public function set txt1(i:int):void
		{
			_txt1.integer = i;
		}
		public function set txt2(i:int):void
		{
			_txt2.integer = i;
		}
		public function set txt3(i:int):void
		{
			_txt3.integer = i;
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
			}
			else if (evt.ctrlKey) {
//				DisplayObjectUtils.stopAllMovieClips(stage);
			}
			else if (evt.altKey) {
				Utils.traceDisplayList(stage);
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
					graphics.beginFill(0, 0.8);
					graphics.drawRect(0, 0, width + 10, height + 10);
					graphics.endFill();
				}
				_lastRender = time;
				_frameCount = 0;
			}
		}	
	}
}
