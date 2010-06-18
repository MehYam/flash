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

		private var _txtWrites:NumericRasterTextField;
		private var _txtBytesWritten:NumericRasterTextField;
		private var _txtReads:NumericRasterTextField;
		private var _txtBytesRead:NumericRasterTextField;

		private var _txtMX:NumericRasterTextField;
		private var _txtMY:NumericRasterTextField;
		private var _txtRoom:TextField;
		private var _txtServerVer:TextField;
		private var _txtClientVer:TextField;		
		
		private var _btn:SimpleButton;
		
		public var _mx:Number = 0;
		public var _my:Number = 0;		
		
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

			_txtMX = new NumericRasterTextField();		
			_txtMX.x = FIELD_LEFT;
			_txtMX.y = currentY;
			_txtMX.suffix = "x";	
			addChild(_txtMX);	
			
			_txtMY = new NumericRasterTextField();		
			_txtMY.x = 55;
			_txtMY.y = currentY;
			_txtMY.suffix = "y";
			addChild(_txtMY);	
			
			currentY += FIELD_HEIGHT;

			_txtRoom = new TextField();
			_txtRoom.embedFonts = true;
			_txtRoom.autoSize = TextFieldAutoSize.LEFT;
			_txtRoom.defaultTextFormat = format;			
			_txtRoom.x = FIELD_LEFT;
			_txtRoom.y = currentY;	
			addChild(_txtRoom);			
			
			currentY += FIELD_HEIGHT;
			
			_txtServerVer = new TextField();
			_txtServerVer.embedFonts = true;
			_txtServerVer.autoSize = TextFieldAutoSize.LEFT;
			_txtServerVer.defaultTextFormat = format;
			_txtServerVer.x = FIELD_LEFT;
			_txtServerVer.y = currentY;			
			addChild(_txtServerVer);

			currentY += FIELD_HEIGHT;

			_txtClientVer = new TextField();
			_txtClientVer.embedFonts = true;
			_txtClientVer.autoSize = TextFieldAutoSize.LEFT;
			_txtClientVer.defaultTextFormat = format;
			_txtClientVer.x = FIELD_LEFT;
			_txtClientVer.y = currentY;			
			addChild(_txtClientVer);
			
			var box:Sprite = new Sprite();
			box.graphics.beginFill(0x00FFFF);
			box.graphics.drawRect(0,0,30,18);
			box.graphics.endFill();
			
			var box2:Sprite = new Sprite();
			box2.graphics.beginFill(0xFF0000);
			box2.graphics.drawRect(0,0,30,18);
			box2.graphics.endFill();
			
			_btn = new SimpleButton(box,box,box2,box2);
			addChild(_btn);
			_btn.addEventListener(MouseEvent.CLICK, onBtnClick);	
			_btn.y = 20;
			_btn.x = 100;

			graphics.beginFill(0, 0.8);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
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
			_txtMX.integer = _mx;			
			_txtMY.integer = _my;

			const time:int = getTimer();
			const periodRender:Boolean = (time - _lastRender) > 2000;
			if (periodRender)
			{			
				_txtTotalMemoryDelta.integer = totalMemoryKB - _lastTotalMemoryKB;
				_lastTotalMemoryKB = totalMemoryKB;
				
				_txtFPS.integer = _frameCount * 1000 / (time - _lastRender);

				_lastRender = time;
				_frameCount = 0;
			}
		}	
	}
}
