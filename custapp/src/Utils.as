package
{
	import data.Order;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	import spark.formatters.CurrencyFormatter;
	import spark.formatters.NumberFormatter;
	
	import ui.Dialog;

	final public class Utils
	{
		public function Utils()
		{
		}
		static public function matches(item:String, pattern:String):Boolean
		{
			return item && item.length && (item.toUpperCase().indexOf(pattern) >= 0);
		}
		static private var s_cf:CurrencyFormatter;
		static public function get currencyFormatter():CurrencyFormatter
		{
			if (!s_cf)
			{
				s_cf = new CurrencyFormatter;
				s_cf.useCurrencySymbol = true;
			}
			return s_cf;
		}
		static private var s_pf:NumberFormatter;
		static public function get phoneFormatter():NumberFormatter
		{
			if (!s_pf)
			{
				s_pf = new NumberFormatter();
				s_pf.groupingPattern = "4;3;3";
				s_pf.groupingSeparator = "-";
				s_pf.fractionalDigits = 0;
			}
			return s_pf;
		}
		static public function extractDigits(str:String):String
		{
			return str.replace(/[^0-9]/g, "");
		}
		static public function daysToTime(days:Number):Number
		{
			return days * 24 * 60 * 60 * 1000;
		}
		static public function get beginningOfDay():Date
		{
			var retval:Date = new Date;
			retval.hours = 0;
			retval.minutes = 0;
			retval.seconds = 0;
			return retval;
		}
		static public function get endOfDay():Date
		{
			var retval:Date = new Date;
			retval.hours = 23;
			retval.minutes = 59;
			retval.seconds = 59;
			return retval;
		}
		static public function customerMatchesPattern(customer:Object, pattern:String):Boolean
		{
			return matches(customer.first, pattern) || 
				matches(customer.last, pattern) || 
				matches(customer.id, pattern) || 
				matches(customer.phone, pattern) || 
				matches(customer.email, pattern);
		}
		static public function showDialog(parent:DisplayObject, d:UIComponent):void
		{
			d.width = parent.width;
			d.maxHeight = parent.height;

			PopUpManager.addPopUp(d, parent, true);
			// KAI: with the right combination of percent height, centerPopUp was causing an infinite loop!  
			// Flex seems stuck in a measure -> invalidate -> measure kinda thing under validateNow().
			// Fixed it with the popup.height setting above
			PopUpManager.centerPopUp(d);
		}
		static public function createOrderEditorDialog(o:Order, title:String):Dialog
		{
			var orderEditor:OrderEditor = new OrderEditor;
			orderEditor.order = o;
			orderEditor.percentHeight = 100;
			orderEditor.percentWidth = 100;
			orderEditor.asPopup = true;
			
			var popup:Dialog = new Dialog;
			popup.autoClose = true;
			popup.bodyContent = orderEditor;
			popup.addButton(Dialog.BTN_DONE);
			popup.title = title;
			
			return popup;
		}
		
		static public function ViewOrder(o:Order, p:DisplayObject):void
		{
			var oview:OrderViewer = new OrderViewer;
			oview.order = o;
			
			var popup:Dialog = new Dialog;
			popup.bodyContent = oview;
			popup.autoClose = true;
			popup.title = "Order Viewer";
			popup.addButton(Dialog.BTN_DONE);
			
			PopUpManager.addPopUp(popup, p, true);
			PopUpManager.centerPopUp(popup);
		}
	}
}
