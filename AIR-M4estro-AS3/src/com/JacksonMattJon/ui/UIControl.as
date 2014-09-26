package com.JacksonMattJon.ui
{
	import com.m4estro.vc.BaseMovieClip;
	
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	*   Base class of all UI controls
	*   @author Jackson Dunstan, Matt Moore
	* 
	* 	@version 1.00
	* 	History
	* 	v1.00 - 10/14/2008 - BH - Added version number.
	*	v1.01 - 10/22/2008 - MM - Added dynamic scaling for scrollers/list
	* 	v1.02 - 12/11/2008 - MM - Abstracted resize method to all UI
	* 	v1.03 - 12/23/2008 - MM - Added minimum height/width to resize
	*	v1.04 - 04/28/2009 - MM - Fixed Menu Popup resizing problems
	*   v1.05 - 05/12/2009 - MM - Added truncate method to PushButton, Selectable Button
	*   v1.05 - 05/12/2009 - JD - Fixed tooltip crashes
	*   v1.07 - 05/12/2009 - ML - updated destroy function
	*   v1.08 - 07/07/2009 - MM - Provide playAnimations static var to kill UI animations
	*/
	public class UIControl extends BaseMovieClip
	{
		/** Version of the UI Lib */
		public static const VERSION:Number = 1.08;
		
		/** The amount of time in milliseconds to wait to dispatch the tooptip event */
		public static var TOOLTIP_DISPATCH_TIME:int = 1000;
		
		/** Original scale of this clip in the X*/
		protected var __originalScaleX:Number;
		
		/** Original scale of this clip in the Y */
		protected var __originalScaleY:Number;
		
		/** Original width of this clip */
		protected var __originalWidth:Number;
		
		/** Original height of this clip */
		protected var __originalHeight:Number;
		
		/** Original width of this clip */
		protected var __originalWidthScaleXRatio:Number;
		
		/** Original height of this clip */
		protected var __originalHeightScaleYRatio:Number;
		
		/** The minimum width */
		protected var __minWidth:Number = 0;
		
		/** The minimum height */
		protected var __minHeight:Number = 0;
		
		/** Keep track of the last event */
		protected var __currentEvent:String;
		
		/** Optional callback for __animating */
		protected var __callbackEvent:Function;
		
		/** If the button is enabled */
		protected var __enabled:Boolean;
		
		/** Timer that is started on roll over to determine when we should fire
		*** the tooltip event */
		private var __tooltipTimer:Timer;
		
		/** If we're tweening */
		private var __animating:Boolean = false;
		
		/** Tool Tip object */
		public var __toolTip:UIControl;
		
		/** If clicking off the control hides it */
		private var __clickOffHides:Boolean;
		
		/** Clips that, if clicked off, trigger a click-off */
		public var clickOffClips:Array;
		
		/** Global setter to play UI animations */
		public static var playAnimations:Boolean = true;
		
		/**
		*   Make the UI control
		*/
		public function UIControl()
		{			
			this.stop();
			
			__originalScaleX = this.scaleX;
			__originalScaleY = this.scaleY;
			__originalWidth = this.width;
			__originalHeight = this.height;
			__originalWidthScaleXRatio = this.width / this.scaleX;
			__originalHeightScaleYRatio = this.height / this.scaleY; 
			
			__tooltipTimer = new Timer(TOOLTIP_DISPATCH_TIME, 1);
			__tooltipTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDispatchTooltipEvent);
			
			this.tabEnabled = false;
			
			this.scaleX = this.scaleY = 1;
			resize();
		}
		
		/**
		*   Check if clicking off hides this control
		*   @return If clicking off hides this control
		*/
		public function get clickOffHides(): Boolean
		{
			return __clickOffHides;
		}
		
		/**
		*   Set if clicking off of the control hides it
		*   @param clickOffHides If clicking off of the control hides it
		*/
		public function set clickOffHides(clickOffHides:Boolean): void
		{
			__clickOffHides = clickOffHides;
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownForHide);
			if (clickOffHides)
			{
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownForHide);
			}
		}
		
		/**
		*   Callback for when the mouse is down anywhere on the stage
		*   @param ev Mouse down event
		*/
		private function onMouseDownForHide(ev:MouseEvent): void
		{
			// Reject clicks anywhere on us
			for (var obj:DisplayObject = ev.target as DisplayObject; obj != null; obj = obj.parent)
			{
				if (this.clickOffClips != null)
				{
					for each (var clickOffClip:* in this.clickOffClips)
					{
						if (obj == clickOffClip)
						{
							return;
						}
					}
				}
				if (obj == this)
				{
					return;
				}
			}
			
			dispatchEvent(new UIControlEvent(UIControlEvent.CLICK_OFF_HIDING));
		}
		
		/**
		*   Set if the ui element should be enabled or not
		*   @param enabled If the element should be enabled or not
		*/
		override public function set enabled(enabled:Boolean):void
		{
			__enabled = enabled;
			this.removeEventListener(MouseEvent.ROLL_OVER, onRollOverTooltip);
			//this.removeEventListener(MouseEvent.ROLL_OUT, onRollOutTooltip);
			
			// Listen to events only if we're enabled
			if (enabled)
			{
				this.addEventListener(MouseEvent.ROLL_OVER, onRollOverTooltip);
				this.addEventListener(MouseEvent.ROLL_OUT, onRollOutTooltip);
			}
		}
		
		/**
		*   Check if this control is enabled
		*   @return If this control is enabled
		*/
		override public function get enabled():Boolean
		{
			return __enabled;
		}
		
		/**
		*   Starts the timer if the mouse rolls over this UIControl
		*   @param  event:MouseEvent
		*/
		private function onRollOverTooltip(event:MouseEvent):void
		{
			__tooltipTimer.start();
		}
		
		/**
		*   Stop the timer when the mouse rolls out of this UIControl
		*   @param  event:MouseEvent
		*/
		private function onRollOutTooltip(event:MouseEvent):void
		{
			//if we've already dispatched ENABLE_TOOLTIP
			if (!__tooltipTimer.running)
			{
				dispatchEvent(new UIControlEvent(UIControlEvent.DISABLE_TOOLTIP));
			}
			__tooltipTimer.reset();
		}
		
		/**
		*   If the mouse has been over this element for more than the
		*   amount of time specified by TOOLTIP_DISPATCH_TIME it dispatches 
		*   a UIControlEvent.TOOLTIP
		*   @param  event:Event
		*/
		private function onDispatchTooltipEvent(event:Event):void
		{
			__tooltipTimer.reset();
			
			dispatchEvent(new UIControlEvent(UIControlEvent.ENABLE_TOOLTIP));
		}
		
		/**
		*   Change the scaleX/scaleY factors on a display object to undo the
		*   scaling applied to this control
		*   @param obj Object to undo scaling on
		*/
		protected function undoScale(obj:DisplayObject): void
		{
			assert(obj != null, "Obj is null");
			
			obj.scaleX = 1 / __originalScaleX;
			obj.scaleY = 1 / __originalScaleY;
		}
		
		/**
		*	Play Animation for an event
		* 	@param state String of push button event
		* 	@param callback Function for when the animation is through
		*/
		protected function playAnimationFor(event:String, callback:Function=null): void
		{
			// Allow the ability to globally not play animations
			if ( !playAnimations )
			{
				if (callback != null) callback();
				return;
			}
			
			// Check if we're already __animating, then
			// let's stop what we were doing before moving on
			if ( __animating )
			{
				this.removeEventListener(Event.ENTER_FRAME, onTweenEvent);
				if ( __callbackEvent != null ) __callbackEvent();
			}
			
			// save new callback
			__callbackEvent = callback;
			
			// stop the playhead
			this.gotoAndStop(1);
			__animating = false;
			
			// save the current event being called
			__currentEvent = event;
			
			// loop through all labels and see if we can 
			// find a match for the event called
			for each( var label:FrameLabel in this.currentLabels )
			{
				if ( label.name == event )
				{
					// Play the animation
					__animating = true;
					this.gotoAndPlay(event);
					
					// Enter frame check for stop or loop
					this.addEventListener(Event.ENTER_FRAME, onTweenEvent);
					break;
				}
			}
			if (!__animating && callback != null)
			{
				callback();
			}
		}
		
		/**
		* 	Enter frame checking frame labels to stop or loop animation
		* 	@param	ev Enter frame event
		*/
		protected function onTweenEvent(ev:Event): void
		{
			if ( this.currentLabel == __currentEvent + " stop" )
			{
				// Stop the animation
				this.stop();
				__animating = false;
				
				// Clear the enter frame
				this.removeEventListener(Event.ENTER_FRAME, onTweenEvent);
				
				// Callback if necessary
				if ( __callbackEvent != null ) __callbackEvent();
			}
			else if ( this.currentLabel == __currentEvent + " loop" )
			{
				// Play the loop again
				this.gotoAndPlay( __currentEvent );
				
				// Callback if necessary
				if ( __callbackEvent != null ) __callbackEvent();
			}
		}
		
		/**
		*   Set the tool tip to enable
		*   @param toolTip Tool tip to enable
		*/
		public function set toolTip(toolTip:UIControl): void
		{	
			if (__toolTip != null)
			{
				__toolTip.enabled = false;
			}
			
			__toolTip = toolTip;
			
			removeEventListener(UIControlEvent.ENABLE_TOOLTIP, onEnableToolTip);
			removeEventListener(UIControlEvent.DISABLE_TOOLTIP, onDisableToolTip);
			
			if (toolTip != null)
			{
				addEventListener(UIControlEvent.ENABLE_TOOLTIP, onEnableToolTip);
				addEventListener(UIControlEvent.DISABLE_TOOLTIP, onDisableToolTip);
			}
		}
		
		/**
		 * Get the tool tip
		 */
		public function get toolTip():UIControl
		{	
			return __toolTip;
		}
		
		/**
		*   Callback for when the tooltip is to be disabled
		*   @param ev Disable event
		*/
		private function onDisableToolTip(ev:UIControlEvent):void
		{
			if (__toolTip != null)
			{
				__toolTip.enabled = false;
			}
		}
		
		/**
		*   Callback for when the tooltip is to be enabled
		*   @param ev Enable event
		*/
		private function onEnableToolTip(ev:UIControlEvent):void
		{
			if (__toolTip != null)
			{
				__toolTip.enabled = true;
			}
		}
		
		/**
		*	Resize this element
		*/
		protected function resize(): void
		{
		}
		
		/**
		*	Set the height
		*	@param	height
		*/
		public override function set height(height:Number): void
		{
			height = Math.max(__minHeight, height);
			__originalScaleY = height / __originalHeightScaleYRatio;
			__originalHeight = height;
			resize();
		}
		
		/**
		*	Set the width
		*	@param	width
		*/
		public override function set width(width:Number): void
		{
			width = Math.max(__minWidth, width);
			__originalScaleX = width / __originalWidthScaleXRatio;
			__originalWidth = width;
			resize();
		}
		
		/**
		*   "Destroys" the instance by disabling it. The instance should be
		*   considered invalid after this.
		*/
		public override function destroy() : void
		{
			__tooltipTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onDispatchTooltipEvent);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownForHide);
			this.removeEventListener(MouseEvent.ROLL_OVER, onRollOverTooltip);
			this.removeEventListener(MouseEvent.ROLL_OUT, onRollOutTooltip);
			this.removeEventListener(Event.ENTER_FRAME, onTweenEvent);
			this.removeEventListener(UIControlEvent.ENABLE_TOOLTIP, onEnableToolTip);
			this.removeEventListener(UIControlEvent.DISABLE_TOOLTIP, onDisableToolTip);
			if (__toolTip != null)
			{
				__toolTip.destroy();
			}
			__callbackEvent = null;
			__toolTip = null;
			clickOffClips = null;
			__tooltipTimer.stop();
			__tooltipTimer = null;
			super.destroy();
		}
	}
}
