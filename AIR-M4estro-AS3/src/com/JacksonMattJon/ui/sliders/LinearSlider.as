package com.JacksonMattJon.ui.sliders
{
	import com.JacksonMattJon.ui.UIControl;
	import com.JacksonMattJon.ui.buttons.PushButton;
	import com.JacksonMattJon.ui.buttons.PushButtonEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	*   Scroller of vertical lists
	*   @author Matt Moore
	*/
	public class LinearSlider extends UIControl
	{
		/** The highest position the slider may go to */
		protected var __sliderMinPos:int;
		
		/** The lowest position the slider may go to */
		protected var __sliderMaxPos:int;
		
		/** The target location to tween the slider to */
		protected var __sliderTarget:int;
		
        /** The value of the slider */
        protected var __sliderValue:Number;
        
		/** If the sliderer will slider to the bottom of the list when a list
		*   becomes larger than the area it is displayed in  */
		public var sliderNextOnViewFull:Boolean;
		
		/** the time at which slidering of the list started, occurs when the
		* user presses the up or down button */
		protected var __sliderLastTime:int;
		
		protected var __sliderElapsedTime:int;
		
		/** the position of the list when slidering started */
		protected var __sliderStartPos:Number;
		
		/** the area that defines how far the sliderTab moves that can also be
		* used to directly move to a spot in the list */
		public var sliderArea:PushButton;
		
		/** the tab that is dragged around to change the lists position */
		public var sliderTab:PushButton;
		
		/** Dispatch event every frame while the slider is animating */
		public var dispatchDuringTween:Boolean;
		
		/**
		*   Setup the sliderer
		*/
		public function LinearSlider()
		{
			assert(this.sliderArea != null, "No sliderArea");
			assert(this.sliderTab != null, "No sliderTab");
			
			this.sliderArea.addEventListener(PushButtonEvent.PRESS, onSliderAreaPress);
			this.sliderArea.addEventListener(PushButtonEvent.RELEASE, onSliderAreaRelease);
				
			this.sliderTab.addEventListener(PushButtonEvent.PRESS, onSliderPress);
			this.sliderTab.addEventListener(PushButtonEvent.RELEASE, onSliderRelease);
			this.sliderTab.addEventListener(PushButtonEvent.RELEASE_OUTSIDE, onSliderRelease);
            
			__sliderValue = 0;
            
			this.enabled = true;
		}
		
		/**
		*   Set the button's tint colors. The state clips must each have a
		*   baseShape child.
		*   @param upColor Color to tint the up clip with
		*   @param overColor Color to tint the over clip with
		*   @param downColor Color to tint the down clip with
		*   @param disabledColor Color to tint the disabled clip with
		*/
		public function tint(upColor:uint, overColor:uint, downColor:uint, disabledColor:uint): void
		{
			this.sliderArea.tint(upColor, overColor, downColor, disabledColor);
			this.sliderTab.tint(upColor, overColor, downColor, disabledColor);
		}
		
		/**
		*   Clear any tinting applied to the button. The state clips must each
		*   have a baseShape child.
		*/
		public function clearTint(): void
		{
			this.sliderArea.clearTint();
			this.sliderTab.clearTint();
		}
		
		/**
		*   Set if this sliderer should be enabled or not
		*   @param enabled If this list view should be enabled or not
		*/
		public override function set enabled(enabled:Boolean): void
		{
			super.enabled = enabled;
			
			this.sliderTab.enabled = enabled;
			this.sliderArea.enabled = enabled;
			
			if ( enabled )
			{
				this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
			else
			{
				this.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
		}
		
		/**
		*   Scrolls the slider and the list to the top
		*/
		public function reset(): void
		{
            __sliderValue = 0;
		}
        
        /**
        *   Getter for the value of the slider
        */
        public function get value(): Number
        {
            return __sliderValue;
        }
        
        /**
        *   Setter for the value of the slider
        */
        public function set value(value:Number): void
        {
			// Clamp to [0:1]
			if (value > 1)
			{
				value = 1;
			}
			else if (value < 0)
			{
				value = 0;
			}
			
			__sliderValue = value;
			dispatchEvent(new SliderEvent(SliderEvent.ON_CHANGE));
        }
        
		/**
		*   Ensures the slider is within its viable area
		*/
		protected function sliderBoundsCheck(): void
		{
		}
		
		/**
		*   Enables or disable the sliderer when the list has changed its size
		*   in relation to its viewable size. Also handles automatic slidering
		*   of the list.
		*   @param ev Size change event
		*/
		protected function onListSizeChange(ev:Event): void
		{
		}
		
		/**
		*   Callback for when any slider button is released
		*   @param ev Release event
		*/
		private function onSliderButtonRelease(ev:Event): void
		{
			this.removeEventListener ( Event.ENTER_FRAME, onSliderButtonHeld );
		}
		
		/**
		*   Callback for when the slider button is being held down
		*   @param ev Enter frame event
		*/
		protected function onSliderButtonHeld(ev:Event): void
		{
		}
		
		/**
		*   Callback for when the slider area is pressed
		*   @param ev Press event
		*/
		protected function onSliderAreaPress(ev:Event): void
		{
			// Start the tween
			this.addEventListener( Event.ENTER_FRAME, onTweenSlider);
            
			// Calculate the slider precentage
			if (!this.dispatchDuringTween)
			{
				__sliderValue = (__sliderTarget - __sliderMinPos) / (__sliderMaxPos - __sliderMinPos);
			}
			
			dispatchEvent(new SliderEvent(SliderEvent.ON_CHANGE));
		}
		
		/**
		*	On enter frame function to tween slider
		*	@param ev Enter frame event
		*/
		protected function onTweenSlider(ev:Event): void
		{
			if ( dispatchDuringTween )
			{
				dispatchEvent(new SliderEvent(SliderEvent.ON_CHANGE));
			}
		}
		
		/**
		*   Callback for when the slider is pressed
		*   @param ev Press event
		*/
		protected function onSliderPress(ev:Event): void
		{
            this.addEventListener(Event.ENTER_FRAME, onSliderDragging);
		}
		
		/**
		*   Callback for when the slider is being dragged
		*   @param ev Enter frame event
		*/
		protected function onSliderDragging(ev:Event): void
		{
            dispatchEvent(new SliderEvent(SliderEvent.ON_CHANGE));
		}
		
		/**
		*   Callback for when the slider is released
		*   @param ev Release event
		*/
		protected function onSliderAreaRelease(ev:Event): void
		{
			dispatchEvent(new SliderEvent(SliderEvent.ON_RELEASE));
		}
		
		/**
		*   Callback for when the slider is released
		*   @param ev Release event
		*/
		protected function onSliderRelease(ev:Event): void
		{
			this.sliderTab.stopDrag();
			this.removeEventListener(Event.ENTER_FRAME, onSliderDragging);
		}
		
		/**
		*   Callback for when the user wheels the mouse
		*   @param ev Wheel event
		*/
		protected function onMouseWheel(ev:MouseEvent): void
		{
		}
		
		/**
		*   Jump the view to show a specified position at the top, if possible.
		*   Otherwise, get as close as we can.
		*   @param pos The position to move the sliderTab to
		*/
		protected function jumpToPos(pos:int): void
		{
			dispatchEvent(new SliderEvent(SliderEvent.ON_CHANGE));
		}
		
		/**
		*   Destroy the sliderer. Don't use it after this.
		*/
		public override function destroy() : void
		{
			this.enabled = false;
			
			this.sliderTab.destroy();
			this.sliderArea.destroy();
		}
	}
}