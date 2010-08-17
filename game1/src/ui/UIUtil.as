package ui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	import gameData.UserData;
	import gameData.VehiclePartData;
	
	import karnold.ui.ShadowTextField;
	import karnold.utils.Util;

	public class UIUtil
	{
		public function UIUtil(){ throw "don't"; }
		
		static public function addGroupBox(parent:DisplayObjectContainer, label:String, locX:Number, locY:Number, width:Number, height:Number):DisplayObject
		{
			var skin:DisplayObject = AssetManager.instance.innerFace();
			skin.width =   width;
			skin.height =  height;
			
			skin.x = locX;
			skin.y = locY;
			
			parent.addChild(skin);
			
			var tf:TextFormat = new TextFormat("Radio Stars", 14);
			var labelField:ShadowTextField = new ShadowTextField(tf, 0, 0x00ff00, 1);
			labelField.text = label;
			
			labelField.x = skin.x + 3;
			labelField.y = skin.y;
			
			parent.addChild(labelField);
			
			return skin;
		}
		static public function createMysteryGameListItem(size:Number):DisplayObject
		{
			var question:DisplayObject = AssetManager.instance.question();
			question.scaleX = 1.3;
			question.scaleY = 1.3;
			
			var item:GameListItem = new GameListItem(question, size, size);
			var lock:DisplayObject = AssetManager.instance.lock();
			lock.x = item.width - 20;
			lock.y = item.height - 20;
			item.addChild(lock);
			
			item.mouseChildren = false;
			item.mouseEnabled = false;
			return item;
		}
		static public function addCheckmark(item:GameListItem):void
		{
			var check:DisplayObject = AssetManager.instance.checkmark();
			check.x = item.width - check.width/2 - 10;
			check.y = check.height/2 + 15;
			item.addChild(check);
		}
		static public var s_tweenInDialogArg:Object;
		static public function openDialog(parent:DisplayObjectContainer, dialog:DisplayObject):void
		{
			if (!s_tweenInDialogArg)
			{
				s_tweenInDialogArg = {x: 0, y: 0, ease:Back.easeOut};
			}

			Util.centerChild(dialog, parent);
			
			s_tweenInDialogArg.x = dialog.x;
			s_tweenInDialogArg.y = dialog.y;
			TweenLite.to(dialog, 0.5, s_tweenInDialogArg);
			
			dialog.y = -dialog.height;
			
			parent.addChild(dialog);
		}
		
		static public var s_tweenOutDialogArg:Object;
		static public function closeDialog(parent:DisplayObjectContainer, dialog:DisplayObject):void
		{
			parent.mouseChildren = true;

			if (!s_tweenOutDialogArg)
			{
				s_tweenOutDialogArg = {x: 0, y: 0, ease:Back.easeIn, onComplete:tweenOut_removeThyself, onCompleteParams:[]};
			}
			
			s_tweenOutDialogArg.x = dialog.x;
			s_tweenOutDialogArg.y = -dialog.height;
			s_tweenOutDialogArg.onCompleteParams[0] = dialog;
			
			TweenLite.to(dialog, 0.5, s_tweenOutDialogArg);
		}
		static private function tweenOut_removeThyself(thy:DisplayObject):void
		{
			if (thy.parent)
			{
				// release the last remaining references to the dialog
				s_tweenOutDialogArg.onCompleteParams.length = 0;
				
				thy.parent.removeChild(thy);
			}
		}

		static public var s_fadeDialogArg:Object;
		static public function fadeAndRemove(removee:DisplayObject):void
		{
			TweenLite.to(removee, 3, {alpha:0, onComplete:removeThyself, onCompleteParams:[removee]});
		}
		static public function removeThyself(thy:DisplayObject):void
		{
			if (thy.parent)
			{
				thy.parent.removeChild(thy);
			}
		}

		static public function formatItemTooltip(part:VehiclePartData, nameHeader:Boolean = true):String
		{
			const cost:uint = part.baseStats.cost;
			var costString:String = "";
			if (part.purchased)
			{
				costString = "<i>Purchased</i>";
			}
			else
			{
				const canAfford:Boolean = part.baseStats.cost <= UserData.instance.credits;
				costString = canAfford ? (cost + " Credits") : ("<font color='#cc2222'>" + cost + " Credits</font>");  
			}

			var retval:String = nameHeader ? "Name: " : ""; 
			retval += "<font size='+2'><b>" + part.name + "</b></font><br>Cost: <b>" + costString + "</b><br><br>";
			retval += "This ship is a pretty cool ship because as far as ship goes, it ship ships shipsss pretty cool ship ship.  ship.";
			return retval;
		}
	}
}