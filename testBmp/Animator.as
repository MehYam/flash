package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class Animator extends Bitmap
	{
		private var _node:XML;
		private var _img:BitmapData;
		public function Animator(img:BitmapData, node:XML)
		{
			super();

			this._img = img;
			this.node = node;			
		}

		private var _frames:uint = 0;
		private var _cache:CachedStuff = new CachedStuff;
		private var _bFlipped:Boolean;
		private var _frameLength:uint = 0;
		public function set node(newNode:XML):void
		{
			_bFlipped = isFlipped(newNode);

			const source:String = newNode.@copy;
			if (source)
			{
				const parent:* = newNode.parent();
				const tiles:XMLList = parent.tile;
				const whatever:* = tiles.(@name == source);

				_node = newNode.parent().tile.(@name == source)[0];
			}
			else
			{
				_node = newNode;
			}
			_frames = _node.children().length();

			_cache.rect.width = newNode.parent().@defaultWidth;
			_cache.rect.height = newNode.parent().@defaultHeight;

			const strFrameLength:String = _node.@frameLength;
			if (strFrameLength != "")
			{
				_frameLength = _node.@frameLength;
			}
			else
			{
			   _frameLength = _node.parent().@defaultFrameLength; 	
			}
			
			this.bitmapData = new BitmapData(_cache.rect.width, _cache.rect.height);

			draw();			
		}
		private function isFlipped(node:XML):Boolean
		{
			return node.@flip == "horz";
		}
		private var _frame:uint = 0;
		public function onFrame(frame:uint):void
		{
			if (_frames > 1)
			{
				if ((frame % _frameLength) == 0)
				{
					++_frame;
					draw();
				}
			}
		}

		private function draw():void
		{
			var xmlFrame:XML = _node.children()[_frame % _frames]; 

			const localFlip:Boolean = isFlipped(xmlFrame) ? !_bFlipped : _bFlipped;   //xor..,. 
			
			const source:String = xmlFrame.@copy;
			if (source)
			{
				xmlFrame = xmlFrame.parent().frame.(@name == source)[0];
			}
			_cache.rect.x = xmlFrame.@x;
			_cache.rect.y = xmlFrame.@y;
			
			if (localFlip)
			{
				this.bitmapData.copyPixels(_img, _cache.rectAlphaTile, _cache.origin);

				_cache.matrixFlip.identity();
				_cache.matrixFlip.scale(-1, 1);
				_cache.matrixFlip.translate(_cache.rect.x + _cache.rect.width, -_cache.rect.y);
				this.bitmapData.draw(_img, _cache.matrixFlip); 
			}
			else
			{
				this.bitmapData.copyPixels(_img, _cache.rect, _cache.origin);
			}
		}
	}
}

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
internal class CachedStuff
{
	public var rect:Rectangle = new Rectangle();
	public var origin:Point = new Point();

	public var rectAlphaTile:Rectangle = new Rectangle(224, 64, 32, 32); // KAI: soft-code

	public var matrixFlip:Matrix = new Matrix; 	
};

