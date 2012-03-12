package
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;

	public class SocketTest
	{
		private var _clientSocket:Socket;
		public function testClient(host:String, port:int):void
		{
			_clientSocket = new Socket;
			_clientSocket.addEventListener(Event.CONNECT, clientConnectHandler, false, 0, true); 
			_clientSocket.addEventListener(Event.CLOSE, clientCloseHandler, false, 0, true); 
			_clientSocket.addEventListener(ErrorEvent.ERROR, clientErrorHandler, false, 0, true); 
			_clientSocket.addEventListener(IOErrorEvent.IO_ERROR, clientIOErrorHandler, false, 0, true); 
			_clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, clientProgressHandler, false, 0, true);
			
			_clientSocket.connect(host, port);
		}
		private function clientConnectHandler(e:Event):void
		{
			trace("client connected");
		}
		private function clientCloseHandler(e:Event):void
		{
			trace("client closed");
		}
		private function clientErrorHandler(e:ErrorEvent):void
		{
			trace("client error", e);
		}
		private function clientIOErrorHandler(e:IOErrorEvent):void
		{
			trace("client IO error", e);
		}
		private function clientProgressHandler(e:ProgressEvent):void
		{
			var ba:ByteArray = new ByteArray;
			while (_clientSocket.bytesAvailable)
			{
				_clientSocket.readBytes(ba);
				trace("read", ba.length, "bytes");
			}
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////
	}
}