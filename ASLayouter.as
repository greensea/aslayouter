/**
 * 该代码以 BSD 开源许可协议进行授权
 * 作者：gs@bbxy.net 2013年8月
 */

package aslayouter
{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	public class ASLayouter
	{
		//private var _root:MovieClip = null;
		private var _layout:Object = null;
		
		public static const AUTO:String = "auto";
		public static const FULL:String = "full";
		public static const INHERIT:String = "inherit";
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _w:Number = 0;
		private var _h:Number = 0;
		
		/**
		 * 构造函数
		 */
		public function ASLayouter()
		{
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
			
			ratio = new Number(percent.split("%").join(""));
			
			ratio /= 100;
			
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
			var propName:String = "";
			var usedValue:Number = 0;	/// 已经使用的宽度
			var autoCount:int = 0;
			var autoValue:Number = 0;
			
			var obj;
			
			if (layout.insts == undefined) {
				return;
			}
			
			
			var propValue:Number = 0;
			if (prop == "width") {
				propValue = _w;
				propName = "__width";
			}
			else if (prop == "height") {
				propValue = _h;
				propName = "__height"
			}
			else {
				throw(propName + " 属性未定义");
				return;
			}
			
			for (i = 0; i < layout.insts.length; i++) {
				obj = layout.insts[i];
				
				/// 默认值是 INHERIT，即不改变原始值
				if (obj[prop] == undefined) {
					obj[prop] = INHERIT;
				}
				
				/// 将百分比换成像素；将 FULL 换成像素
				if (obj[prop].toString().indexOf("%") >= 0) {
					obj[propName] = percent2px(obj[prop], propValue);
				}
				else if (obj[prop] == FULL) {
					obj[propName] = propValue;
				}
				else if (obj[prop] == INHERIT) {
					obj[propName] = obj.inst[prop];
				}
				else {
					obj[propName] = obj[prop];
				}
				
				/// 记录已经占用的数量
				if (obj[prop] != AUTO) {
					usedValue += obj[propName];
				}
				else {
					autoCount++;
				}
			}
			
			/// 设定 AUTO 元素的大小
			if (autoCount > 0) {
				autoValue = (propValue - usedValue) / autoCount;
				
				if (autoValue <= 0) {
					autoValue = 0;
					trace("警告：在 " + layout.name + " 的布局中，" + autoCount + " 个子布局的" + prop + " 属性的自动值小于等于 0");
				}
				
				for (i = 0; i < layout.insts.length; i++) {
					obj = layout.insts[i];
					
					if (obj[prop] == AUTO) {
						obj[propName] = autoValue;
					}
				}
			}
		}
		
		
		/**
		 * 重新绘制布局
		 */
		public function redraw()
		{
			var i:int;
			
			if (_layout == null) {
				return;
			}
			
			redrawLayout();
		}
		

		/**
		 * 绘制子布局的 Layouter
		 * 
		 * 1. 重新计算子布局的长度和高度，以及坐标
		 * 2. 为子布局创建新的 ASLayouter()
		 */
		private function redrawLayout()
		{
			var i:int;
			var layout:Object = _layout;
			
			var x:int = 0, y:int = 0;
			var lineMaxY:Number = 0;	/// 一行中的最大 Y 值
			
			if (layout.name == "root") {
				trace("");
			}
			
			calcLayout(layout, "width");
			calcLayout(layout, "height");
			
			trace("layout <" + layout.name + ">: width=" + layout.__width + ", height=" + layout.__height);
			
			layout.inst.width = layout.__width;
			layout.inst.height = layout.__height;
			layout.inst.x = _x;
			layout.inst.y = _y;
			
			for (i = 0; i < layout.insts.length; i++) {
				var obj:Object = layout.insts[i];
				var l:ASLayouter = new ASLayouter();
				
				/// 换行判断
				if (layout.__width - x - obj.__width < 0) {
					y += lineMaxY;
					x = 0;
					lineMaxY = 0;
				}


				/// 设置坐标
				var p:Point;
				
				if (layout.inst == null) {
					p = new Point(x, y);
				}
				else {
					p = layout.inst.globalToLocal(new Point(x + _x, y + _y));
				}
				l.x = p.x;
				l.y = p.y;
				
				trace("layout pos <" + obj.name + ">: x=" + p.x + ", y=" + p.y);
				
				
				/// 设置大小
				l.width = obj.__width;
				l.height = obj.__height;
				
				
				/// 设置布局
				l.layout = obj;
				
				
				/// 计算下一个元素的坐标
				x += obj.__width;
				
				if (lineMaxY < obj.__height) {
					lineMaxY = obj.__height;
				}
			}
		}

		
		
		/// 下面都是无聊的属性设置的函数
		
		public function set layout(layout:Object):void
		{
			
			var i:int;
			
			if (_layout != null) {
				/// FIXME: 销毁现有的对象
			}
			
			_layout = layout;
			
			
			/// 创建子布局的类
			
			if (!_layout.insts) {
				_layout.insts = new Array();
			}
			
			redraw();
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(vx:Number):void
		{
			_x = vx;
			redraw();
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(vy:Number):void
		{
			_y = vy;	
			redraw();
		}

		public function get width():Number
		{
			return _w;
		}
		
		public function set width(vw:Number):void
		{
			_w = vw;	
			redraw();
		}
		
		public function get height():Number
		{
			return _h;
		}
		
		public function set height(vh:Number):void
		{
			_h = vh;
			redraw();
		}
	}
}

