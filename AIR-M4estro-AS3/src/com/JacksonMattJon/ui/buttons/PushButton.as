package com.JacksonMattJon.ui.buttons
{
	import com.JacksonMattJon.ui.UIControl;
	import com.JacksonMattJon.ui.util.StringUtils;
	import com.JacksonMattJon.ui.buttons.PushButtonEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	/**
	*   A simple push button
	*   @author Jackson Dunstan
	*/
	public class PushButton extends UIControl
	{
		/** Maximum number of milliseconds that can elapse between two
		 *  consecutive mouse release events for them to be considered a
		 *  double click */
		public static var DOUBLE_CLICK_INTERVAL:uint = 300;
		
		/** When scaling due to label text changes, don't resize */
		public static const LABEL_TEXT_SCALE_ALIGN_NONE:uint = 0;
		
		/** When scaling due to label text changes, align left */
		public static const LABEL_TEXT_SCALE_ALIGN_LEFT:uint = 1;
		
		/** When scaling due to label text changes, align right */
		public static const LABEL_TEXT_SCALE_ALIGN_RIGHT:uint = 2;
		
		/** When scaling due to label text changes, align center */
		public static const LABEL_TEXT_SCALE_ALIGN_CENTER:uint = 3;
		
		/** True after an MOUSE_PRESS event occurs but before an onRelease
		*   event occurs. */
		protected var __mouseDownOnThis:Boolean;
		
		/** Clip to show during up state */
		public var up:MovieClip;
		
		/** Clip to show during over state */
		public var over:MovieClip;
		
		/** Clip to show during down state */
		public var down:MovieClip;
		
		/** Clip to show during disabled state */
		public var disabled:MovieClip;
		
		/** Label on all states of the button */
		protected var __labelText:String;
		
		/** Last time the mouse was released */
		protected var __lastRelease:int;
		
		/** Type of scaling and alignment to apply when changing label text */
		public var labelTextScaleAlign:uint;
		
		/** The padding left of the text field */
		protected var __paddingLeft:Number;
		
		/** The padding right of the text field */
		protected var __paddingRight:Number;
		
		/** Button states */
		protected var __states:Array;
		
		/**
		*   Construct the push button. This defaults to "up" state
		*/
		public function PushButton()
		{
			assert(this.up != null, "Button has no up state clip");
			assert(this.over != null, "Button has no over state clip");
			assert(this.down != null, "Button has no down state clip");
			assert(this.disabled != null, "Button has no disabled state clip");
			
			__states = [this.up, this.over, this.down, this.disabled];
			
			__labelText = "";
			__lastRelease = -1;
			
			// If we have a label then set the default padding to x
			if ( isNaN(__paddingLeft) && isNaN(__paddingRight ) )
			{
				if ( this.up.label != null ) 
				{
					__paddingLeft = this.up.label.x; 
					__paddingRight = this.up.label.x;
				}
				else
				{
					__paddingLeft = 0;
					__paddingRight = 0;
				}
			}
			
			this.labelTextScaleAlign = LABEL_TEXT_SCALE_ALIGN_NONE;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			this.enabled = true;
			
			this.stop();
			
			resize();
		}
		
		/**
		*	Resize the push button 
		*/
		protected override function resize(): void
		{
			if (this.up.base && this.over.base && this.down.base && this.disabled.base)
			{
				var state:MovieClip;
				
				// Scale label and base instead of us
				if (this.up.label && this.down.label && this.over.label && this.disabled.label && !isNaN(__paddingLeft) && !isNaN(__paddingRight))
				{					
					for each( state in __states )
					{
						state.label.width = __originalWidth - __paddingLeft - __paddingRight;
						state.label.x = __paddingLeft;
					}
				}
				
				for each ( state in __states )
				{
					state.base.width = __originalWidth;
					state.base.height = __originalHeight;
					
					// Reject rotation of state clip bases. Designers should rotate
					// the whole button instead.
					state.base.rotation = 0;
				}
			}
		}
		
		/**
		*	Textfield autosize the text field
		*/
		public function set labelTextAutoSize(autoSize:String): void
		{
			for each ( var state:MovieClip in __states )
			{
				state.label.autoSize = autoSize;
			}
		}
		
		/**
		*   Set the button's tint colors. The state clips must each have a
		*   base child.
		*   @param upColor Color to tint the up clip with
		*   @param overColor Color to tint the over clip with
		*   @param downColor Color to tint the down clip with
		*   @param disabledColor Color to tint the disabled clip with
		*/
		public function tint(upColor:uint, overColor:uint, downColor:uint, disabledColor:uint): void
		{
			assert(this.up.base != null, "Up clip has no base to tint");
			assert(this.over.base != null, "Over clip has no base to tint");
			assert(this.down.base != null, "Down clip has no base to tint");
			assert(this.disabled.base != null, "Disabled clip has no base to tint");
			
			this.up.base.transform.colorTransform = new ColorTransform(
				1, // red multiplier
				1, // green multiplier
				1, // blue multiplier
				1, // alpha multiplier
				(upColor >> 16) & 0xff, // red offset
				(upColor >> 8) & 0xff, // green offset
				upColor & 0xff, // blue offset
				0 // alpha offset
			);
			
			this.over.base.transform.colorTransform = new ColorTransform(
				1, // red multiplier
				1, // green multiplier
				1, // blue multiplier
				1, // alpha multiplier
				(overColor >> 16) & 0xff, // red offset
				(overColor >> 8) & 0xff, // green offset
				overColor & 0xff, // blue offset
				0 // alpha offset
			);
			
			this.down.base.transform.colorTransform = new ColorTransform(
				1, // red multiplier
				1, // green multiplier
				1, // blue multiplier
				1, // alpha multiplier
				(downColor >> 16) & 0xff, // red offset
				(downColor >> 8) & 0xff, // green offset
				downColor & 0xff, // blue offset
				0 // alpha offset
			);
			
			this.disabled.base.transform.colorTransform = new ColorTransform(
				1, // red multiplier
				1, // green multiplier
				1, // blue multiplier
				1, // alpha multiplier
				(disabledColor >> 16) & 0xff, // red offset
				(disabledColor >> 8) & 0xff, // green offset
				disabledColor & 0xff, // blue offset
				0 // alpha offset
			);
		}
		
		/**
		*   Clear any tinting applied to the button. The state clips must each
		*   have a base child.
		*/
		public function clearTint(): void
		{			
			for each ( var state:MovieClip in __states )
			{
				assert(state.base != null, state.name + " clip has no base to tint");
				state.base.transform.colorTransform = new ColorTransform();
			}
		}
		
		/**
		*   Set the label on all states
		*   @param str The label
		*/
		public function set labelText(str:String): void
		{			
			var state:MovieClip;
			
			for each ( state in __states )
			{
				assert(state.label is TextField, "Button has no " + state.name + " label");
				state.label.mouseEnabled = false;
			}
			
			var oldWidth:Number = this.width;
			
			__labelText = str;
			
			for each ( state in __states )
			{
				state.label.text = str;
			}
			
			labelTextSet(oldWidth);
		}
		
		/**
		*   Set the HTML label on all states
		*   @param str The HTML label
		*/
		public function set labelTextHTML(str:String): void
		{	
			var state:MovieClip;
			
			for each ( state in __states )
			{
				assert(state.label is TextField, "Button has no " + state.name + " label");
				state.label.mouseEnabled = false;
			}
			
			var oldWidth:Number = this.width;
			
			__labelText = str;
			
			for each ( state in __states )
			{
				state.label.htmlText = str;
			}
			
			labelTextSet(oldWidth);
		}
		
		/**
		*   Routine to perform after the label text is set (HTML or not)
		*   @param oldWidth Width of ourself before setting the text
		*/
		protected function labelTextSet(oldWidth:Number): void
		{
			// Have a base and they want scaling
			if (this.up.base && this.over.base && this.down.base && this.disabled.base && this.labelTextScaleAlign != LABEL_TEXT_SCALE_ALIGN_NONE)
			{
				// Size correctly
				for each ( var state:MovieClip in __states )
				{
					state.label.autoSize = TextFieldAutoSize.LEFT;
					state.base.width = state.label.width + __paddingLeft + __paddingRight;
				}
				
				// Adjust position to align properly
				switch (this.labelTextScaleAlign)
				{
					case LABEL_TEXT_SCALE_ALIGN_RIGHT:
					{
						this.x += oldWidth - this.width;
						break;
					}
					case LABEL_TEXT_SCALE_ALIGN_CENTER:
					{
						this.x -= (this.width - oldWidth) / 2;
						break;
					}
				}
			}
			
			dispatchEvent(new PushButtonEvent(PushButtonEvent.LABEL_TEXT_CHANGED));
		}
		
		/**
		*	Get the left padding amount 
		*/
		public function get paddingLeft(): Number
		{
			return __paddingLeft;
		}
		
		/**
		*	Get the right padding amount 
		*/
		public function get paddingRight(): Number
		{
			return __paddingRight;
		}
		
		/**
		*	Get the left padding amount 
		*/
		public function set paddingLeft(padding:Number): void
		{
			var oldPadding:Number = __paddingLeft;
			__paddingLeft = padding;
			__originalWidth -= __paddingLeft - oldPadding;
			resize();
		}
		
		/**
		*	Get the right padding amount 
		*/
		public function set paddingRight(padding:Number): void
		{
			var oldPadding:Number = __paddingRight;
			__paddingRight = padding;
			__originalWidth -= __paddingRight - oldPadding;
			resize();
		}
		
		/**
		*	This will truncate each state label 
		*/
		public function truncateLabelText(): void
		{
			for each ( var state:MovieClip in __states )
			{
				assert(state.label is TextField, "Button has no " + state.name + " label");
				StringUtils.truncateLabel(state.label, state.label.text);
			}
		}
		
		
		/**
		*   Get the label on all states
		*   @return The label
		*/
		public function get labelText(): String
		{
			return __labelText;
		}
		
		/**
		*   Set if the label is multiline or not
		*   @param multiline If the label should be multiline or not
		*/
		public function set multiline(multiline:Boolean): void
		{
			for each ( var state:MovieClip in __states )
			{
				assert(state.label is TextField, "Button has no " + state.name + " label");
				state.label.multiline = multiline;
			}
		}
		
		/**
		*   Check if the label is multiline or not
		*   @return If the label is multiline or not
		*/
		public function get multiline(): Boolean
		{
			for each ( var state:MovieClip in __states )
			{
				assert(state.label is TextField, "Button has no " + state.name + " label");
			}
			
			return this.up.label.multiline &&
				this.over.label.multiline &&
				this.down.label.multiline &&
				this.disabled.label.multiline;
		}
		
		/**
		*   Set if the label is word-wrapped or not
		*   @param wordWrap If the label should be word-wrapped or not
		*/
		public function set wordWrap(wordWrap:Boolean): void
		{
			for each ( var state:MovieClip in __states )
			{
				assert(state.label is TextField, "Button has no " + state.name + " label");
				state.label.wordWrap = wordWrap;
			}
		}
		
		/**
		*   Check if the label is word-wrapped or not
		*   @return If the label is word-wrapped or not
		*/
		public function get wordWrap(): Boolean
		{
			for each ( var state:MovieClip in __states )
			{
				assert(state.label is TextField, "Button has no " + state.name + " label");
			}
			
			return this.up.label.wordWrap &&
				this.over.label.wordWrap &&
				this.down.label.wordWrap &&
				this.disabled.label.wordWrap;
		}
		
		/**
		*   Set if the button should be enabled or not
		*   @param enabled If the button should be enabled or not
		*/
		public override function set enabled(enabled:Boolean): void
		{
			super.enabled = enabled;
			
			// Set visibility to up for enabled and disabled for disabled
			this.up.visible = enabled;
			this.over.visible = false;
			this.down.visible = false;
			this.disabled.visible = !enabled;
			
			// Act like a button or not
			__mouseDownOnThis = false;
			this.buttonMode = enabled;
			this.useHandCursor = enabled;
			this.doubleClickEnabled = enabled;
			
			// Remove old event listeners in either case, because if we are
			// enabled while already enabled, we don't want double message
			this.removeEventListener(MouseEvent.ROLL_OVER, onRollOverInternal);
			this.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onPress);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageLeave);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageRelease);
			
			// Listen to events only if we're enabled
			if (enabled)
			{
				this.addEventListener(MouseEvent.ROLL_OVER, onRollOverInternal);
				this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				this.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
				if (this.stage)
				{
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageRelease);
					stage.addEventListener(Event.MOUSE_LEAVE, onStageLeave);
				}
			}
		}
		
		/**
		*   Callback for when we are added to the stage
		*   @param ev Added to stage event
		*/
		protected function onAddedToStage(ev:Event): void
		{
			if (__enabled)
			{
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageRelease);
				stage.addEventListener(Event.MOUSE_LEAVE, onStageLeave);
			}
		}
		
		/**
		*   Callback for when we are removed to the stage
		*   @param ev Added to stage event
		*/
		protected function onRemovedFromStage(ev:Event): void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageRelease);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageLeave);
		}
		
		/**
		*   Callback for when the mouse leaves the stage
		*   @param ev Stage leave event
		*/
		protected function onStageLeave(ev:Event) :void
		{
			if (!this.up.visible)
			{
				handleRollOut();
			}
		}
		
		/**
		*   Callback for when we are rolled over
		*   @param ev Rollover event
		*/
		protected function onRollOverInternal(ev:MouseEvent): void
		{
			if (__mouseDownOnThis)
			{
				onDragOver(ev);
			}
			else
			{
				onRollOver(ev);
			}
		}
		
		/**
		*   Callback for when the button is rolled over
		*   @param ev Roll over event
		*/
		protected function onRollOver(ev:MouseEvent): void
		{
			this.up.visible = false;
			this.over.visible = true;
			this.down.visible = false;
			this.disabled.visible = false;
			
			playAnimationFor(PushButtonEvent.ROLL_OVER);
			dispatchEvent(new PushButtonEvent(PushButtonEvent.ROLL_OVER));
		}
		
		/**
		*   Callback for when the button is rolled over and the mouse was
		*   originally clicked on the button and was dragged out.
		*   @param ev Roll over event
		*/
		protected function onDragOver(ev:MouseEvent) :void
		{
			this.up.visible = false;
			this.over.visible = false;
			this.down.visible = true;
			this.disabled.visible = false;
			playAnimationFor(PushButtonEvent.DRAG_OVER);
			dispatchEvent(new PushButtonEvent(PushButtonEvent.DRAG_OVER));
		}
		
		/**
		*   Callback for when the button is rolled out
		*   @param ev Roll out event
		*/
		protected function onRollOut(ev:MouseEvent): void
		{
			handleRollOut();
		}
		
		/**
		*   Handle the user rolling out of the clip or off the stage
		*/
		protected function handleRollOut(): void
		{
			this.up.visible = true;
			this.over.visible = false;
			this.down.visible = false;
			this.disabled.visible = false;
			
			if (__mouseDownOnThis)
			{
				playAnimationFor(PushButtonEvent.DRAG_OUT);
				dispatchEvent(new PushButtonEvent(PushButtonEvent.DRAG_OUT));
			}
			else
			{
				playAnimationFor(PushButtonEvent.ROLL_OUT);
				dispatchEvent(new PushButtonEvent(PushButtonEvent.ROLL_OUT));
			}
		}
		
		/**
		*   Callback for when the button is pressed
		*   @param ev Press event
		*/
		protected function onPress(ev:MouseEvent): void
		{
			this.up.visible = false;
			this.over.visible = false;
			this.down.visible = true;
			this.disabled.visible = false;
			__mouseDownOnThis = true;
			playAnimationFor(PushButtonEvent.PRESS);
			dispatchEvent(new PushButtonEvent(PushButtonEvent.PRESS));
		}
		
		/**
		*   Callback for when the button is released
		*   @param ev Release event
		*/
		protected function onRelease(ev:MouseEvent): void
		{
			__mouseDownOnThis = false;
			
			this.up.visible = false;
			this.over.visible = true;
			this.down.visible = false;
			this.disabled.visible = false;
			
			playAnimationFor(PushButtonEvent.RELEASE);
			dispatchEvent(new PushButtonEvent(PushButtonEvent.RELEASE));
			
			checkDoubleClick();
		}
		
		/**
		*   Check for double clicks
		*/
		protected function checkDoubleClick(): void
		{
			const now:int = getTimer();
			if (now - __lastRelease <= DOUBLE_CLICK_INTERVAL)
			{
				playAnimationFor(PushButtonEvent.DOUBLE_CLICK);
				dispatchEvent(new PushButtonEvent(PushButtonEvent.DOUBLE_CLICK));
			}
			__lastRelease = now;
		}
		
		/**
		 * Click the button from code.
		 * Mark Thrall added me.  Blame him for being lazy.
		 */
		public function click():void
		{
			onRelease(new MouseEvent(MouseEvent.CLICK));
			
			this.over.visible = false;
			this.up.visible = true;
		}
		
		
		/**
		*   Callback for when the mouse is released outside of our clip
		*   @param ev Release outside event
		*/
		protected function onReleaseOutside(ev:MouseEvent): void
		{
			__mouseDownOnThis = false;
			playAnimationFor(PushButtonEvent.RELEASE_OUTSIDE);
			dispatchEvent(new PushButtonEvent(PushButtonEvent.RELEASE_OUTSIDE));
		}
		
		/**
		*   Occurs when the mouse is released anywhere, since the mouse event
		*   model is quite different in AS3, buttons need to listen to all
		*   mouse release events after they have been clicked so they know if
		*   the mouse button was released while Not over the button's clip
		*   @param ev Event data describing the mouse up event
		*/
		protected function onStageRelease(ev:MouseEvent): void
		{
			if (!__enabled || !__mouseDownOnThis)
			{
				return;
			}
			
			// If it hits us, it's a normal release
			for (var obj:DisplayObject = ev.target as DisplayObject; obj != null; obj = obj.parent)
			{
				if (obj == this)
				{
					onRelease(ev);
					//ev.stopImmediatePropagation();
					return;
				}
			}
			
			// If it doesn't hit us, but the mouse was down on us, it's an outside release
			onReleaseOutside(ev);
		}
		
		/**
		*   "Destroys" the instance by disabling it. The instance should be
		*   considered invalid after this.
		*/
		public override function destroy() : void
		{
			__states = null;
			this.enabled = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageRelease);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			__labelText = null;
			up = null;
			over = null;
			down = null;
			disabled = null;
			super.destroy();
		}
	}
}
