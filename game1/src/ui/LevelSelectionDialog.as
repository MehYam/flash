package ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import gameData.UserData;
	
	import karnold.ui.ShadowTextField;
	import karnold.utils.Util;
	
	public class LevelSelectionDialog extends GameDialog
	{
		public function LevelSelectionDialog()
		{
			super();

			title = "LEVEL SELECTION";

			addLevelButtons();
			addBottomInterface();

			render();
		}
		
		private function addLevelButtons():void
		{
			var btn:GameButton;
			for (var r:uint = 0; r < 7; ++r)
			{
				for (var c:uint = 0; c < 5; ++c)
				{
					var level:uint = (r*c) + r;
					btn = GameButton.create("Level " + level, false, 18, 1);
					btn.name = String(level);
					btn.width = 85;
					btn.y = TOP_MARGIN + (r * (btn.height + 2));
					btn.x = 10 + c * (btn.width + 2);

					if (UserData.instance.levelReached < level)
					{
						btn.enabled = false;
						var lock:DisplayObject = AssetManager.instance.lock();
						lock.scaleX = 0.7;
						lock.scaleY = 0.7;
						lock.x = btn.width - lock.width;
						lock.y = btn.height - lock.height;
						DisplayObjectContainer(btn).addChild(lock);
					}
					else
					{
						Util.listen(btn, MouseEvent.CLICK, onLevel);
					}

					addChild(btn);
				}
			}
		}
		
		private function addBottomInterface():void
		{
			var hangar:DisplayObject = GameButton.create("Plane Hangar", true, 20, 1);
			hangar.x = 10;
			hangar.y = height + 20;
			
			addChild(hangar);
			Util.listen(hangar, MouseEvent.CLICK, onPlaneHangar); 

			var garage:GameButton = GameButton.create("Tank Garage", true, 20, 1);
			garage.x = hangar.x;
			garage.y = hangar.y + hangar.height + 5;
			garage.width = hangar.width;
			
			addChild(garage);
			Util.listen(garage, MouseEvent.CLICK, onTankGarage);

			var goldReportParent:Sprite = new Sprite;

			var tf:TextFormat = new TextFormat("Computerfont", 24);
			var goldReport:ShadowTextField = new ShadowTextField(tf, 0xffffff, 0x00, 1);
			goldReport.text = "Credits:";
			
			goldReportParent.addChild(goldReport);
			
			var gold:ShadowTextField = new ShadowTextField(new TextFormat("SF Transrobotics", 24), Consts.CREDIT_FIELD_COLOR, 0, 1);
			gold.y = goldReport.y - 2;
			gold.x = goldReport.x + goldReport.width + 2;
			gold.text = "230000";
			
			goldReportParent.addChild(gold);

			goldReportParent.x = width - goldReportParent.width;
			goldReportParent.y = height - goldReportParent.height;
		
			addChild(goldReportParent);
		}
		
		private function onPlaneHangar(e:Event):void
		{
			UIUtil.openDialog(parent, new UpgradePlaneDialog);
		}
		private function onTankGarage(e:Event):void
		{
			UIUtil.openDialog(parent, new UpgradeTankDialog);
		}
		private function onLevel(e:Event):void
		{
			const level:uint = parseInt(DisplayObject(e.currentTarget).name);
			
		}
	}
}