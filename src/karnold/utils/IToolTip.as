package karnold.utils
{
	import flash.display.DisplayObject;

	public interface IToolTip
	{
		function set text(t:String):void;
		function get displayObject():DisplayObject;
	}
}