package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import karnold.ui.ShadowTextField;
	
	//KAI: this and gamebutton could be moved to karnold.ui
	public class GameDialog extends Sprite
	{
		private var _background:DisplayObject;
		private var _inner:DisplayObject;

		static private const s_titleHeight:Number = 25;
		static private const s_innerMarginTopLeft:Point = new Point(5, 5);
		static private const s_innerMarginBottomRight:Point = new Point(7, 7);
		static private const s_titleOffset:Point = new Point(3, 2);
		
		static protected const TOP_MARGIN:Number = s_titleHeight + 15;

		public function GameDialog(inner:Boolean = true)
		{
			super();

			_background = AssetManager.instance.buttonFace();
			addChild(_background);
			
			if (inner)
			{
				_inner = AssetManager.instance.innerFace();
				addChild(_inner);
			}
		}

		protected function render():void
		{
			// LAAAAAAAAAAAAAAAAME
			width = width + 20;
			height = height + 20;
		}
		public function layoutSkins():void
		{
			if (_inner && _background)
			{
				_inner.x = s_innerMarginTopLeft.x;
				_inner.y = s_innerMarginTopLeft.y + s_titleHeight;
				
				_inner.width = _background.width - _inner.x - s_innerMarginBottomRight.x;
				_inner.height = _background.height - _inner.y - s_innerMarginBottomRight.y;
			}
		}
		
		override public function set width(w:Number):void
		{
			_background.width = w;
			layoutSkins();
		}
		override public function set height(h:Number):void
		{
			_background.height = h;
			layoutSkins();
		}
		
		private var _title:DisplayObject;
		public function set title(t:String):void
		{
			if (_title)
			{
				removeChild(_title);
			}
			var tf:ShadowTextField = new ShadowTextField;
			AssetManager.instance.assignFont(tf, AssetManager.FONT_ROBOT, 20);
			tf.text = t;
			tf.x = s_titleOffset.x;
			tf.y = s_titleOffset.y;
			addChild(tf);
			
			_title = tf;
		}
		protected function set enabled(b:Boolean):void
		{
			mouseEnabled = b;
			mouseChildren = b;
		}
	}
}