package
{
	import data.Data;
	import data.LineItem;
	import data.Order;
	
	import flash.desktop.JSClipboard;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;

	[Event(name="PosCmdEvent.COMPLETE", type="src.PosCmdEvent")]
	[Event(name="PosCmdEvent.ERROR", type="src.PosCmdEvent")]
	public final class PosCmd
	{
		private var _p:NativeProcess;
		public function print(order:Order):void
		{
			_p = new NativeProcess;
			_p.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onPosCmdStdOut);
			_p.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onPosCmdStdErr);
			_p.addEventListener(NativeProcessExitEvent.EXIT, onPosCmdDone);

			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo;
			startupInfo.executable = (new File).resolvePath("c:\\bin\\poscmd.exe");
			var args:Vector.<String> = new Vector.<String>();
			args.push("/Emulation");
			args.push("/PrintSlip");
			startupInfo.arguments = args;
			
			_p.start(startupInfo);
			_p.standardInput.writeUTFBytes(encodeOrderForPrinting(order));
		}
		private function encodeOrderForPrinting(order:Order):String
		{
			const customer:Object = Data.instance.getCustomer(order.customerID);
			const command:Object =
			{
				type: "ticket",
				id:   order.id,
				datetime: new Date().toLocaleString(),
				businessInfo:
				{
					name: "J's Cleaners",
					address: "205 S San Mateo Dr, San Mateo, CA 94401",
					web: "http://jsdryclean.com",
					phone: "(650) 343-2060"
				},
				customerInfo:
				{
					name: customer.name || "-",
						address: customer.email || "-",
						phone: customer.phone || "-",
						items: []
				}
			};
			for each (var item:LineItem in order.items.source)
			{
				const itemObj:Object =
					{
						quantity: item.quantity,
							description: item.name,
							comment: item.description || "",
							perItemPrice: item.price
					};
				command.customerInfo.items.push(itemObj);
			}
			return JSON.stringify(command);
		}
		public function popDrawer():void
		{
			
		}
		private function onPosCmdStdOut(e:Event):void
		{
			trace(_p.standardOutput.readUTFBytes(_p.standardOutput.bytesAvailable));
		}
		private function onPosCmdStdErr(e:Event):void
		{
			trace(_p.standardOutput.readUTFBytes(_p.standardError.bytesAvailable));
		}
		private function onPosCmdDone(e:NativeProcessExitEvent):void
		{
			trace("pos process done, code", e.exitCode);
		}
	}
}