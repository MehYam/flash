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
			lock.x = item.width - 15;
			lock.y = item.height - 15;
			item.addChild(lock);
			
			item.mouseChildren = false;
			item.mouseEnabled = false;
			return item;
		}
		static public function addCheckmark(item:GameListItem):void
		{
			var check:DisplayObject = AssetManager.instance.checkmark();
			check.x = item.width - check.width/2;
			check.y = check.height/2 + 5;
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
				s_tweenOutDialogArg = {x: 0, y: 0, ease:Back.easeIn, onComplete:removeThyself, onCompleteParams:[]};
			}
			
			s_tweenOutDialogArg.x = dialog.x;
			s_tweenOutDialogArg.y = -dialog.height;
			s_tweenOutDialogArg.onCompleteParams[0] = dialog;
			
			TweenLite.to(dialog, 0.5, s_tweenOutDialogArg);
		}
		
		static public function removeThyself(thy:DisplayObject):void
		{
			if (thy.parent)
			{
				thy.parent.removeChild(thy);
			}
		}
		
		static public function formatItemTooltip(name:String, cost:uint, description:String):String
		{
			var retval:String = "Name: <b>" + name + "</b><br>Cost: <b>" + cost + "</b><br><br>";
			retval += "This ship is a pretty cool ship because as far as ship goes, it ship ships shipsss pretty cool ship ship.  ship.";
			return retval;
		}
	}
}