package karnold.spark
{
	import mx.core.ILayoutElement;
	
	import spark.components.gridClasses.GridLayout;
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class FlowLayout extends LayoutBase
	{
		private function invalidateLayout():void
		{
			var layoutTarget:GroupBase = target;
			if (layoutTarget)
			{
				layoutTarget.invalidateSize();
				layoutTarget.invalidateDisplayList();
			}
		}
		private var _horizontalGap:Number = 4;
		public function set horizontalGap(value:Number):void
		{
			if (_horizontalGap != value)
			{
				_horizontalGap = value;
				invalidateLayout();
			}
		}
		private var _verticalGap:Number = 4;
		public function set verticalGap(value:Number):void
		{
			if (_verticalGap != value)
			{
				_verticalGap = value;
				invalidateLayout();
			}
		}
		// KAI: before publishing this, add all that inspector jazz like how TileLayout does
		private var _justify:Boolean = false;
		/**
		 * Grows the child items so that they fit the parent container perfectly.  This will override the item widths,
		 * so it's not useful for cases where you want items to flow with variable widths. 
		 * @param j
		 * 
		 */
		public function set justify(j:Boolean):void
		{
			if (_justify != j)
			{
				_justify = j;
				invalidateLayout();
			}
		}
		/**
		 * Adjusts the width of an item - this assumes all the items are the same size 
		 * @param targetWidth
		 * @return 
		 * 
		 */
		private function getLayoutJustifiedWidth(targetWidth:Number):Number
		{
			if (target.numElements)
			{
				const elementWidth:Number = target.getElementAt(0).getPreferredBoundsWidth();
				const numCanFit:uint = Math.max(targetWidth / (elementWidth + _horizontalGap), 1);
				const remainder:Number = targetWidth - (elementWidth * numCanFit) - (_horizontalGap * (numCanFit - 1));
				
				return elementWidth + (remainder / numCanFit);
			}
			return NaN;
		}
		private function doLayout(layout:GridLayout, targetWidth:Number, updatingDisplayList:Boolean = false):void
		{
			layout.reset();

			var layoutTarget:GroupBase = target;
			var currentRowHeight:Number = 0;
			const justifiedWidth:Number = (updatingDisplayList && _justify) ? getLayoutJustifiedWidth(targetWidth) : NaN;

			const count:int = layoutTarget.numElements;
			for (var i:int = 0; i < count; ++i)
			{
				// not sure virtual layout works, haven't tested it
				var element:ILayoutElement = useVirtualLayout ?	layoutTarget.getVirtualElementAt(i) : layoutTarget.getElementAt(i);
				
				// In virtualization scenarios, the element returned could still be null. Look at the typical element instead.
				if (!element)
				{
					element = typicalLayoutElement;
				}
				if (updatingDisplayList)
				{
					// Resize the element to its preferred size
					element.setLayoutBoundsSize(NaN, NaN);
				}
				
				// Find the preferred sizes    
				const elementWidth:Number = !isNaN(justifiedWidth) ? justifiedWidth :   
					(updatingDisplayList ? element.getLayoutBoundsWidth() : element.getPreferredBoundsWidth());
				const elementHeight:Number = updatingDisplayList ? element.getLayoutBoundsHeight() : element.getPreferredBoundsHeight();

				currentRowHeight = Math.max(currentRowHeight, elementHeight);
				if (layout.x > 0 && (int(layout.x + elementWidth) > target.width))
				{
					// row has exceeded width, wrap to a new one
					layout.x = 0;
					layout.y += currentRowHeight + _verticalGap;

					currentRowHeight = elementHeight;
				}
				// add item to row
				if (updatingDisplayList)
				{
					if (!isNaN(justifiedWidth))
					{
						element.setLayoutBoundsSize(justifiedWidth, elementHeight);
					}
					element.setLayoutBoundsPosition(layout.x, layout.y);
				}
				layout.width = Math.max(layout.width, layout.x + elementWidth);
				layout.x += elementWidth + _horizontalGap;
			}
			layout.height = layout.y + currentRowHeight;
		}
		private var _measuredLayout:GridLayout = new GridLayout;
		override public function measure():void
		{
			doLayout(_measuredLayout, target.width);
			target.measuredWidth = _measuredLayout.width;
			target.measuredHeight = _measuredLayout.height;
		}
		
		override public function updateDisplayList(containerWidth:Number,
												   containerHeight:Number):void
		{
			var layout:GridLayout = new GridLayout;
			doLayout(layout, containerWidth);
			if (!layout.compare(_measuredLayout))
			{
				target.invalidateSize();
				
				// defer until measure() gets called again
				return;
			}
			
			doLayout(layout, containerWidth, true);
			
			// Scrolling support - update the content size
			target.setContentSize(layout.width, layout.height);
		}
	}
}

internal final class GridLayout
{
	public var x:Number;
	public var y:Number;
	public var width:Number;
	public var height:Number;
	public function GridLayout()
	{
		reset();
	}
	public function reset():void
	{
		x = 0;
		y = 0;
		width = 0;
		height = 0;
	}
	public function compare(rhs:GridLayout):Boolean
	{
		return width == rhs.width && height == rhs.height;
	}
}