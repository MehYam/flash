package ui.dialogs
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	import gameData.UserData;
	
	import karnold.ui.ShadowTextField;
	import karnold.utils.ToolTipMgr;
	import karnold.utils.Util;
	
	import scripts.TankActor;
	import ui.GameButton;
	import ui.GlobalUIEvent;
	import ui.UIUtil;
	
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
		
		static private const LOCK_NAME:String = "lock";
		static private const CHECK_NAME:String = "check";
		static private const ICON_NAME:String = "icon";
		static private const ICON_DROP:Array = [ new DropShadowFilter(1, 45, 0xffffff) ];
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
					btn = GameButton.create("Level " + (level + 1), false, 18, 1);
					btn.name = String(level);
					btn.width = 95;
					btn.y = TOP_MARGIN + (r * (btn.height + 2));
					btn.x = 10 + c * (btn.width + 2);
					
					if (level > UserData.instance.levelsBeaten)
					{
						btn.enabled = false;
						var lock:DisplayObject = AssetManager.instance.lock();
						lock.scaleX = 0.7;
						lock.scaleY = 0.7;
						lock.x = btn.width - lock.width;
						lock.y = btn.height - lock.height;
						lock.name = LOCK_NAME;
						DisplayObjectContainer(btn).addChild(lock);
					}
					else if (level <= UserData.instance.levelsBeaten)
					{
						addLevelButtonIcon(btn, (level % 2) != 0);
						if (level < UserData.instance.levelsBeaten)
						{
							addLevelButtonCheck(btn);
						}
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
				_goldParent.x -= (_goldParent.width - prevWidth);  // haxorZ
				
				updateCurrentVehicles();
				enabled = true;
			}
		}
		public function updateCurrentVehicles():void
		{
			Util.removeAllChildren(_vehicleParent);
			var plane:DisplayObject = ActorAssetManager.createShipRaw(UserData.instance.currentPlane);
			var bounds:Rectangle = plane.getBounds(plane);
			plane.x = -bounds.left;
			plane.scaleX = plane.scaleY = 0.75;
			_vehicleParent.addChild(plane);
			
			var tank:DisplayObject = TankActor.createTankActor(UserData.instance.currentHull, UserData.instance.currentTurret, null).displayObject;
			bounds = tank.getBounds(tank);
			tank.x = -bounds.left + plane.width + 20;
			
			tank.scaleX = tank.scaleY = 0.75;
			_vehicleParent.addChild(tank);
		}
		static private function addLevelButtonIcon(btn:DisplayObjectContainer, tank:Boolean):void
		{
			var icon:DisplayObject = tank ? AssetManager.instance.tankIcon() : AssetManager.instance.planeIcon();
			icon.name = ICON_NAME;
			icon.scaleX = .7;
			icon.scaleY = .7;
			icon.x = 80;
			icon.y = btn.height /2 - 2;
			icon.filters = ICON_DROP;
			btn.addChild(icon);
		}
		static private function addLevelButtonCheck(btn:DisplayObjectContainer):void
		{
			Util.ASSERT(!btn.getChildByName(CHECK_NAME));
			
			var check:DisplayObject = AssetManager.instance.checkmark();
			check.scaleX = check.scaleY = 0.5;
			check.x = 5;
			check.y = 5;
			btn.addChild(check);
			
//			ToolTipMgr.instance.addToolTip(btn, "Here's a completed level");
		}
		public function unlockLevels(levels:uint):void
		{
			for (var i:uint = 0; i < levels; ++i)
			{
				var btn:GameButton = GameButton(_buttons[i]);
				btn.enabled = true;
				
				var lock:DisplayObject = btn.getChildByName(LOCK_NAME);
				if (lock)
				{
					btn.removeChild(lock);
				}
				if (i == (levels-2))
				{
					var check:DisplayObject = btn.getChildByName(CHECK_NAME);
					if (!check)
					{
						addLevelButtonCheck(btn);
					}
				}
				var icon:DisplayObject = btn.getChildByName(ICON_NAME);
				if (!icon)
				{
					addLevelButtonIcon(btn, (i % 2) != 0);
				}
			}
		}
		private var _gold:ShadowTextField;
		private var _goldParent:Sprite;
		private var _vehicleParent:Sprite;
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

			_vehicleParent = new Sprite;
			_vehicleParent.x = hangar.x + hangar.width + 5;
			_vehicleParent.y = (garage.y + garage.height + hangar.y)/2;
			addChild(_vehicleParent);

			var goldReportParent:Sprite = new Sprite;

			var goldReport:ShadowTextField = new ShadowTextField(0xffffff, 0x00, 1);
			AssetManager.instance.assignFont(goldReport, AssetManager.FONT_COMPUTER, 24);
			goldReport.text = "Credits:";
			goldReport.embedFonts = true;
			
			goldReportParent.addChild(goldReport);
			
			var gold:ShadowTextField = new ShadowTextField(Consts.CREDIT_FIELD_COLOR, 0, 1);
			AssetManager.instance.assignFont(gold, AssetManager.FONT_ROBOT, 24); 
			gold.y = goldReport.y - 2;
			gold.x = goldReport.x + goldReport.width + 2;
			gold.text = String(UserData.instance.credits);
			gold.embedFonts = true;
			_gold = gold;
			
			goldReportParent.addChild(gold);

			goldReportParent.x = width - goldReportParent.width;
			goldReportParent.y = hangar.y;
			_goldParent = goldReportParent;

			addChild(goldReportParent);
			
			var quit:GameButton = GameButton.create("Quit", true, 20, 1);
			quit.x = width - quit.width;
			quit.y = garage.y;
			
			addChild(quit);
			Util.listen(quit, MouseEvent.CLICK, onQuit);
		}
		private function onPlaneHangar(e:Event):void
		{
			openDialog(new UpgradePlaneDialog);
		}
		private function onTankGarage(e:Event):void
		{
			openDialog(new UpgradeTankDialog);
		}
		private function openDialog(dlg:DisplayObject):void
		{
			enabled = false;
			UIUtil.openDialog(parent, dlg);
			attachDialogListeners(dlg);
		}
		private function onPurchase(e:GlobalUIEvent):void
		{
			// because HACK the dialog replaces itself :(
			attachDialogListeners(EventDispatcher(e.arg));
		}
		private function attachDialogListeners(dlg:EventDispatcher):void
		{
			Util.listen(dlg, Event.COMPLETE, onDialogComplete);
			Util.listen(dlg, GlobalUIEvent.PURCHASE_MADE, onPurchase);
		}
		private function onDialogComplete(e:Event):void
		{
			enabled = true;
			
			_gold.text = String(UserData.instance.credits);
			updateCurrentVehicles();
		}
		private var _selection:uint = 0;
		private function onLevel(e:Event):void
		{
			enabled = false;

			_selection = parseInt(DisplayObject(e.currentTarget).name);
			dispatchEvent(new Event(Event.SELECT));	
		}
		private function onQuit(e:Event):void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		public function get selection():uint
		{
			return _selection;
		}
	}
}