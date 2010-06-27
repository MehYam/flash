package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import karnold.utils.FrameTimer;
	import karnold.utils.MathUtil;
	import karnold.utils.Util;

	public class as3 extends Sprite
	{
		private var _tf:TextField = new TextField();
		public function as3()
		{
			FrameTimer.init(stage);

//			testTextField();
			
//			testDistance();
			
//			testAngle();

//			testEnterFrame();

//			testUniquenessOfBoundMethods();

//			testStringErrorThing();
			
//			testSomeShape();
			
			testBitmapDataTransform();
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
		
		private function testSomeShape():void
		{
			addChild(new SomeShape);

			// test comment
			graphics.lineStyle(0, 0xff0000);
			graphics.drawRect(x, y, width, height);
		}

		private function addMarker(x:Number, y:Number):void
		{
			var marker:Shape = new Shape;
			marker.graphics.lineStyle(0);
			marker.graphics.lineTo(5, 5);
			marker.graphics.moveTo(0, 0);
			marker.graphics.lineTo(5, 0);
			marker.graphics.moveTo(0, 0);
			marker.graphics.lineTo(0, 5);
			marker.x = x;
			marker.y = y;
			addChild(marker);
		}
		private var _bitmap:DisplayObject;
		private function testBitmapDataTransform():void
		{
//			stage.scaleMode = StageScaleMode.NO_SCALE;
//			stage.align = StageAlign.TOP_LEFT;
			Util.listen(stage, MouseEvent.CLICK, testBitmapDataTransform_onClick);

			const whole:Number = 100;
			const half:Number = whole/2;

			var sprite:Shape = new Shape;
			sprite.graphics.lineStyle(3, 0xff0000);
			sprite.graphics.beginFill(0x00ff00);
			sprite.graphics.drawEllipse(-half, -half, whole, whole);
			sprite.graphics.drawRect(-half, -half, whole, half);
			sprite.graphics.moveTo(0, 0);
			sprite.graphics.lineTo(0, -half);
			sprite.graphics.endFill();

			const filter:DropShadowFilter = new DropShadowFilter;
			sprite.filters = [filter];

			const rect:Rectangle = sprite.getBounds(sprite);
			trace(rect);

			var bitmapData:BitmapData = new BitmapData(rect.width + filter.distance, rect.height + filter.distance);
			
			var matrix:Matrix = new Matrix;
			matrix.identity();
			matrix.translate(-rect.left, -rect.top);
			bitmapData.draw(sprite, matrix);
			
			var bitmap:Bitmap = new Bitmap(bitmapData);

			matrix.identity();
			matrix.translate(-bitmap.width/2, -bitmap.height/2);
			matrix.rotate(MathUtil.degreesToRadians(45));
//			matrix.translate(bitmap.width/2, bitmap.height/2);
			matrix.translate(stage.stageWidth/2 + whole, stage.stageHeight/2);
			bitmap.transform.matrix = matrix;

//			bitmap.x = stage.stageWidth/2 + whole;
//			bitmap.y = stage.stageHeight/2;

			_bitmap = bitmap;
			addChild(bitmap);

			sprite.x = stage.stageWidth/2 - whole;
			sprite.y = stage.stageHeight/2;
			sprite.rotation = 45;
			addChild(sprite);

			addMarker(0, 0);
			addMarker(bitmap.x, bitmap.y);
			addMarker(sprite.x, sprite.y);
		}
		private function testBitmapDataTransform_onClick(e:Event):void
		{
			_bitmap.x = 350;
		}
	}
}
