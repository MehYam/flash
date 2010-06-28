package
{
	import karnold.utils.FrameRatePanel;
	import karnold.utils.NumericRasterTextField;
	
	public class OurFrameRatePanel extends FrameRatePanel
	{
		private var _txt1:NumericRasterTextField;
		private var _txt2:NumericRasterTextField;
		private var _txt3:NumericRasterTextField;
		private var _pooled:NumericRasterTextField;
		private var _debugText:NumericRasterTextField;

		public function OurFrameRatePanel()
		{
			super();

			_txt1 = new NumericRasterTextField();
			_txt1.suffix = "t";
			addFieldOnNextLine(_txt1);	
			
			_txt2 = new NumericRasterTextField();
			_txt2.suffix = "do";
			addField(_txt2, 55);	

			_txt3 = new NumericRasterTextField();
			_txt3.suffix = " cast";
			addFieldOnNextLine(_txt3);
			
			_pooled = new NumericRasterTextField();
			_pooled.suffix = " pooled";
			addFieldOnNextLine(_pooled);

			_debugText = new NumericRasterTextField;
//			addFieldOnNextLine(_debugText);
			
			txt1 = 0;
			txt2 = 0;
			txt3 = 0;
			_debugText.integer = 0;
			debug = "ready";
		}
		public function set txt1(i:int):void
		{
			_txt1.integer = i;
		}
		public function set txt2(i:int):void
		{
			_txt2.integer = i;
		}
		public function set txt3(i:int):void
		{
			_txt3.integer = i;
		}
		public function set pooled(i:int):void
		{
			_pooled.integer = i;
		}
		public function set debug(str:String):void
		{
			_debugText.suffix = str;
		}
	}
}