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
	
	import karnold.utils.Util;
	import karnold.ui.ShadowTextField;

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
	}
}