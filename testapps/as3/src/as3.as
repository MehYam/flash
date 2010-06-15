package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	public class as3 extends Sprite
	{
		private var _tf:TextField = new TextField();
		public function as3()
		{

//			testTextField();
			
//			testDistance();
			
//			testAngle();

//			testEnterFrame();

//			testUniquenessOfBoundMethods();

			testStringErrorThing();
		}
	
		private function testTextField():void
		{
			var fmt:TextFormat = new TextFormat();
			fmt.color = 0xff0000;
			
			_tf = new TextField();
//			_tf.defaultTextFormat = fmt;
			
			//tf.htmlText = "Hey man <a href='event:foo'> check this out</a>";
			_tf.text = "this is a test";
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.x = 20;
			_tf.y = 20;
			_tf.textColor = 0xff0000;
			
			//tf.addEventListener(TextEvent.LINK, onLink, false, 0, true);
			stage.addEventListener(MouseEvent.CLICK, onLink, false, 0, true);
			this.addChild(_tf);
		}	
		private function onLink(e:MouseEvent):void
		{
			trace("got event " + e);

			var fmt:TextFormat = new TextFormat();
			fmt.color = 0xff;
//			_tf.text = "foo";
			_tf.textColor = 0xff;
//			_tf.defaultTextFormat = fmt;
		}
		
		public static function distanceBetweenPoints(point1:Point, point2:Point):Number {
			var x:Number = point2.x - point1.x;
			x *= x;
			
			var y:Number = point2.y - point1.y;
			y *= y;

			return Math.sqrt(x + y);
		}

		private function testDistance():void
		{
			var pt1:Point = new Point(100, 200);
			var pt2:Point = new Point(33, 66);
			
			var t:int = getTimer();
			
			t = getTimer(); 
			for (var j:int = 0; j < 1000000; ++j)
			{
				num = as3.distanceBetweenPoints(pt1, pt2);
			}
			trace("time: " + (getTimer() - t));
			for (var i:int = 0; i < 1000000; ++i)
			{
				var num:Number = Point.distance(pt1, pt2);
			}
			trace("time: " + (getTimer() - t));
			
		}
		
		static private const s_PIConvert:Number = 180/Math.PI 
		private function testAngle():void
		{
			var xExceeds:Number;
			var yExceeds:Number;
			
			
			xExceeds = -10;
			yExceeds = -10;
			
			var radAngle:Number = Math.atan2(yExceeds, xExceeds);
			
			trace("angle: " + ((radAngle*s_PIConvert) + 90));
		}
		
		private function testEnterFrame():void
		{
			var child:Test = new Test(stage);
			addChild(child);

			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame2);
			stage.frameRate = 4;
		}

		private var _stranded:Object;
		private function testEnterFrameStrandedChild():void
		{
			var child:Test = new Test(stage);
			_stranded = child;

			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame2);
			stage.frameRate = 4;
		}

		private function onEnterFrame(e:Event):void
		{
		}
		private function onEnterFrame2(e:Event):void
		{
		}
		
		private function testUniquenessOfBoundMethods():void
		{
			var button:Sprite = new Sprite;
			button.graphics.lineStyle(3, 0xffff00);
			button.graphics.beginFill(0x0000ff);
			button.graphics.drawRect(0, 0, 150, 100);
			
			this.addChild(button);
			
			button.addEventListener(MouseEvent.CLICK, onTestButton, false, 0, true);
		}
		
		private var _boundMethods:Array = [];
		private function onTestButton(e:Event):void
		{
//			_boundMethods.push(this.onTestButton);
			trace(this.onTestButton);
		}
		
		private function testStringErrorThing():void
		{
			var obj:Object = "This is a string";

			obj = { error: "foo" };

// this causes a runtime error w/o the top line first
//			trace(obj.error);

			trace(obj.hasOwnProperty("error"));
		}
	}
}
