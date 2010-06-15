package net.goozo.mx.dockable
{
	import mx.core.UIComponent;
	
[ExcludeClass]

	public class DockHint extends UIComponent
	{
		private var inColor:uint;
		private var outColor:uint;
		private var radius:Number;
		 
		public function DockHint(inColor:uint = 0xFFFF00, outColor:uint = 0xFF0000, radius:Number = 4)
		{
			super();
			this.inColor = inColor;
			this.outColor = outColor;
			this.radius = radius;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			graphics.lineStyle(2, inColor, 1, true);
			graphics.drawRoundRect(3, 3, unscaledWidth-6, unscaledHeight-6, radius);
			graphics.lineStyle(2, outColor, 1, true);
			graphics.drawRoundRect(1, 1, unscaledWidth-2, unscaledHeight-2, radius);
		}
	}
}