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
		
		public static const AUTO:String = "auto";
		public static const FULL:String = "full";
		
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
		 * 将百分比转换成像素
		 *
		 * @param String	带百分号的百分比数值，如 "20 %"，百分号可以省略，但不可以使用小数形式
		 * @param Number	属性值，返回的结果将以该属性值乘以百分比
		 * @return Number	计算得到的百分比
		 */
		private function percent2px(percent:String, total:Number):Number
		{
			var ratio:Number;
			
			ratio = new Number(percent.split("%").join());
			
			return total * ratio;
		}
		
		
		/**
		 * 将该布局下的子布局的单位转换成像素
		 * 子布局的长度和高度可以使用像素，百分比，AUTO 以及 FULL
		 * AUTO 模式下将自动设定子布局属性的值，使所有的子布局正好能够填充整个布局
		 * FULL 模式下，子布局的属性值将被设为最大，及填充整个布局
		 * 百分比模式下，会将百分比转换成像素
		 * 像素模式下不做任何处理
		 * 
		 * @param Object	布局对象
		 * @param String	布局对象的属性值名字，可以为 width 或 height
		 */
		private function calcLayout(layout:Object, prop:String)
		{
			var i:int;
			var usedValue:Number = 0;	/// 已经使用的宽度
			var autoCount:int = 0;
			var autoValue:Number = 0;
			
			var obj;
			
			if (layout.insts == undefined) {
				return;
			}

			for (i = 0; i < layout.insts.length; i++) {
				obj = layout.insts[i];
				
				/// width 的默认值是 AUTO
				if (obj[prop] == undefined) {
					obj[prop] = AUTO;
				}
				
				/// 将百分比换成像素；将 FULL 换成像素
				if (obj[prop].toString().indexOf("%") >= 0) {
					obj[prop] = percent2px(obj[prop], layout[prop]);
				}
				else if (obj[prop] == FULL) {
					obj[prop] = layout[prop];
				}

				/// 记录已经占用的宽度
				if (obj[prop] != AUTO) {
					usedValue += obj[prop];
				}
				else {
					autoCount++;
				}
			}
			
			/// 设定 AUTO 元素的大小
			if (autoCount > 0) {
				autoValue = (layout[prop] - usedValue) / autoCount;
				
				if (autoValue < 0) {
					autoValue = 0;
					trace("警告：在 " + layout.inst + " 的布局中，" + autoCount + " 个子布局的" + prop + " 属性的自动值小于 0");
				}
				
				for (i = 0; i < layout.insts.length; i++) {
					obj = layout.insts[i];
					
					if (obj[prop] == AUTO) {
						obj[prop] = autoValue;
					}
				}
			}
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
			
			calcLayout(layout, "width");
			calcLayout(layout, "height");
			
			for (i = 0; i < layout.insts.length; i++) {
				var obj:Object = layout.insts[i];
				var mc = obj.inst;
				
				mc.x = x;
				mc.y = y;
				
				
				mc.width = obj.width;
				mc.height = obj.height;
				
				trace(obj + " mc.width set to " + mc.width)
				
				x += mc.width;
			}
		}

	}
}

