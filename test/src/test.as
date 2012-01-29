package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.registerClassAlias;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.describeType;
	
	import karnold.utils.Util;

	[SWF(backgroundColor="#0")]
	public final class test extends Sprite
	{
		public function test()
		{
//			testAddChild();
//			testApply("arg1", "arg2");
//			testArray();
//			testBadgeMockup();
//			testBadgeMockup2();
//			testBlurFilterRasterizationBounds();
//			testBooleanExpressionTrick();
//			testBrowserZoomDetection();
//			teste4x();
//			testEmbeddedFont();
//			testEnumeratingObjectMembers();
//			testException();
//			testExternalInterfaceAndApply();
//			testFilters();
//			testGradientBitmap();
//			testGradientFilter();
//			testHack();
//			testHtmlAnchorTag();
//			testInstances();
//			testMask();
//			testMovieclipDynamicObj();
//			testParsing();
//			testPixelSnapping();
//			testRegularExpressions();
//			testSimpleAnimationPerformance();
//			testStorageObject(false);
//			testStorageObject(true);
//			testTime();
//			testTimer();
//			testTint();
//			testTypeStuff();
//			testVector();
			testCleverOr();
		}
		private function testCleverOr():void
		{
			const foo:Object = {};
			foo[1] = PseudoEnum.ENUM1;
			foo[2] = PseudoEnum.ENUM2;
			
			var pe:PseudoEnum = foo[0] || PseudoEnum.UNDEFINED;
			
			pe = foo[1] || PseudoEnum.UNDEFINED;
		}
		private function testVector():void
		{
			var foo2:Array = [];
			foo2[0] = "foo";
			foo2[5] = "bar";
			
			for each (var i:String in foo2)
			{
				trace(i);
			}

			trace("creating foo");
			var foo:Vector.<String> = new Vector.<String>;
			foo[5] = "bar";			// throws exception
		}
		private function fooFunction(i:int, b:Boolean):void {}
		private function testTypeStuff():void
		{
			trace(new ClassA);
			trace(ClassB);
			
			var foo:Object = fooFunction;
			
			trace((new ClassB)["constructor"]);
			
			foo = new ClassA;
			trace(foo["constructor"]);
		}
		private function testTime():void
		{
			const now:Date = new Date();
			
			trace(now);
			trace(now.time);
			trace(now.toUTCString());
			trace(now.toLocaleString());
		}
		private function testRegularExpressions():void
		{
			// strip out all numeric chars from a string
			trace("this3is0a223-555-111test1234".replace(/[^0-9]/g, ""));
		}
		private function testEnumeratingObjectMembers():void
		{
			var obj:Object = new ClassToEnumerate;
			for(var id:String in obj) {
				var value:Object = obj[id];
				
				trace(id + " = " + value);
			}
			trace(describeType(obj));
		}
		private function testTint():void
		{
			function tintEm(startColor:uint, endColor:uint, y:Number):void
			{
				for (var i:uint = 0; i < 16; ++i)
				{
					var shape:Shape = new Shape;
					shape.graphics.beginFill(Util.tint(startColor, endColor, i/15));
					shape.graphics.drawEllipse(0, 0, 28, 28);
					shape.graphics.endFill();
					
					shape.x = i * (shape.width + 3);
					shape.y = y;
					
					addChild(shape);
				}
			}
			tintEm(0xff0000, 0xffffff, 10);
			tintEm(0xff0000, 0xffff00, 40);
			tintEm(0x00ff00, 0xff00ff, 70);
			tintEm(0x0077ff, 0xff7700, 100);
		}
		static public function rasterize(target:DisplayObject, scale:Number = 1):BitmapData
		{
			const bounds:Rectangle = target.getBounds(target);
			const inflate:int = 10;
			bounds.left -= inflate;
			bounds.top -= inflate;
			bounds.right += inflate;
			bounds.bottom += inflate;
			var bitmapData:BitmapData = new BitmapData(bounds.width * scale, bounds.height * scale, true, 0);
			
			var matrix:Matrix = new Matrix;
			matrix.translate(-bounds.left, -bounds.top);
			matrix.scale(scale, scale);
			bitmapData.draw(target, matrix);
			
			return bitmapData;
		}
		private function outline(obj:DisplayObject, color:uint):void
		{
			const bounds:Rectangle = obj.getBounds(this);
			var shape:Shape = new Shape;
			shape.graphics.lineStyle(0, color);
			shape.graphics.drawRect(0, 0, bounds.width, bounds.height);
			
			shape.x = bounds.left;
			shape.y = bounds.top;
			
			trace("bounds", bounds.width, bounds.height);
			addChild(shape);
		}
		[Embed(source="assets/master.swf", symbol="explosion1")] static private const EXPLOSION1:Class;
		private function testBlurFilterRasterizationBounds():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var dobj:DisplayObject = new EXPLOSION1;
			dobj.x = 100;
			dobj.y = 100;
			outline(dobj, 0x00ff00);
			dobj.filters = [new BlurFilter(25, 25, BitmapFilterQuality.LOW)];
//			outline(dobj, 0xff0000);
			
			addChild(dobj);
			
			dobj = new EXPLOSION1;
			dobj.filters = [new BlurFilter(25, 25, BitmapFilterQuality.LOW)];
			var bmd:BitmapData = rasterize(dobj);
			var bmp:Bitmap = new Bitmap(bmd);
			
			bmp.x = 200;
			bmp.y = 100;
			bmp.smoothing;
//			outline(bmp, 0x00ff00);
			
			addChild(bmp);
		}
		private function testArray():void
		{
			var foo:Array = [3, 1, 2, 5];
			trace(foo[uint(Math.random() * foo.length)]);
		}
		private function testBrowserZoomDetection():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var shape:Shape = new Shape;
			shape.graphics.beginFill(0x440000);
			shape.graphics.drawCircle(0, 0, 200);
			shape.graphics.endFill();
			
			shape.x = 300;
			shape.y = 300;
			addChild(shape);

			var text:TextField = new TextField;
			text.autoSize = TextFieldAutoSize.LEFT;
			text.text = "...";
			addChild(text);
			stage.addEventListener(Event.RESIZE, function(e:Event):void 
			{
				trace("stage:", stage.width, stage.height, "|", stage.stageWidth, stage.stageHeight);
				
				text.text = ["stage:", stage.width, stage.height, "|", stage.stageWidth, stage.stageHeight,
							 "html:", ExternalInterface.call("$('#test').width"), ExternalInterface.call("$('#test').height")].join(" ");
			});
		}
		private function testPixelSnapping():void
		{
			var shape:Shape = new Shape;
			shape.graphics.lineStyle(1, 0xff0000, 1, false);
			shape.graphics.beginFill(0xbb1111);
			shape.graphics.moveTo(0, 0);
			shape.graphics.lineTo(0, 20);
			shape.graphics.lineTo(20, 20);
			shape.graphics.lineTo(30, 10);
			shape.graphics.lineTo(20, 0);
			shape.graphics.lineTo(0, 0);
			shape.graphics.endFill();
			
			var holder:Sprite = new Sprite;
			holder.x = 30;
			holder.y = 30;
			addChild(holder);
			
			var bmp:Bitmap = new Bitmap(new BitmapData(shape.width, shape.height));
			bmp.bitmapData.draw(shape);
			bmp.pixelSnapping = PixelSnapping.NEVER;
			
			var target:DisplayObject = bmp;
			target.addEventListener(Event.ENTER_FRAME, testPixelSnapping_onFrame);
			holder.addChild(target);

			stage.align = StageAlign.TOP_LEFT;
//			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		private function testPixelSnapping_onFrame(e:Event):void
		{
			e.target.x += 0.116;
			e.target.y += 0.06213;
			if (e.target.x > 300)
			{
				e.target.x = 0;
				e.target.y = 0;
			}
		}
		private function testBooleanExpressionTrick():void
		{
			function foo(one:String, two:String):String
			{
				return one || two;
			}
			trace(foo("one", "two"));
			trace(foo(null, "two"));
			trace(foo("one", null));
			trace(foo(null, null));
		}
		private var _child1:Sprite = new Sprite;
		private var _child2:Sprite = new Sprite;
		private function testAddChild():void
		{
			_child1.graphics.beginFill(0xff0000);
			_child1.graphics.drawEllipse(0, 0, 30, 30);
			_child1.graphics.endFill();
			_child2.graphics.beginFill(0xff00);
			_child2.graphics.drawEllipse(0, 0, 30, 30);
			_child2.graphics.endFill();
			
			addChild(_child1);
			_child2.y = 10;
			addChild(_child2);
			
			_child1.addEventListener(MouseEvent.CLICK, function(e:Object):void { addChild(_child1); });
		}
		private function testSimpleAnimationPerformance():void
		{
			function makeShape(x:Number, y:Number):DisplayObject
			{
				var shape:Shape = new Shape;
				shape.graphics.lineStyle(2, Math.random() * 0xffffff);
				shape.graphics.beginFill(Math.random() * 0xffffff);
				shape.graphics.drawEllipse(0, 0, 200, 30);
				shape.graphics.endFill();
				shape.x = x;
				shape.y = y;
				shape.cacheAsBitmap = true;
				return shape;
			}
			addChild(makeShape(10, 20));
			addChild(makeShape(10, 50));
			addChild(makeShape(10, 80));
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 30;
			
			stage.addEventListener(Event.ENTER_FRAME, onSimpleAnimationFrame);
		}
		private function onSimpleAnimationFrame(_unused:Event):void
		{
			const children:uint = numChildren;
			for (var i:uint = 0; i < numChildren; ++i)
			{
				var child:DisplayObject = getChildAt(i);
				
				child.x += Math.random()-0.5;
				child.x = Math.max(0, Math.min(300, child.x));
			}
		}
		private function testHtmlAnchorTag():void
		{
			var textField:TextField = new TextField;
			
			textField.htmlText = "<a href='event:foo'>click here</a> end test";
			textField.addEventListener(TextEvent.LINK, onAnchor);
			
			var shape:Sprite = new Sprite;
			shape.graphics.beginFill(0xff0000);
			shape.graphics.drawCircle(0, 0, 30);
			shape.graphics.endFill();
			shape.x = 100;
			shape.y = 100;

			shape.addEventListener(MouseEvent.CLICK, onAnchor);
			addChild(shape);
			addChild(textField);
		}
		private function onAnchor(e:Event):void
		{
			trace(e);
			var request:URLRequest = new URLRequest("http://www.google.com");
			navigateToURL(request, "_blank");
		}
		private function testParsing():void
		{
			trace(parseInt("ff", 16));

			var foo:Array = "test.png".split(".")[0].split("_");
		}
		private function teste4x():void
		{
			const xml:XML =
				<foo>
					<layer>
						<bar id="1" blah="true" static="true"/>
						<bar id="5" blah="true"/>
						<bar id="-1" blah="false"/>
					</layer>
				</foo>;
			
//			for each (var bar:XML in xml..bar)
			for each (var bar:XML in xml..bar.(@blah == "true" && @id > 1))
			{
				trace(bar.@id.toString());
			}
			var foo:Object = xml..bar.(attribute("static") == "true");
			trace(foo[0].@id);
		}
		private function testStorageObject(write:Boolean):void
		{
			var so:SharedObject = SharedObject.getLocal("kaiTestObject");
			
			if (write)
			{
				registerClassAlias("KaiClass", ObjectWithSettersForSerialization);
				var data:Object =
				{
					fooField: "foo",
					barField: "bar",
					arrayField: [ "this", "is", "an", "array of", { various: "stuff" } ],
					
					object: new ObjectWithSettersForSerialization("one", "two")
				}
				so.data.root = data;
				so.flush();
				
				data.postWrite = "this is here";
			}
			else
			{
				trace(so.data);
			}
		}
		private function testMovieclipDynamicObj():void
		{
			var mc:MovieClip = new MovieClip;
			
			mc.fooBackground = new Sprite;
			mc.barBackground = new Sprite;
			
			mc = new MovieClipSubClass;
			mc.foo = new Sprite;
			mc.bar = new Sprite;
		}
		private function testGradientBitmap():void
		{
			const HEIGHT:Number = 50;
			const themes:Vector.<ThemeSetting> = Vector.<ThemeSetting>([
				new ThemeSetting(0x22608d, 0x90AFC6, 0), 
				new ThemeSetting(0xF5F7F9, 0x8CADC4, 100), 
				new ThemeSetting(0xF9F9F9, 0xDADADA, 0)
			]);
			var i:uint;
			for each (var theme:ThemeSetting in themes)
			{
				var src:Shape = new Shape;
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(1, HEIGHT, 3*Math.PI/2);
				src.graphics.beginGradientFill("linear", theme.colorPair, [100, 100], [theme.ratio, 255], matrix);
				src.graphics.drawRect(0, 0, 1, HEIGHT);
				src.graphics.endFill();
				
				var bmd:BitmapData = new BitmapData(src.width, src.height);
				bmd.draw(src);
				
				var bmp:Bitmap = new Bitmap(bmd);
				bmp.width = 50;
				bmp.y = i;
				
				i += bmp.height + 10;
				addChild(bmp);
			}
		}
		
		[Embed(source="../assets/MyriadPro-Bold.otf", fontFamily="mpro", mimeType="application/x-font", embedAsCFF="false", unicodeRange='U+0020-U+00ff')]
		static private const ANON_PRO_FONT2:Class;
		
		[Embed(source="Anonymous Pro.ttf", fontFamily="embeddedAP", mimeType="application/x-font", embedAsCFF="false")]
		static private const ANON_PRO_FONT:Class;
		[Embed(source='../assets/Boulder.ttf', fontFamily='embeddedBoulder', mimeType='application/x-font', embedAsCFF="false")] 
		private var _as3_doesnt_use1:Class;
		private function testEmbeddedFont():void
		{
			var str:String;
			for (var i:int = 0x20; i < 0xff; ++i)
			{
				str += String.fromCharCode(i);
			}
			const gutter:Number = 10;
			function addTextField(text:String, fontSize:int):void
			{
				var format:TextFormat = new TextFormat();
				format.size = fontSize;
				format.font = "mpro";
				
				var tf:TextField = new TextField();
				tf.embedFonts = true;
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.antiAliasType = AntiAliasType.ADVANCED;
				tf.defaultTextFormat = format;
				tf.selectable = false;
				tf.mouseEnabled = true;
				tf.text = format.font + str;
				if(numChildren > 0) {
					var sibling:DisplayObject = getChildAt(numChildren - 1);
					tf.y = sibling.y + sibling.height + gutter;
				}
				addChild(tf);			
			}
			addTextField("The quick brown fox jumped over the lazy dog.", 8);
			addTextField("The quick brown fox jumped over the lazy dog.", 20);
			addTextField("The quick brown fox jumped over the lazy dog.", 30);
			
			var foo:TextField = newEmbeddedFontTextField(newBoulderTextFormat(10), 0xff0000); 
			foo.text = "foo";
			addChild(foo);
			
			var fonts:Array = Font.enumerateFonts(false);
			
			/* Create a new TextFormat object, and set the font property to the myFont
			object's fontName property. */
			var myFormat:TextFormat = new TextFormat();
			myFormat.font = Font(fonts[0]).fontName;
			myFormat.size = 24;
			
			/* Create a new TextField object, assign the text format using the 
			defaultTextFormat property, and set the embedFonts property to true. */
			var myTextField:TextField = new TextField();
			myTextField.autoSize = TextFieldAutoSize.LEFT;
			myTextField.defaultTextFormat = myFormat;
			myTextField.embedFonts = true;
			myTextField.text = "The quick brown fox jumped over the lazy dog.";
			myTextField.x = 100;
			myTextField.y = 100;
			addChild(myTextField);
		}
		public function newBoulderTextFormat(size:Number):TextFormat
		{
			var retval:TextFormat = new TextFormat; 
			retval.font = "embeddedBoulder";
			retval.size = size;
			return retval;
		}
		public function newEmbeddedFontTextField(fmt:TextFormat, color:uint):TextField
		{
			var tf:TextField = new TextField;
			
			tf.selectable = false;
			tf.embedFonts = true;
			tf.textColor = color;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.defaultTextFormat = fmt;
			return tf; 
		}
		public function newBoulderThinTextFormat(size:Number):TextFormat
		{
			var retval:TextFormat = new TextFormat; 
			retval.font = "embeddedBoulderThin";
			retval.size = size;
			return retval;
		}
		private function testExternalInterfaceAndApply():void
		{
			var array:Array = ["externalInterfaceTest", "foo", "bar"];
			ExternalInterface.call.apply(null, array);
		}
		private function testException():void
		{
			try
			{
				testExceptionInner();
			}
			catch (e:Error)
			{
				trace(e.getStackTrace());
			}
		}
		private function testExceptionInner(foo:Object = null):void
		{
			foo.throwNPE();
		}
		private var testHack_v:PortClimberHack;
		private function testHack():void
		{
			testHack_v = new PortClimberHack;
			testHack_v.start(testHackResult);
		}
		private function testHackResult(e:Event):void
		{
			trace(testHack_v.nextPort);
		}
		private function testApply(...args:Array):void
		{
			args.push("arg3");
			trace.apply(null, args);
		}
		
		private function testMask():void
		{
			var foo:DisplayObject = new MySprite;
			
			var mask:Sprite = new Sprite;
			mask.graphics.beginFill(0);
			mask.graphics.drawRoundRect(0, 0, foo.width, foo.height, 50, 50);
			mask.graphics.endFill();
			foo.mask = mask;
			
			addChild(mask);
			addChild(foo);
		}

		[Embed(source="badge1.png")] static private const BADGE1:Class;
		[Embed(source="badge9.png")] static private const BADGE9:Class;
		[Embed(source="badge16.png")] static private const BADGE16:Class;
		[Embed(source="badge29.png")] static private const BADGE29:Class;
		[Embed(source="badge55.png")] static private const BADGE55:Class;
		
		static private const WIDTH:Number = 28;
		static private const HEIGHT:Number = WIDTH;
		static private const PADDING:Number = 1;
		static private const BORDER:Number = 2;
		
		static private function createBadge():DisplayObject
		{
			var parent:Sprite = new Sprite;
			
			var s_gradientArgs:Object = {};
			s_gradientArgs.box = new Matrix;
			s_gradientArgs.box.createGradientBox(WIDTH, HEIGHT, 45);
			s_gradientArgs.colors = [0x444444, 0x444444];
			s_gradientArgs.alphas = [0, 100];
			s_gradientArgs.strengths = [0, 255];
			
			///////////////////
			parent.graphics.lineStyle(BORDER, 0x444444, 1, true);
			parent.graphics.beginGradientFill(GradientType.LINEAR, s_gradientArgs.colors, s_gradientArgs.alphas, s_gradientArgs.strengths, s_gradientArgs.box);
			parent.graphics.drawRoundRect(BORDER/2, BORDER/2, WIDTH-BORDER, HEIGHT-BORDER, 3, 3);
			parent.graphics.endFill();
			var rect:Rectangle = parent.getBounds(parent); 
			
			var bmp:Bitmap = new BADGE1;
			bmp.smoothing = true;
			bmp.pixelSnapping = PixelSnapping.NEVER;
			bmp.x = PADDING;
			bmp.y = PADDING;
			bmp.scaleX = bmp.scaleY = (parent.width - 2*PADDING) / bmp.width
				
			parent.addChild(bmp);
			return parent;
		}
		private function testBadgeMockup():void
		{
			var foo:DisplayObject = createBadge();
			addChild(foo);
			
			foo = createBadge();
			foo.x = 40;
			foo.y = 40;
			foo.width = 20;
			
			addChild(foo);
			
			foo = createBadge();
			foo.x = 80;
			foo.y = 80;
			foo.height = 23;
			foo.width = 23;
			
			addChild(foo);
		}
		static private const TRIM_AMOUNT:Number = 5;
		static private function createBadge2(badge:Class, maskIt:Boolean = false):DisplayObject
		{
			var parent:Sprite = new Sprite;
			
			var bmp:Bitmap = new badge;
			bmp.smoothing = true;
			bmp.pixelSnapping = PixelSnapping.NEVER;
			bmp.x = PADDING;
			bmp.y = PADDING;

			parent.addChild(bmp);

			if (maskIt)
			{
				var mask:Shape = new Shape;
				mask.graphics.beginFill(0);
				mask.graphics.drawRoundRect(TRIM_AMOUNT + 1, TRIM_AMOUNT + 1, bmp.width - TRIM_AMOUNT*2, bmp.height - TRIM_AMOUNT*2, 8, 8);
				mask.graphics.endFill();
				
				bmp.mask = mask;
				parent.addChild(mask);
			}
			return parent;
		}
		static private var BADGE_FILTER:Array = [];
		private function addTestBadge(badgeImg:Class, x:Number, y:Number, size:Number):void
		{
			var badge:DisplayObject = createBadge2(badgeImg, false);
			badge.x = x;
			badge.y = y;
			badge.width = badge.height = size;
			badge.filters = BADGE_FILTER;
			addChild(badge);

			const scaleTrim:Number = badge.scaleX * TRIM_AMOUNT; 

			badge = createBadge2(badgeImg, true);
			badge.x = x + size + 5;
			badge.y = y - scaleTrim;

			badge.width = badge.height = size + scaleTrim*2;
			badge.filters = BADGE_FILTER;
			addChild(badge);
		}
		private function testBadgeMockup2():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			var horz:Number = 20;
			var vert:Number = 20;
			const badges:Array = [BADGE1, BADGE9, BADGE16, BADGE29, BADGE55];
			BADGE_FILTER = [new DropShadowFilter(2, 45, 0, 0.2, 1, 1)];
			for each (var badge:Class in badges)
			{
				addTestBadge(badge, horz, vert, 45);
				addTestBadge(badge, horz, vert + 60, 28);
				addTestBadge(badge, horz, vert + 120, 23);
				addTestBadge(badge, horz, vert + 180, 17);
				addTestBadge(badge, horz, vert + 240, 14);
				
				horz += 150;
			}
			
			horz = 20;
			vert = 300;
			BADGE_FILTER = [new BevelFilter(3, 45, 0xdddddd, 1, 0xdddddd, 1)];
			for each (badge in badges)
			{
				addTestBadge(badge, horz, vert, 45);
				addTestBadge(badge, horz, vert + 60, 28);
				addTestBadge(badge, horz, vert + 120, 23);
				addTestBadge(badge, horz, vert + 180, 17);
				addTestBadge(badge, horz, vert + 240, 14);
				
				horz += 150;
			}
		}
		
		private function testInstances():void
		{
			for (var i:uint = 0; i < 1000; ++i) {
				trace("this", "is", "a", "test"); 
				trace("this " + "is " + "a " + "test"); 
			}
		}
		
		private function testFilters():void
		{
			var shape:Shape = new Shape;
			shape.graphics.beginFill(0xff0000);
			shape.graphics.drawEllipse(0, 0, 50, 60);
			shape.graphics.drawRect(0, 0, 25, 25);
			shape.graphics.endFill();
			
			var bmd:BitmapData = new BitmapData(shape.width, shape.height, true, 0);
			bmd.draw(shape);
			var bmp:Bitmap = new Bitmap(bmd);
			
			bmp.smoothing = true;
			bmp.filters = [new DropShadowFilter];
			addChild(bmp);
		}
		private function testGradientFilter():void
		{
			const bgColor:uint = 0xCCCCCC;
			const size:uint    = 80;
			const offset:uint  = 50;
			
			const distance:Number  = 0;
			const angleInDegrees:Number = 45;
			const colors:Array     = [0xFFFFFF, 0xFF0000, 0xFFFF00, 0x00CCFF];
			const alphas:Array     = [0, 1, 1, 1];
			const ratios:Array     = [0, 63, 126, 255];
			const blurX:Number     = 50;
			const blurY:Number     = 50;
			const strength:Number  = 2.5;
			const quality:Number   = BitmapFilterQuality.HIGH;
			const type:String      = BitmapFilterType.OUTER;
			const knockout:Boolean = false;

			graphics.beginFill(bgColor);
			graphics.drawRect(offset, offset, size, size);
			graphics.endFill();

			filters = [
			new GradientGlowFilter(distance,
				angleInDegrees,
				colors,
				alphas,
				ratios,
				blurX,
				blurY,
				strength,
				quality,
				type,
				knockout)
			];
		}
		private var _testTimer:Timer;
		private function testTimer():void
		{
			_testTimer = new Timer(1, 1);
			_testTimer.addEventListener(TimerEvent.TIMER, testTimer_onTimer);
			_testTimer.start();
		}
		private function testTimer_onTimer(e:Event):void
		{
			if (_testTimer.currentCount < 10)
			{
				++_testTimer.repeatCount;
				_testTimer.start();
				trace("timer", _testTimer.currentCount);
			}
		}
	}
}
import flash.display.MovieClip;
import flash.events.TimerEvent;
import flash.utils.Timer;

