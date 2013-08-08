/**
 * 该代码以 BSD 开源许可协议进行授权
 * 作者：gs@bbxy.net 2013年8月
 */

package aslayouter
{
	import flash.display.MovieClip;
	
	public class ASLayouter
	{
		private var root:MovieClip = null;
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

		
		public function set layout(layout:String):void
		{
			_layout = layout;
			
			redraw();
		}
		

		private redraw()
		{
			
		}

	}
}

