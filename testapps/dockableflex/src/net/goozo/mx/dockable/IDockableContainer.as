package net.goozo.mx.dockable 
{
	import mx.core.IContainer;

[ExcludeClass]

	public interface IDockableContainer extends IContainer
	{
		function get floatEnabled():Boolean;
		function closeChild():void;
		function set panelType(value:int):void;
	}
	
}