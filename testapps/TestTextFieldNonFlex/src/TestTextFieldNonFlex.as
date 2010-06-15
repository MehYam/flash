package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;

	public class TestTextFieldNonFlex extends Sprite
	{
		private static function newTextField(text:String, x:Number, y:Number):TextField
		{
			var tf:TextField = new DerivedTextField;
			tf.text = text;
			tf.x = x;
			tf.y = y;
			tf.type = TextFieldType.INPUT;
			tf.backgroundColor = 0xffffff;
			tf.background = true;
			tf.autoSize = TextFieldAutoSize.CENTER;
			return tf;
		}
		public function TestTextFieldNonFlex()
		{
			addChild(newTextField("text field 1", 10, 20));
			addChild(newTextField("text field 2", 10, 40));
		}
	}
}
