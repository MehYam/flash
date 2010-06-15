package net.goozo.mx.dockable
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.TabBar;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.core.Application;
	
[ExcludeClass]	
	internal class DockHelper
	{
		public var targetCanvas:Container;
		public var lastBtn:Button;
		public var lastTabBar:TabBar;
		public var lastTabNav:DockableTabNavigator;
		public var lastPanel:DockablePanel;
		
		public var lastAccepter:UIComponent;
		public var lastPosition:String;
		public var lastDistance:Number;
		
		private var checklog:Object;
		
		public var acceptLevel:Number;
		public var lastDividedChild:UIComponent;
			
		public function DockHelper()
		{
			super();
			clear();
		}
		public function clear():void
		{
			checklog = new Object();
			targetCanvas = null;
			lastDividedChild = null;
		}
		public function findCanvas(panel:DockablePanel):Container
		{
			var getTar:DisplayObject = panel;
			while (getTar != Application.application)
			{
				if (getTar is Canvas)
				{
					targetCanvas = getTar as Container;
					return targetCanvas;
				}

				getTar = getTar.parent;
			}
			targetCanvas = Application.application as Container;
			return targetCanvas;
		}

		public function findTabBar(target:DisplayObject):Boolean
		{
			var getTar:DisplayObject = target;
			
			var nFind:int = 0;
			while (!(getTar is ClosablePanel) && getTar != Application.application)
			{
				if (getTar is DockableTabNavigator)
				{
					lastTabNav = DockableTabNavigator(getTar);
					nFind |= 4;
					break;
				}
				else if (getTar is TabBar)
				{
					lastTabBar = TabBar(getTar);
					nFind |= 2;
				}
				else if (getTar is Button)
				{
					lastBtn = Button(getTar);
					nFind |= 1;
				}
				getTar = getTar.parent;
			}
			if (nFind == 7)
			{
				lastAccepter = lastBtn;
				return true;
			}
			return false;
		}
		public function findPanel(target:DisplayObject):Boolean
		{
			var getTar:DisplayObject = target;
			
			while (!(getTar is IDockableDividedBox) && getTar != Application.application)
			{
				if (getTar is DockablePanel)
				{
					lastPanel = DockablePanel(getTar);
					findCanvas(lastPanel);
					return true;
				}
				getTar = getTar.parent;
			}
			return false;
		}
		public function checkTabBar(source:DockSource):Boolean
		{
			lastPosition = closestSideToBtn(lastBtn);
			lastAccepter = lastBtn;
			return lastTabNav.dockAsk(source, lastAccepter, lastPosition);
		}
		public function checkPanel(source:DockSource):Boolean
		{
			lastPosition = closestSideToPanel(lastPanel);
			if (lastDistance >= 0.25)
			{
				return false;
			}
			lastAccepter = findHighestAccepter(lastPanel, lastPosition);
			return lastPanel.dockAsk(source, lastAccepter, lastPosition);
		}
		
		public static function closestSideToBtn(component:UIComponent):String
		{
			var bound:Rectangle = getRect(component, component);//component.getRect(component);
			var leftRate:Number = component.mouseX / bound.width;
			if (leftRate < 0.5)
			{
				return DockManager.LEFT;
			}
			else
			{
				return DockManager.RIGHT;
			}
		}
		public function closestSideToPanel(component:UIComponent):String
		{
			var bound:Rectangle = getRect(component, component);//component.getRect(component);
			var leftRate:Number = component.mouseX / bound.width;
			var topRate:Number = component.mouseY / bound.height;
			var rightRate:Number = 1 - leftRate;
			var bottomRate:Number = 1 - topRate;
			lastDistance = Math.min(leftRate, topRate, rightRate, bottomRate);
	
			switch (lastDistance)
			{
				case leftRate:
					return DockManager.LEFT;
				case topRate:
					return DockManager.TOP;
				case rightRate:
					return DockManager.RIGHT;
				case bottomRate:
					return DockManager.BOTTOM;
			}
			return "";
		}
		public function rateFromMouse(component:UIComponent, side:String):Number
		{
			var bound:Rectangle = getRect(component, component);//component.getRect(component);
			var toLeft:Number = component.mouseX / bound.width;
			var toTop:Number = component.mouseY / bound.height;
			
			switch (side)
			{
				case DockManager.LEFT:
					return toLeft;
				case DockManager.TOP:
					return toTop;
				case DockManager.RIGHT:
					return 1 - toLeft;
				case DockManager.BOTTOM:
					return 1 - toTop;
			}
			throw new Error("unknown side");
			return 0;
		}
		
		public function findHighestAccepter(target:Container, side:String):Container
		{
			switch (side)
			{
				case DockManager.LEFT:
				case DockManager.RIGHT:
					 return findHighestAccepterH(target, side);
				case DockManager.TOP:
				case DockManager.BOTTOM:
					return findHighestAccepterV(target, side);
			}
			return null;
		}
		private function findHighestAccepterH(target:Container, side:String):Container
		{
			var iterateTarget:Container = target;
			var tempLastDividedChild:UIComponent;
			var returnTarget:Container;
			var threshold:Number = 0.25;
			
			var sideRate:Number = rateFromMouse(target, side);
			while (sideRate < threshold && rateFromMouse(iterateTarget, side) < threshold)
			{
				if (iterateTarget is DockableVDividedBox)
				{
					acceptLevel = sideRate * 2 / threshold - 1;
					lastDividedChild = tempLastDividedChild;
				}
				else
				{
					lastDividedChild = null;
				}
				
				returnTarget = iterateTarget;
				
				if (iterateTarget.parent is DockableHDividedBox)
				{				
					do
					{
						iterateTarget = Container(iterateTarget.parent);
					}
					while (iterateTarget.parent is DockableHDividedBox);
				}
				if (iterateTarget.parent is DockableVDividedBox)
				{
					tempLastDividedChild = iterateTarget;
					iterateTarget = iterateTarget.parent as Container;
				}
				else
				{
					break;
				}
				threshold /= 2;
			}
			if (lastDividedChild)
			{
				rateFromMouse(lastDividedChild, side); //update properties
			}
			return returnTarget;
		}
		private function findHighestAccepterV(target:Container, side:String):Container
		{
			var iterateTarget:Container = target;
			var tempLastDividedChild:UIComponent;
			var returnTarget:Container;
			var threshold:Number = 0.25;
			
			var sideRate:Number = rateFromMouse(target, side);
			while (sideRate < threshold && rateFromMouse(iterateTarget, side) < threshold)
			{
				if (iterateTarget is DockableHDividedBox)
				{
					acceptLevel = sideRate * 2 / threshold - 1;
					lastDividedChild = tempLastDividedChild;
				}
				else
				{
					lastDividedChild = null;
				}
				
				returnTarget = iterateTarget;

				if (iterateTarget.parent is DockableVDividedBox)
				{				
					do
					{
						iterateTarget = Container(iterateTarget.parent);
					}
					while (iterateTarget.parent is DockableVDividedBox);
				}
				if (iterateTarget.parent is DockableHDividedBox)
				{
					tempLastDividedChild = iterateTarget;
					iterateTarget = iterateTarget.parent as Container;
				}
				else
				{
					break;
				}
				threshold /= 2;
			}
			if (lastDividedChild)
			{
				rateFromMouse(lastDividedChild, side); //update properties
			}
			return returnTarget;
		}
		public static function replace(dest:UIComponent, source:UIComponent):void
		{
			if (dest.parent == null)
			{
				return;
			}
			source.x = dest.x;
			source.y = dest.y;
			source.height = dest.height;
			source.width = dest.width;
			source.percentHeight = dest.percentHeight;
			source.percentWidth = dest.percentWidth;
			source.setStyle("left", dest.getStyle("left"));
			source.setStyle("right", dest.getStyle("right"));
			source.setStyle("top", dest.getStyle("top"));
			source.setStyle("bottom", dest.getStyle("bottom"));
			source.setStyle("baseline", dest.getStyle("baseline"));
			source.setStyle("horizontalCenter", dest.getStyle("horizontalCenter"));
			source.setStyle("verticalCenter", dest.getStyle("verticalCenter"));
			
			var findIndex:int = dest.parent.getChildIndex(dest);
			dest.parent.addChildAt(source, findIndex);
			dest.parent.removeChild(dest);
		}
		
		public static function getRect(target:DisplayObject, coordinateSpace:DisplayObject):Rectangle
		{
			var pt:Point = new Point(0, 0);
			pt = target.localToGlobal(pt);
			pt = coordinateSpace.globalToLocal(pt);
			return new Rectangle(pt.x, pt.y, target.width, target.height);
		}
			
	}
}