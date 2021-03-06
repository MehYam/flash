package {
	import flash.display.Sprite;

	public class SecondLayer extends Sprite
	{
		public function SecondLayer()
		{

			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;

			test1();

//			test2BuildTree(this, this.stage.stageWidth, this.stage.stageHeight, 2, 2, 5);
			trace("created " + created);

			this.graphics.lineStyle(0, 0xffffff);
			this.graphics.beginFill(0xff00ff);
			this.graphics.drawRect(0, 0, 100, 100);
			this.graphics.endFill();

			addEventListener(MouseEvent.MOUSE_DOWN, onClick);
		}

		
		private function test1():void
		{
			const enable:Boolean = false;
			
			var elm:TestElement = new TestElement();
			elm.init(200, 200, Math.random() * 0xffffff);
			elm.x = 20;
			elm.y = 20;
			elm.mouseEnabled = enable;
			
			addChild(elm);

			var elm2:TestElement = new TestElement();			
			elm2.init(190, 190, Math.random() * 0xffffff);
			elm2.x = 5;
			elm2.y = 5;
			elm2.mouseEnabled = enable;
			elm.addChild(elm2);
			
			var elm3:TestElement = new TestElement();			
			elm3.init(180, 180, Math.random() * 0xffffff);
			elm3.x = 5;
			elm3.y = 5;
			elm3.mouseEnabled = enable;
			elm2.addChild(elm3);
		}
		private function onClick(e:Event):void
		{
			trace("onClick: " + e);
		}
		
		private static var MARGIN:Number = 5;
		private static var created:int = 0;
		private static function test2BuildTree(parent:DisplayObjectContainer, width:Number, height:Number, rows:int, cols:int, levels:int):void
		{
			if (levels > 0)
			{
				const elmWidth:Number = (width - MARGIN*2) / rows;
				const elmHeight:Number = (height - MARGIN*2) / cols;
				for (var r:int = 0; r < rows; ++r)
				{
					var elmY:Number = MARGIN + r*elmHeight;
					for (var c:int = 0; c < cols; ++c)
					{
						var elmX:Number = MARGIN + c*elmWidth;
						
						var elm:TestElement = new TestElement();
						elm.init(elmWidth, elmHeight, Math.random() * 0xffffff);
						elm.x = elmX;
						elm.y = elmY;
						elm.mouseEnabled = false;
						
						parent.addChild(elm);
						++created;
						
						test2BuildTree(elm, elm.width, elm.height, rows, cols, levels - 1);
					}
				}
			}
		}
	}
}
