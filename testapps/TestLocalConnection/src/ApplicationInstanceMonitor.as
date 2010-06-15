//
// Call start() with the channel upon which you want to define the application's id, i.e. .start("zomg").
// This will fire an event when a new instance starts and/or when an old instance has been found.
// If you're the old instance, you'll get the new instance starting event and will have to close the
// channel.  If you're the new instance, you can keep trying to acquire the channel by calling
// .start again. 
package
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;

	[Event(name=ApplicationInstanceMonitorEvent.INSTANCE_STARTING, type="ApplicationInstanceMonitorEvent")]
	public class ApplicationInstanceMonitor extends EventDispatcher
	{
		private static const MSG_INSTANCE_STARTING:String = "msg.instanceStarting";

		private var _localConnectionInbound:LocalConnection;
		public function ApplicationInstanceMonitor()
		{
			super();
		}
		
		public function start(channel:String):void
		{
            _localConnectionInbound = new LocalConnection();
            _localConnectionInbound.client = this;  // allow receiveMessage to be called

			const name:String = "com.gaiaonline." + channel;  // may be redundant, I think Flash prepends the domain too
            try
            {
                _localConnectionInbound.connect(name);
            }
            catch (error:ArgumentError)
            {
				// assume this connection is already in use - tell the existing instance that a new one has started
                
				var localConnectionOutbound:LocalConnection = new LocalConnection();
				localConnectionOutbound.addEventListener(StatusEvent.STATUS, onStatus);
				localConnectionOutbound.send(name, "receiveMessage", MSG_INSTANCE_STARTING);  // unlikely that this will throw
				
				dispatchEvent(new ApplicationInstanceMonitorEvent(ApplicationInstanceMonitorEvent.INSTANCE_EXISTS));
            }
		}

		public function stop():void
		{
			_localConnectionInbound.close();
		}

		private function onStatus(e:StatusEvent):void
		{
            switch (e.level) {
            case "status":
				// outbound send success!
                break;
            case "error":
				dispatchEvent(new ApplicationInstanceMonitorEvent(ApplicationInstanceMonitorEvent.SEND_ERROR));
                break;
            }
		}

		//
		// This really isn't part of the public interface, it just needs to be public for the 
		// external LocalConnection to call us. We could use a member Object with a closure instead.   
		public function receiveMessage(str:String):void
		{
			dispatchEvent(new ApplicationInstanceMonitorEvent(ApplicationInstanceMonitorEvent.INSTANCE_STARTING));
		}
	}
}