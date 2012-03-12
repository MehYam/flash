package data
{
	import flash.net.SharedObject;
	
	import mx.collections.ArrayList;
	import mx.events.CollectionEvent;

	public final class Settings
	{
		static public function get instance():SharedObject
		{
			return SharedObject.getLocal("MDP.1");
		}
		static public const connectionData:ArrayList = new ArrayList([]);
		{
			connectionData.addEventListener(CollectionEvent.COLLECTION_CHANGE, onConnectionsChange);
		}
		static public function loadConnections():void
		{
			const newList:Array = [];
			for each (var item:Object in instance.data.connections)
			{
				var newItem:ConnectionItem = new ConnectionItem;
				newItem.destIP = item.destIP;
				newItem.destPort = item.destPort;
				newItem.destServerPort = item.destServerPort;
				newItem.destType = ConnectionType.fromString(item.destType);
				
				newItem.sourceIP = item.sourceIP;
				newItem.sourcePort = item.sourcePort;
				newItem.sourceType = ConnectionType.fromString(item.sourceType);
				
				newItem.name = item.name;
				newList.push(newItem);
			}
			connectionData.source = newList;
		}
		static private function onConnectionsChange(evt:CollectionEvent):void
		{
			saveConnections();
		}
		static private function saveConnections():void
		{
			var serialized:Array = [];			
			for each (var item:ConnectionItem in connectionData.source)
			{
				var obj:Object = {};
				obj.destIP = item.destIP;
				obj.destPort = item.destPort;
				obj.destServerPort = item.destServerPort;
				obj.destType = item.destType.toString();
				
				obj.sourceIP = item.sourceIP;
				obj.sourcePort = item.sourcePort;
				obj.sourceType = item.sourceType.toString();
				
				obj.name = item.name;
				
				serialized.push(obj);
			}
			instance.data.connections = serialized;
		}
	}
}