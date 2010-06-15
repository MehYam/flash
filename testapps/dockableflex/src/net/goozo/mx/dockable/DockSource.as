package net.goozo.mx.dockable
{
	import mx.core.Container;

[ExcludeClass]

	public class DockSource
	{
		public var dockType:String;
		public var dockId:String;
		
		public var multiTabEnabled:Boolean = true;
		public var floatEnabled:Boolean = true;
		public var autoCreatePanelEnabled:Boolean = true;
		public var panelType:int = DockManager.DOCKABLEPANEL;
		
		public var lockPanel:Boolean = false;
		
		public var targetTabNav:DockableTabNavigator
		public var targetChild:Container;
		public var targetPanel:DockablePanel;
		
		

		
		public function DockSource(dockType:String, targetTabNav:DockableTabNavigator, dockId:String = "")
		{
			this.dockType = dockType;
			this.targetTabNav = targetTabNav;
			this.dockId = dockId;
		}

	}
}