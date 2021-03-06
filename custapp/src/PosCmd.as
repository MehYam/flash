package
{
	import data.Data;
	import data.LineItem;
	import data.Order;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.globalization.DateTimeStyle;
	
	import karnold.utils.Util;
	
	import mx.controls.Alert;
	
	import ui.Dialog;

	[Event(name="PosCmdEvent.COMPLETE", type="src.PosCmdEvent")]
	[Event(name="PosCmdEvent.ERROR", type="src.PosCmdEvent")]
	[Event(name="PosCmdEvent.OUTPUT", type="src.PosCmdEvent")]
	public class PosCmd extends EventDispatcher
	{
		static private var s_instances:uint = 0;

		private const _instance:uint = s_instances++;
		private var _p:NativeProcess;
		private var _openDrawer:Boolean;
		private var _printSlip:Boolean;
		private var _order:Order;
		private var _isTicket:Boolean;
		public function PosCmd() //FACTORY_CREATED_ONLY:Class)
		{
			Util.debug(_instance, "PosCmd constructor");
						
			_p = new NativeProcess;
			_p.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onPosCmdStdInProgress);
			_p.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onPosCmdStdOut);
			_p.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onPosCmdStdErr);
			_p.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onPosCmdError);
			_p.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onPosCmdError);
			_p.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onPosCmdError);
			_p.addEventListener(NativeProcessExitEvent.EXIT, onPosCmdDone);
		}
		public function openDrawer():void
		{
			Util.debug(_instance, "PosCmd::openDrawer");
			_openDrawer = true;			
		}
		public function printSlip(order:Order, isTicket:Boolean):void
		{
			Util.debug(_instance, "PosCmd::printSlip", "isTicket: " + isTicket);
			_printSlip = true;
			_order = order;
			_isTicket = isTicket;			
		}
		// template method
		public function run():void	
		{				
			Util.debug(_instance, "PosCmd::run()");
		
			if (!_p.running)
			{
				Util.debug(_instance, "PosCmd::run(), !_p.running");

				var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo;
				startupInfo.executable = (new File).resolvePath(Data.settings.data.poscmdPath);
				//startupInfo.arguments = new Vector.<String>();

				Util.debug("startupInfo", startupInfo);
				Util.debug("process", _p);

				try
				{
					_p.start(startupInfo);
				}
				catch (e:Error)
				{
					Util.error("process.start error", e.message, "\n", e.toString());
				}


				if( Data.settings.data.simulatePOS )
				{
					Util.debug(_instance, "writing [emu] command to PosCmd's stdin");
					_p.standardInput.writeUTFBytes("[emu]\r\n");			
				}
				if( _openDrawer )
				{
					Util.debug(_instance, "writing [openDrawer] command PosCmd's stdin");
					_p.standardInput.writeUTFBytes("[openDrawer]\r\n");
				}
				if( _printSlip )
				{
					Util.debug(_instance, "writing [printSlip] command to PosCmd's stdin");
					_p.standardInput.writeUTFBytes("[printSlip]\r\n");
					_p.standardInput.writeUTFBytes(encodeOrderForPrinting(_order, _isTicket) + "\r\n");
				}
				Util.debug(_instance, "PosCmd::run(), 3");

				_p.standardInput.writeUTFBytes("[EOF]\r\n");
			}
		}

		// abstract method for the run() template
//		protected function run_impl(np:NativeProcess, startupInfo:NativeProcessStartupInfo):void  {}
		private function onPosCmdStdOut(e:Event):void
		{
			const result:String = _p.standardOutput.readUTFBytes(_p.standardOutput.bytesAvailable);
			Util.debug(_instance, "PosCmd stdout", result);
			
			dispatchEvent(new PosCmdEvent(PosCmdEvent.OUTPUT, result));
		}
		private function onPosCmdStdErr(e:Event):void
		{
			const result:String = _p.standardOutput.bytesAvailable ? _p.standardOutput.readUTFBytes(_p.standardError.bytesAvailable) : "unknown stderr"; 
			Util.debug(_instance, "PosCmd stderr", result);
			
			dispatchEvent(new PosCmdEvent(PosCmdEvent.ERROR, result));
		}
		private function onPosCmdDone(e:NativeProcessExitEvent):void
		{
			const result:String = String(e.exitCode);
			Util.debug(_instance, "PosCmd done", result);
			
			dispatchEvent(new PosCmdEvent(PosCmdEvent.COMPLETE, result));
		}
		private function onPosCmdError(e:IOErrorEvent):void
		{
			//Dialog.alert(this, "onPosCmdError", "kira", [Dialog.BTN_DONE]);
			
			Util.debug(_instance, "PosCmd error, code", result);
			const result:String = e.toString();
			
			dispatchEvent(new PosCmdEvent(PosCmdEvent.ERROR, result));
		}
		private function onPosCmdStdInProgress(e:ProgressEvent):void
		{
			if (e.bytesLoaded >= e.bytesTotal)
			{
//				_p.closeInput();
			}
		}
		import spark.formatters.DateTimeFormatter;
		private function encodeOrderForPrinting(order:Order, ticket:Boolean):String
		{
//			Util.debug(_instance, "PosCmd::encodeOrderForPrinting()", "is ticket? " + ticket);
//			var dtf:DateTimeFormatter = new DateTimeFormatter();
//			dtf.dateTimePattern = "mm/dd/yy h:mm a";
//			dtf.setStyle("locale", "en-US");
			
			// tenderAmount - NOT HOOKED UP
			const customer:Object = Data.instance.getCustomer(order.customerID) || { first:"unknown", last:"", email: "kerbumble@yahoo.com", phone: "----"};
			const command:Object =
			{
				type: ticket ? "ticket" : "receipt",
					id:   order.id,
					datetimePickup: new Date(order.pickupTime).toLocaleString(),
					datetimeDropoff: new Date(order.creationTime).toLocaleString(),
					
					total: order.total,
					discount: order.discount,
					paymentType: order.paymentType,
					tenderAmount: order.tenderAmount,
					change: order.change,
					
					businessInfo:
					{
						name: "J's Cleaners & Alterations",
						addr1: "205 S San Mateo Dr",
						addr2: "San Mateo, CA 94010",
						web: "http://www.jsdryclean.com",
						phone: "(650) 343-2060"
					},
					customerInfo:
					{
						name: customer.first + " " + customer.last,
						phone: Utils.phoneFormatter.format(customer.phone)
					},
					items: [],
					totalPieces: 0,
					storeHours: "Store Hours:\r\nMON-FRI 7:30-6:00 | SAT 8:00-5:00 | SUN Closed", 
					footer: "Thanks for choosing J's Cleaners."

			};
			
			for each (var item:LineItem in order.items.source)
			{
				const itemObj:Object =
					{
						quantity: item.pieceQuantity,
						description: Data.inventoryCatsMap[item.category] + " " + item.name,
						comment: item.description || "",
						perItemPrice: item.price,
						amount: item.price * item.quantity
					};
				
				command.items.push(itemObj);
				
				command.totalPieces += item.pieceQuantity;
			}
			
			return JSON.stringify(command);
		}
	
	}
}
