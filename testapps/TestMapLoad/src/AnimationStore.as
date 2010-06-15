package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	public class AnimationStore
	{
		private var _animations:Dictionary = new Dictionary(true);
		private static function storeTimelinedMovieClipsFunctor(self:Object, dobj:DisplayObject):void
		{
			var mc:MovieClip = dobj as MovieClip;
			if (mc && mc.totalFrames > 1) {
				self.animations[mc] = true;
			}
		}

		private static function recurseDisplayObjects(parent:DisplayObject, functor:Object):void
		{
			functor.onObject(functor, parent);
			
			var container:DisplayObjectContainer = parent as DisplayObjectContainer;
			if (container && container.numChildren)
			{
				for (var i:int = 0; i < container.numChildren; ++i)
				{
					recurseDisplayObjects(container.getChildAt(i), functor);
				}
			}
		}

		public function AnimationStore(parent:DisplayObject)
		{
			//
			// Store a weak reference to all MovieClips that have a timeline 
			var functor:Object =
			{
				animations: _animations,
				onObject:   storeTimelinedMovieClipsFunctor
			};
			recurseDisplayObjects(parent, functor);
		}
		public function playAll():void
		{
			for (var mc:Object in _animations) {
				MovieClip(mc).play();
			}
		}
		public function stopAll():void
		{
			for (var mc:Object in _animations) {
				MovieClip(mc).stop();
			}
		}
		public function report():void
		{
			var hash:Dictionary = new Dictionary(true);
			for (var mc:Object in _animations) {
				var type:Class = mc["constructor"];
				if (hash[type]) {
					hash[type]++;
				}
				else {
					hash[type] = 1;
				}
			}
			
			for (var t:Object in hash) {
				trace(hash[t] + " instance(s) of " + String(t).split("[class ")[1].split("]")[0]); 
			}
		}
	}
}