package com.cloudkid.peep.trashstash.ui
{
	import com.cloudkid.ui.UIControl;
	
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	
	public class GamePanel extends UIControl
	{
		
		public var toss:MovieClip;
		public var chirp:MovieClip;
		public var raccoon:MovieClip;
		public var slot1:MovieClip;
		public var slot2:MovieClip;
		public var slot3:MovieClip;
		public var slot4:MovieClip;
		public var obj1:MovieClip;
		public var obj2:MovieClip;
		public var obj3:MovieClip;
		public var obj4:MovieClip;
		public var obj5:MovieClip;
		public var obj6:MovieClip;
		public var obj7:MovieClip;
		public var obj8:MovieClip;
		public var obj9:MovieClip;
		public var obj10:MovieClip;
		
		
		
		public function GamePanel()
		{
			super();
		}
		public function init():void
		{
			toss.stop();
			chirp.stop();
			raccoon.stop();
			
			slot1.stop();
			slot2.stop();
			slot3.stop();
			slot4.stop();
			slot1.visible = false;
			slot2.visible = false;
			slot3.visible = false;
			slot4.visible = false;
			slot1.mouseChildren = false;
			slot2.mouseChildren = false;
			slot3.mouseChildren = false;
			slot4.mouseChildren = false;
			
			obj1.stop();
			obj2.stop();
			obj3.stop();
			obj4.stop();
			obj5.stop();
			obj6.stop();
			obj7.stop();
			obj8.stop();
			obj9.stop();
			obj10.stop();
			obj1.visible = false;
			obj2.visible = false;
			obj3.visible = false;
			obj4.visible = false;
			obj5.visible = false;
			obj6.visible = false;
			obj7.visible = false;
			obj8.visible = false;
			obj9.visible = false;
			obj10.visible = false;
			
			obj1.mouseChildren = false;
			obj2.mouseChildren = false;
			obj3.mouseChildren = false;
			obj4.mouseChildren = false;
			obj5.mouseChildren = false;
			obj6.mouseChildren = false;
			obj7.mouseChildren = false;
			obj8.mouseChildren = false;
			obj9.mouseChildren = false;
			obj10.mouseChildren = false;
			
			toss.fly1.stop();
			toss.fly2.stop();
			toss.fly3.stop();
			toss.fly4.stop();
			toss.fly5.stop();
			toss.fly6.stop();
			toss.fly7.stop();
			toss.fly8.stop();
			toss.fly9.stop();
			toss.fly10.stop();
			toss.mouseEnabled = false;

		}
	}
}