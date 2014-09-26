package com.JacksonMattJon.ui.sliders
{
	import flash.events.Event;
	
	/**
	*   Event indicuation the user has confirmed dialog
	*/
	public class SliderEvent extends Event
	{	
		/** Type of event */
		public static const ON_CHANGE:String = "onChange";
		public static const ON_RELEASE:String = "onRelease";
		
		/**
		*   Make the dialog
		*/
		public function SliderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}