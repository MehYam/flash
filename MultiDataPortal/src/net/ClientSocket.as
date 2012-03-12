package net
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;

	public final class ClientSocket
	{
		static public function create():ClientSocket
		{
			var retval:ClientSocket = new ClientSocket(CONSTRUCTOR_LOCK);
			return retval;
		}
		// dispatches ClientSocketEvents
		public function get events():EventDispatcher
		{
			return _events;
		}
		public function get status():SocketStatus
		{
			return SocketStatus.CLOSED;
		}
		public function close():void
		{
			if (_clientSocket && _clientSocket.connected)
			{
				_clientSocket.close();
			}
		}
		
		private var _host:String;
		private var _port:int;
		private var _interval:int;
		public function connectWithRetry(host:String, port:int, interval:int):void
		{
			_host = host;
			_port = port;
			_interval = interval;
			
			tryConnect();
		}
		
		// implementation
		public function ClientSocket(lock:Class) { if (lock != CONSTRUCTOR_LOCK) throw "constructed from the class factory only"; }

		private var _events:EventDispatcher = new EventDispatcher;
		private var _clientSocket:Socket;
		private var _status:SocketStatus = SocketStatus.READY;
		
		private function tryConnect():void
		{
			close();
			removeListeners(_clientSocket);
			
			_clientSocket = new Socket;
			_clientSocket.timeout = _interval;
			addListeners(_clientSocket);
		}
		private function addListeners(socket:Socket):void
		{
			socket.addEventListener(Event.CONNECT, clientConnectHandler, false, 0, true); 
			socket.addEventListener(Event.CLOSE, clientCloseHandler, false, 0, true); 
			socket.addEventListener(ErrorEvent.ERROR, clientErrorHandler, false, 0, true); 
			socket.addEventListener(IOErrorEvent.IO_ERROR, clientIOErrorHandler, false, 0, true); 
			socket.addEventListener(ProgressEvent.SOCKET_DATA, clientProgressHandler, false, 0, true);
		}
		private function removeListeners(socket:Socket):void
		{
			if (socket)
			{
				socket.removeEventListener(Event.CONNECT, clientConnectHandler); 
				socket.removeEventListener(Event.CLOSE, clientCloseHandler); 
				socket.removeEventListener(ErrorEvent.ERROR, clientErrorHandler); 
				socket.removeEventListener(IOErrorEvent.IO_ERROR, clientIOErrorHandler); 
				socket.removeEventListener(ProgressEvent.SOCKET_DATA, clientProgressHandler);
			}
		}
		private function clientConnectHandler(e:Event):void
		{
			trace("client connected");
		}
		private function clientCloseHandler(e:Event):void
		{
			trace("client closed");
			tryConnect();
		}
		private function clientErrorHandler(e:ErrorEvent):void
		{
			trace("client error", e);
			tryConnect();
		}
		private function clientIOErrorHandler(e:IOErrorEvent):void
		{
			trace("client IO error", e);
			tryConnect();
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
	}
}

final internal class CONSTRUCTOR_LOCK {}