internal final class FOO {}
internal final class BAR {}
internal final class BLARF {}


final internal class PortClimberHack 
{
	private const _timer:Timer = new Timer(10);
	private const _port:uint = 5015;
	private var   _increment:uint = 0;
	private var   _max:uint = 1;
	
	public function start(fn:Function):void
	{
		_timer.addEventListener(TimerEvent.TIMER, fn, false, 0, true);
		_timer.start();
	}
	public function stop():void
	{
		_timer.stop();
		_increment = 0;
		_max = 1;
	}
	public function get nextPort():uint
	{
		const port:uint = _port + _increment++;
		if (_increment > _max)
		{
			++_max;
			_increment = 0;
			if (_max > 5)
			{
				_timer.stop();
			}
		}
		return port;
	}
}

final class ThemeSetting
{
	public var colorPair:Array;
	public var ratio:uint; // 0-256
	public function ThemeSetting(colorTop:uint, colorBottom:uint, ratio:uint):void
	{
		this.colorPair = [colorTop, colorBottom];
		this.ratio = ratio;
	}
}

final dynamic class MovieClipSubClass extends MovieClip
{
	
}

class ObjectWithSettersForSerialization
{
	private var _foo:String;
	private var _bar:String;
	
	public function ObjectWithSettersForSerialization(foo:String = "", bar:String = ""):void
	{
		_foo = foo;
		_bar = bar;
	}
}

final class ClassToEnumerate
{
	public var field1:String = "foo";
	public var field2:uint = 0;
	public var field3:Number = 5;
	public var field4:String = "bar";
}

final class ClassA {}
final class ClassB {}


final class PseudoEnum
{
	static public const UNDEFINED:PseudoEnum = new PseudoEnum(-1);
	static public const ENUM1:PseudoEnum = new PseudoEnum(1);
	static public const ENUM2:PseudoEnum = new PseudoEnum(2);
	
	public var val:int;
	public function PseudoEnum(v:int):void { this.val = v; }
}