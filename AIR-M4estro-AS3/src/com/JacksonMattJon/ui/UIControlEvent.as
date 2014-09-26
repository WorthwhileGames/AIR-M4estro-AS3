package com.JacksonMattJon.ui 
{
	import flash.events.Event;
	
	/**
	*   An event class that encompasses all UIControls
	*   @author Jonathan Ross, Jackson Dunstan
	*/
	public class UIControlEvent extends Event 
	{
		/** When the tooltip should be enabled */
		public static const ENABLE_TOOLTIP:String = "onTooltipEnable";
		
		/** When the tooltip should be disabled */
		public static const DISABLE_TOOLTIP:String = "onTooltipDisable";
		
		/** When clicking off the control is now hiding it */
		public static const CLICK_OFF_HIDING:String = "onClickOffHiding";
		
		/**
		*   Make the event
		*   @param type @see flash.events.Event
		*   @param bubbles @see flash.events.Event
		*   @param cancelable @see flash.events.Event
		*/
		public function UIControlEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
