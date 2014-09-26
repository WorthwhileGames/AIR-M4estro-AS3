package com.JacksonMattJon.ui.buttons
{
	import flash.events.Event;
	
	/**
	*   An event pertaining to a PushButton
	*   @author Jackson Dunstan
	*/
	public class PushButtonEvent extends Event
	{
		/** When a PushButton is pressed */
		public static const PRESS:String = "onPress";
		
		/** When a PushButton is released */
		public static const RELEASE:String = "onRelease";
		
		/** When a PushButton is double clicked */
		public static const DOUBLE_CLICK:String = "onDoubleClick";
		
		/** When a PushButton is rolled over */
		public static const ROLL_OVER:String = "onRollOver";
		
		/** When a PushButton is rolled out */
		public static const ROLL_OUT:String = "onRollOut";
		
		/** When a PushButton is released outside */
		public static const RELEASE_OUTSIDE:String = "onReleaseOutside";
		
		/** When a PushButton is dragged over */
		public static const DRAG_OVER:String = "onDragOver";
		
		/** When a PushButton is dragged out */
		public static const DRAG_OUT:String = "onDragOut";
		
		/** When a PushButton's label text changes */
		public static const LABEL_TEXT_CHANGED:String = "onLabelTextChanged";
		
		/**
		*   Make the event
		*   @param type @see flash.events.Event
		*   @param bubbles @see flash.events.Event
		*   @param cancelable @see flash.events.Event
		*/
		public function PushButtonEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
