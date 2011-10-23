package karnold.spark
{
	import mx.core.ILayoutElement;
	
	import spark.components.gridClasses.GridLayout;
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class FlowLayout extends LayoutBase
	{
		private var _horizontalGap:Number = 1;
		public function set horizontalGap(value:Number):void
		{
			_horizontalGap = value;
			
			// We must invalidate the layout
			var layoutTarget:GroupBase = target;
			if (layoutTarget)
			{
				layoutTarget.invalidateSize();
				layoutTarget.invalidateDisplayList();
			}
		}
		private var _verticalGap:Number = 1;
		public function set verticalGap(value:Number):void
		{
			_verticalGap = value;
			
			// We must invalidate the layout
			var layoutTarget:GroupBase = target;
			if (layoutTarget)
			{
				layoutTarget.invalidateSize();
				layoutTarget.invalidateDisplayList();
			}
		}
		
		private function doLayout(layout:GridLayout, targetWidth:Number):void
		{
			// assume we're flowing the way text word-wraps - this means our target will
			// already have a width, and so we'll calculate measured height based on that.
			var layoutTarget:GroupBase = target;
			var widthThisColumn:Number = 0;
			var heightThisRow:Number = 0;
			const count:int = layoutTarget.numElements;
			for (var i:int = 0; i < count; ++i)
			{
				// get the current element, we're going to work with the
				// ILayoutElement interface
				var element:ILayoutElement = useVirtualLayout ? 
					layoutTarget.getVirtualElementAt(i) :
					layoutTarget.getElementAt(i);
				
				// In virtualization scenarios, the element returned could
				// still be null. Look at the typical element instead.
				if (!element)
					element = typicalLayoutElement;
				
				// Find the preferred sizes    
				const elementWidth:Number = element.getPreferredBoundsWidth();
				const elementHeight:Number = element.getPreferredBoundsHeight();
				
				heightThisRow = Math.max(heightThisRow, elementHeight);
				if (layout.empty)
				{
					layout.totalHeight = heightThisRow;
					layout.widestColumn = widthThisColumn = elementWidth;
					layout.rows = 1;
				}
				else
				{
					if (widthThisColumn + elementWidth > targetWidth)
					{
						// wrap to next row
						layout.widestColumn = Math.max(layout.widestColumn, widthThisColumn);
						layout.totalHeight += heightThisRow;
						++layout.rows;
						
						widthThisColumn = elementWidth;
					}
					else
					{
						widthThisColumn += elementWidth;
					}
				}
			}
			layout.widestColumn = Math.max(layout.widestColumn, widthThisColumn);
		}
		private var _lastMeasuredLayout:GridLayout = new GridLayout;
		override public function measure():void
		{
			_lastMeasuredLayout.reset();			
			doLayout(_lastMeasuredLayout, target.width);
			target.measuredWidth = _lastMeasuredLayout.widestColumn;
			target.measuredHeight = _lastMeasuredLayout.totalHeight;
		}
		
		private var _lastDrawnLayout:GridLayout = new GridLayout;
		override public function updateDisplayList(containerWidth:Number,
												   containerHeight:Number):void
		{
			_lastDrawnLayout.reset();
			doLayout(_lastDrawnLayout, containerWidth);
			if (!_lastDrawnLayout.compare(_lastMeasuredLayout))
			{
				target.invalidateSize();
				
				// defer until measure() gets called again
				return;
			}
			
			// The position for the current element
			var x:Number = 0;
			var y:Number = 0;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			
			// loop through the elements
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;
			for (var i:int = 0; i < count; i++)
			{
				// get the current element, we're going to work with the
				// ILayoutElement interface
				var element:ILayoutElement = useVirtualLayout ? 
					layoutTarget.getVirtualElementAt(i) :
					layoutTarget.getElementAt(i);
				
				// Resize the element to its preferred size by passing
				// NaN for the width and height constraints
				element.setLayoutBoundsSize(NaN, NaN);
				
				// Find out the element's dimensions sizes.
				// We do this after the element has been already resized
				// to its preferred size.
				var elementWidth:Number = element.getLayoutBoundsWidth();
				var elementHeight:Number = element.getLayoutBoundsHeight();
				
				// Would the element fit on this line, or should we move
				// to the next line?
				if (x + elementWidth > containerWidth)
				{
					// Start from the left side
					x = 0;
					
					// Move down by elementHeight, we're assuming all 
					// elements are of equal height
					y += elementHeight + _verticalGap;
				}
				
				// Position the element
				element.setLayoutBoundsPosition(x, y);
				
				// Find maximum element extents. This is needed for
				// the scrolling support.
				maxWidth = Math.max(maxWidth, x + elementWidth);
				maxHeight = Math.max(maxHeight, y + elementHeight);
				
				// Update the current position, add the gap
				x += elementWidth + _horizontalGap;
			}
			
			// Scrolling support - update the content size
			layoutTarget.setContentSize(maxWidth, maxHeight);
		}
		//		override public function updateDisplayList(containerWidth:Number,
		//												   containerHeight:Number):void
		//		{
		//			_lastDrawnLayout.reset();
		//			doLayout(_lastDrawnLayout, containerWidth);
		//			if (!_lastDrawnLayout.compare(_lastMeasuredLayout))
		//			{
		//				target.invalidateSize();
		//				
		//				// defer until measure() gets called again
		//				return;
		//			}
		//			
		//			// The position for the current element
		//			var x:Number = 0;
		//			var y:Number = 0;
		//			var maxWidth:Number = 0;
		//			var maxHeight:Number = 0;
		//			
		//			// loop through the elements
		//			var layoutTarget:GroupBase = target;
		//			var count:int = layoutTarget.numElements;
		//			for (var i:int = 0; i < count; i++)
		//			{
		//				// get the current element, we're going to work with the
		//				// ILayoutElement interface
		//				var element:ILayoutElement = useVirtualLayout ? 
		//					layoutTarget.getVirtualElementAt(i) :
		//					layoutTarget.getElementAt(i);
		//				
		//				// Resize the element to its preferred size by passing
		//				// NaN for the width and height constraints
		//				element.setLayoutBoundsSize(NaN, NaN);
		//				
		//				// Find out the element's dimensions sizes.
		//				// We do this after the element has been already resized
		//				// to its preferred size.
		//				var elementWidth:Number = element.getLayoutBoundsWidth();
		//				var elementHeight:Number = element.getLayoutBoundsHeight();
		//				
		//				// Would the element fit on this line, or should we move
		//				// to the next line?
		//				if (x + elementWidth > containerWidth)
		//				{
		//					// Start from the left side
		//					x = 0;
		//					
		//					// Move down by elementHeight, we're assuming all 
		//					// elements are of equal height
		//					y += elementHeight + _verticalGap;
		//				}
		//				
		//				// Position the element
		//				element.setLayoutBoundsPosition(x, y);
		//				
		//				// Find maximum element extents. This is needed for
		//				// the scrolling support.
		//				maxWidth = Math.max(maxWidth, x + elementWidth);
		//				maxHeight = Math.max(maxHeight, y + elementHeight);
		//				
		//				// Update the current position, add the gap
		//				x += elementWidth + _horizontalGap;
		//			}
		//			
		//			// Scrolling support - update the content size
		//			layoutTarget.setContentSize(maxWidth, maxHeight);
		//		}
	}
}

internal final class GridLayout
{
	public var rows:uint = 0;
	public var widestColumn:Number = 0;
	public var totalHeight:Number = 0;
	
	public function reset():void
	{
		rows = 0;
		widestColumn = 0;
		totalHeight = 0;
	}
	public function get empty():Boolean
	{
		return !rows;
	}
	public function compare(rhs:GridLayout):Boolean
	{
		return widestColumn == rhs.widestColumn && totalHeight == rhs.totalHeight;
	}
}