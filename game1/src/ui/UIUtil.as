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
	import gameData.VehiclePart;
	
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
			
			var labelField:ShadowTextField = new ShadowTextField(0, 0x00ff00, 1);
			AssetManager.instance.assignFont(labelField, AssetManager.FONT_RADIOSTARS, 14);
			labelField.text = label;
			labelField.embedFonts = true;
			
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
		static public function addCheckmark(item:GameListItem):DisplayObject
		{
			var check:DisplayObject = AssetManager.instance.checkmark();
			check.x = item.width - check.width/2 - 10;
			check.y = check.height/2 + 15;
			item.addChild(check);
			
			return check;
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
		static public function closeDialog(dialog:DisplayObject):void
		{
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
		static public function fadeIn(fader:DisplayObject):void
		{
			fader.alpha = 0;
			TweenLite.to(fader, 3, {alpha:1});
		}
		static public function removeThyself(thy:DisplayObject):void
		{
			if (thy.parent)
			{
				thy.parent.removeChild(thy);
			}
		}

		static private function formatLabel(txt:String, size:uint = 2):String
		{
			return "<font size='+" + size + "'><b>" + txt + "</b></font>";
		}
		static public function formatItemTooltip(part:VehiclePart, nameHeader:Boolean = true):String
		{
			const cost:uint = part.baseStats.cost;
			var costString:String = "";

			const owns:Boolean = UserData.instance.owns(part.id);
			const canAfford:Boolean = part.baseStats.cost <= UserData.instance.credits;
			costString = (canAfford || owns) ? (cost + " Credits") : ("<font color='#cc2222'>" + cost + " Credits</font>");
			if (owns)
			{
				costString += " <i>(Purchased)</i>";
			}

			var retval:String = nameHeader ? "Name: " : "";
			retval += formatLabel(part.name);
			if (part.subType)
			{
				retval += "<br>Class: " + formatLabel(part.subType, 0);
			}
			retval += "<br>Cost: <b>" + costString + "</b><br><br>";
			retval += "<font size='-1'>" + (part.description || "Details unavailable.") + "</font>";
			if (part.unlockDescription && part.unlockDescription.length)
			{
				retval += "<br><br><b>Progression:</b> <i>" + part.unlockDescription + "</i>";
			}
			return retval;
		}
	}
}