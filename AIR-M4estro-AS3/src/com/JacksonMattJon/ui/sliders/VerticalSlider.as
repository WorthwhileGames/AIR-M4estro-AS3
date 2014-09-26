package com.JacksonMattJon.ui.sliders
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	*   Scroller of vertical lists
	*   @author Matt Moore
	*/
	public class VerticalSlider extends LinearSlider
	{
		/**
		*   Setup the sliderer
		*/
		public function VerticalSlider()
		{
			__sliderMinPos = int(this.sliderTab.y);
		}
		
		/**
		*	Resize the slider 
		*/
		protected override function resize(): void
		{
			this.sliderArea.height = __originalHeight;
			__sliderMaxPos = -int(__sliderMinPos + __originalHeight - this.sliderTab.height);
		}
		
		/**
		*   Scrolls the slider and the list to the top
		*/
		public override function reset(): void
		{
			super.reset();
			
			this.sliderTab.y = __sliderMinPos;
		}
        
		/**
		*   Ensures the slider is within its viable area
		*/
		protected override function sliderBoundsCheck(): void
		{
			// Clamp to [min, max]
			this.sliderTab.y = Math.min(Math.max(this.sliderTab.y, __sliderMaxPos), __sliderMinPos);
		}
		
		/**
		*   Callback for when the slider button is being held down
		*   @param ev Enter frame event
		*/
		protected override function onSliderButtonHeld( ev:Event ) :void
		{
			var current:int = getTimer();
			var elapsed:Number = current - __sliderLastTime;
			
			__sliderLastTime = current;
			__sliderElapsedTime += Math.max(50, elapsed); // cap lag
        }
		
		/**
		*   Callback for when the slider area is pressed
		*   @param ev Press event
		*/
		protected override function onSliderAreaPress(ev:Event): void
		{
			// Find the slider target location based on the mouse x
			__sliderTarget = this.mouseY + this.sliderTab.height / 2;

			// Let make sure our target is within bounds
			__sliderTarget = __sliderTarget < __sliderMaxPos ? 
				__sliderMaxPos : 
				( 
					__sliderTarget > __sliderMinPos ? 
					__sliderMinPos : 
					__sliderTarget 
				);
			
		    // Dispatch the change event and start tween event
            super.onSliderAreaPress(ev);
		}
		
		/**
		*	On enter frame function to tween slider
		*	@param ev Enter frame event
		*/
		protected override function onTweenSlider(ev:Event): void
		{
			if (this.dispatchDuringTween)
			{
				__sliderValue = (this.sliderTab.y - __sliderMinPos) / (__sliderMaxPos - __sliderMinPos);
			}
			
			super.onTweenSlider(ev);
			
			// If the distance to move is less than one,
			// then we'll stop the animation 
			if ( Math.abs(__sliderTarget - this.sliderTab.y) < 1 )
			{
				this.removeEventListener(Event.ENTER_FRAME, onTweenSlider);
				this.sliderTab.y = int(__sliderTarget);
			}
			else
			{
				this.sliderTab.y += (__sliderTarget - this.sliderTab.y) / 4;
				sliderBoundsCheck();
			}
		}
        
		/**
		*   Callback for when the slider is pressed
		*   @param ev Press event
		*/
		protected override function onSliderPress(ev:Event): void
		{
			super.onSliderPress(ev);
			
			this.sliderTab.startDrag(
				false,
				new Rectangle(
					this.sliderTab.x,
					__sliderMinPos,
					0,
					__sliderMaxPos - __sliderMinPos
				)
			);
		}
		
		/**
		*   Callback for when the slider is being dragged
		*   @param ev Enter frame event
		*/
		protected override function onSliderDragging(ev:Event): void
		{
            this.value = (this.sliderTab.y - __sliderMinPos) / (__sliderMaxPos - __sliderMinPos);
			
            super.onSliderDragging(ev);
		}
		
		/**
		*   Callback for when the user wheels the mouse
		*   @param ev Wheel event
		*/
		protected override function onMouseWheel(ev:MouseEvent): void
		{
			for (var obj:DisplayObject = ev.target as DisplayObject; obj != null; obj = obj.parent)
			{
				if (obj == this)
				{
					jumpToPos(this.sliderTab.y - ev.delta);
					return;
				}
			}
		}
		
		/**
		*	Jump to position
		*	@param	pos	position of sliderTab
		*/
		protected override function jumpToPos(pos:int):void 
		{
			this.sliderTab.y = pos;
			sliderBoundsCheck();
			this.value = (this.sliderTab.y - __sliderMinPos) / (__sliderMaxPos - __sliderMinPos);
			
			super.jumpToPos(pos);
		}
		
		/**
		*	Jump to value
		*	@param	pos	position of sliderTab
		*/
		public override function set value(value:Number):void 
		{
			super.value = value;
			this.sliderTab.y = (value * (__sliderMaxPos - __sliderMinPos)) + __sliderMinPos;
		}
	}
}