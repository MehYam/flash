package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
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
					btn = GameButton.create("Level " + ((r*c) + r), false, 18, 1);
					btn.enabled = !r && !c;
					btn.width = 85;
					btn.y = TOP_MARGIN + (r * (btn.height + 2));
					btn.x = 10 + c * (btn.width + 2);
					
					addChild(btn);
				}
			}
		}
		
		private function addBottomInterface():void
		{
			var hangar:GameButton = GameButton.create("Plane Selection", true, 20, 1);
			hangar.x = 10;
			hangar.y = height + 20;
			
			addChild(hangar);
			Util.listen(hangar, MouseEvent.CLICK, onPlaneHangar); 

			var garage:GameButton = GameButton.create("Tank Selection", true, 20, 1);
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
	}
}