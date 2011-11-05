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
	
	import mx.controls.Alert;
	
	import ui.Dialog;

	[Event(name="PosCmdEvent.COMPLETE", type="src.PosCmdEvent")]
	[Event(name="PosCmdEvent.ERROR", type="src.PosCmdEvent")]
	[Event(name="PosCmdEvent.OUTPUT", type="src.PosCmdEvent")]
	public class PosCmd extends EventDispatcher
	{
		// factory methods
		static public function createPrintCmd(order:Order, ticket:Boolean):PosCmd
		{
			return new PrintPosCmd(order, ticket);
		}
		static public function createOpenDrawerCmd():PosCmd
		{
			return new OpenDrawerPosCmd;
		}
		private var _p:NativeProcess;
		public function PosCmd(FACTORY_CREATED_ONLY:Class)
		{
			if (FACTORY_CREATED_ONLY != FACTORY_GUARD) throw "Create this only with the factory methods above";
			
			_p = new NativeProcess;
			_p.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onPosCmdStdInProgress);
			_p.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onPosCmdStdOut);
			_p.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onPosCmdStdErr);
			_p.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onPosCmdError);
			_p.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onPosCmdError);
			_p.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onPosCmdError);
			_p.addEventListener(NativeProcessExitEvent.EXIT, onPosCmdDone);
		}
		// template method
		public function run():void	
		{			
			if (!_p.running)
			{
				var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo;
				startupInfo.executable = (new File).resolvePath(Data.settings.data.poscmdPath);
				startupInfo.arguments = new Vector.<String>();

//				if (Data.settings.data.simulatePOS)
//				{
//					startupInfo.arguments.push("/emu");
//				}
				run_impl(_p, startupInfo);
			}
		}
		// abstract method for the run() template
		protected function run_impl(np:NativeProcess, startupInfo:NativeProcessStartupInfo):void  {}
		private function onPosCmdStdOut(e:Event):void
		{
			//Dialog.alert(this, "onPosCmdStdOut", "kira", [Dialog.BTN_DONE]);

			const result:String = _p.standardOutput.readUTFBytes(_p.standardOutput.bytesAvailable);
			trace(result);
			
			dispatchEvent(new PosCmdEvent(PosCmdEvent.OUTPUT, result));
		}
		private function onPosCmdStdErr(e:Event):void
		{
			const result:String = _p.standardOutput.bytesAvailable ? _p.standardOutput.readUTFBytes(_p.standardError.bytesAvailable) : "unknown stderr"; 
			trace(result);
			
			dispatchEvent(new PosCmdEvent(PosCmdEvent.ERROR, result));
		}
		private function onPosCmdDone(e:NativeProcessExitEvent):void
		{
			const result:String = String(e.exitCode);
			trace("pos process done, code", result);
			
			dispatchEvent(new PosCmdEvent(PosCmdEvent.COMPLETE, result));
		}
		private function onPosCmdError(e:IOErrorEvent):void
		{
			//Dialog.alert(this, "onPosCmdError", "kira", [Dialog.BTN_DONE]);
			
			trace("pos cmd error, code", result);
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
	}
}
import data.Data;
import data.LineItem;
import data.Order;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.filesystem.File;

final internal class FACTORY_GUARD {}

final class PrintPosCmd extends PosCmd
{
	private var _command:String;
	public function PrintPosCmd(order:Order, ticket:Boolean)
	{
		super(FACTORY_GUARD);
		_command = encodeOrderForPrinting(order, ticket) + "\r\n";
	}
	static private function encodeOrderForPrinting(order:Order, ticket:Boolean):String
	{
		// tenderAmount - NOT HOOKED UP
		const customer:Object = Data.instance.getCustomer(order.customerID);
		const command:Object =
		{
			type: ticket ? "ticket" : "receipt",
			id:   order.id,
			datetime: new Date().toLocaleString(),
			total: order.total,
			paymentType: "Cash",
			tenderAmount: 20,
			businessInfo:
			{
				name: "J's Cleaners",
				addr1: "205 S San Mateo Dr",
				addr2: "San Mateo, CA 94010",
				web: "http://www.jsdryclean.com",
				phone: "(650) 343-2060",
				footer: "Thanks for choosing J's Cleaners."
			},
			customerInfo:
			{
				name: customer.name || "Kira Tsu",
				address: customer.email || "kerbumble@yahoo.com",
				phone: customer.phone || "6502003022"
			},
			items: []

		};
		
		for each (var item:LineItem in order.items.source)
		{
			const itemObj:Object =
			{
				quantity: item.quantity,
				description: item.name,
				comment: item.description || "",
				perItemPrice: item.price,
				amount: item.price * item.quantity
			};
			
			command.items.push(itemObj);
		}
		return JSON.stringify(command);
	}
	protected override function run_impl(np:NativeProcess, startupInfo:NativeProcessStartupInfo):void
	{
//		startupInfo.arguments.push("/printSlip");

		np.start(startupInfo);
		if( Data.settings.data.simulatePOS )
		{
			np.standardInput.writeUTFBytes("[emu]\r\n");			
		}
		np.standardInput.writeUTFBytes("[printSlip]\r\n");
		np.standardInput.writeUTFBytes(_command + "\r\n[EOF]\r\n");
	}
}

final class OpenDrawerPosCmd extends PosCmd
{
	public function OpenDrawerPosCmd()
	{
		super(FACTORY_GUARD);
	}
	protected override function run_impl(np:NativeProcess, startupInfo:NativeProcessStartupInfo):void
	{
		np.start(startupInfo);

		if( Data.settings.data.simulatePOS )
		{
			np.standardInput.writeUTFBytes("[emu]\r\n");			
		}
		np.standardInput.writeUTFBytes("[openDrawer]\r\n[EOF]\r\n");
	}
}