/**
 * 该代码以 BSD 开源许可协议进行授权
 * 作者：gs@bbxy.net 2013年8月
 */

package aslayouter
{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	
	public class ASLayouter
	{
		private var _root:MovieClip = null;
		private var _layout:Object = null;
		
		/**
		 * 构造函数
		 */
		public function ASLayouter(root:MovieClip)
		{
			if (root == null) {
				throw("作为根的影片剪辑不能为空");
			}
			
			_root = root;
		}

		
		public function set layout(layout:Object):void
		{
			_layout = layout;
			
			redraw();
		}
		
		/**
		 * 重新绘制布局
		 */
		public function redraw()
		{
			redrawLayout(_layout)
		}
		
		
		private function redrawLayout(layout:Object)
		{
			var i:int;
			
			var x:int = 0, y:int = 0;
			
			for (i = 0; i < layout.insts.length; i++) {
				var obj:Object = layout.insts[i];
				var mc = obj.inst;
				
				mc.x = x;
				mc.y = y;
				
				if (obj.width != undefined) {
					mc.width = obj.width;
				}
				
				if (obj.height != undefined) {
					mc.height = obj.height;
				}
				
				x += mc.width;
			}
		}

	}
}

