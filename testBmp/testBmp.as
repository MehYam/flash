package
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class testBmp extends Sprite
	{
		private var _xml:XML = null;
		public function testBmp()
		{
			var loader:URLLoader = new URLLoader;
			
			loader.load(new URLRequest("tileset.xml"));
			loader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			
			addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
			levelXML();
		}
		
		private function xmlLoaded(e:Event):void
		{
			const loader:URLLoader = e.target as URLLoader;
			if (loader)
			{
				_xml = new XML(loader.data);
			}
			
			const imgLoader:Loader = new Loader();
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded, false, 0, true);
			imgLoader.load(new URLRequest("tileset.png"));
		}
		
		private var _imgData:BitmapData;
		private function imgLoaded(e:Event):void
		{
			_imgData = e.target.content.bitmapData;
			
			add("brick");
			add("pengoWait");
			add("pengoWalkDown");
			add("pengoWalkUp");
			add("pengoWalkLeft");
			add("pengoWalkRight");
			add("enemyWalkLeft");
			add("enemyWalkRight");
			add("enemyWalkDown");
			add("enemyWalkUp");
			add("enemySmashUp");
			add("enemySmashDown");
			add("enemySmashLeft");
			add("enemySmashRight");
			add("enemyCrush");
			
		}
		private function onKeyUp(e:KeyboardEvent):void
		{
			
			switch(e.keyCode) {
				case 37:
					Animator(getChildAt(0)).node = _xml.tile.(@name=="enemySmashLeft")[0];
					break;
				case 38:
					Animator(getChildAt(0)).node = _xml.tile.(@name=="enemySmashUp")[0];
					break;
				case 39:
					Animator(getChildAt(0)).node = _xml.tile.(@name=="enemySmashRight")[0];
					break;
				case 40:
					Animator(getChildAt(0)).node = _xml.tile.(@name=="enemySmashDown")[0];
					break;
			}
		}
		
		private var _x:int = 10;
		private function add(which:String):void
		{
			var animator:Animator = new Animator(_imgData, _xml.tile.(@name==which)[0]);
			animator.x = _x;
			animator.y = _x;
			
			_x += 24;

			this.addChild(animator);
		}
		private var _frame:uint = 0;
		private function onFrame(e:Event):void
		{
			++_frame;

			for (var i:uint = 0; i < this.numChildren; ++i)
			{
				Animator(this.getChildAt(i)).onFrame(_frame);
			}
		}
		
		static private const _levelXML:XML =
			<levels>
				<level>
					<path row="14" col="0" rd="-1" len="15"/>
					<path row="10" col="1" cd="1" len="2"/>
					<path row="11" col="2" rd="1" len="4"/>
					<path row="14" col="3" cd="1" len="8"/>
					<path row="13" col="10" rd="-1" len="2"/>
					<path row="12" col="9" cd="-1" len="2"/>
					<path row="11" col="8" rd="-1" len="2"/>
					<path row="10" col="9" cd="1" len="2"/>
					<path row="9" col="10" rd="-1" len="2"/>
					<path row="8" col="11" cd="1" len="2"/>
					<path row="9" col="12" rd="1" len="6"/>
					<path row="7" col="12" rd="-1" len="8"/>
					<path row="7" col="12" rd="-1" len="4"/>
					<path row="13" col="4" rd="-1" len="2"/>
					<path row="12" col="5" cd="1" len="2"/>
					<path row="11" col="6" rd="-1" len="4"/>
					<path row="8" col="7" cd="1" len="2"/>
					<path row="7" col="8" rd="-1" len="2"/>
					<path row="6" col="7" cd="-1" len="2"/>
					<path row="10" col="5" cd="-1" len="2"/>
					<path row="9" col="4" rd="-1" len="4"/>
					<path row="6" col="3" cd="-1" len="2"/>
					<path row="5" col="2" rd="-1" len="2"/>
					<path row="4" col="3" cd="1" len="6"/>
					<path row="3" col="8" rd="-1" len="2"/>
					<path row="2" col="9" cd="1" len="2"/>
					<path row="1" col="10" rd="-1" len="2"/>
					<path row="0" col="9" cd="-1" len="4"/>
					<path row="1" col="6" rd="1" len="2"/>
					<path row="2" col="5" cd="-1" len="4"/>
					<path row="1" col="2" rd="-1" len="2"/>
					<path row="0" col="3" cd="1" len="2"/>
					<path row="9" col="2" rd="-1" len="2"/>
					<path row="7" col="10" rd="-1" len="4"/>
				</level>
			</levels>;
		
		private function levelXML():void
		{
			trace("<levels>");
			for each (var level:XML in _levelXML.level)
			{
				trace("<level><paths>");
				var str:String = "";
				for each (var path:XML in level.path)
				{
					if (str.length)
					{
						str += ";";
					}
					str += path.@row + "," + path.@col + "," + int(path.@rd) + "," + int(path.@cd) + "," + int(path.@len);
				}
				trace(str);
				trace("</paths></level>");
			}
			trace("</levels>");
		}
	}
}
