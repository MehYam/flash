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
			
			Util.listen(this, Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private var _buttons:Array = [];
		private function addLevelButtons():void
		{
			var btn:GameButton;
			const ROWS:uint = 7;
			for (var c:uint = 0; c < 5; ++c)
			{
				for (var r:uint = 0; r < ROWS; ++r)
				{
					var level:uint = (ROWS*c) + r;
					btn = GameButton.create("Level " + level, false, 18, 1);
					btn.name = String(level);
					btn.width = 85;
					btn.y = TOP_MARGIN + (r * (btn.height + 2));
					btn.x = 10 + c * (btn.width + 2);

//					if (!r && !c)
//					{
//						var icon:DisplayObject = AssetManager.instance.planeIcon();
//						icon.x = btn.width - icon.width;
//						icon.y = icon.height;
//						btn.addChild(icon);
//					}

					if (UserData.instance.levelReached < level)
					{
						btn.enabled = false;
						var lock:DisplayObject = AssetManager.instance.lock();
						lock.scaleX = 0.7;
						lock.scaleY = 0.7;
						lock.x = btn.width - lock.width;
						lock.y = btn.height - lock.height;
						lock.name = "tremendoushack";
						DisplayObjectContainer(btn).addChild(lock);
					}
					Util.listen(btn, MouseEvent.CLICK, onLevel);

					addChild(btn);
					_buttons.push(btn);
				}
			}
		}
		private function onAddedToStage(e:Event):void
		{
			if (e.target == this)
			{
				const prevWidth:Number = _goldParent.width;

				_gold.text = String(UserData.instance.credits);
				_goldParent.x -= (_goldParent.width - prevWidth);  // my lameness knows no bounds, except when it's calculating bounds
			}
		}
		public function unlockLevels(levels:uint):void
		{
			for (var i:uint = 0; i < levels; ++i)
			{
				var btn:GameButton = GameButton(_buttons[i]);
				btn.enabled = true;
				
				var lock:DisplayObject = btn.getChildAt(btn.numChildren - 1);
				if (lock.name == "tremendoushack")
				{
					btn.removeChild(lock);
				}
			}
		}
		private var _gold:ShadowTextField;
		private var _goldParent:Sprite;
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
			gold.text = String(UserData.instance.credits);
			_gold = gold;
			
			goldReportParent.addChild(gold);

			goldReportParent.x = width - goldReportParent.width;
			goldReportParent.y = height - goldReportParent.height;
			_goldParent = goldReportParent;

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
		private var _selection:uint = 0;
		private function onLevel(e:Event):void
		{
			_selection = parseInt(DisplayObject(e.currentTarget).name);
			dispatchEvent(new Event(Event.SELECT));	
		}
		public function get selection():uint
		{
			return _selection;
		}
	}
}