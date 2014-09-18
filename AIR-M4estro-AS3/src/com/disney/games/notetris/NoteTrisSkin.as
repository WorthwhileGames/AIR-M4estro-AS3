package com.disney.games.notetris
{
    import com.disney.base.BaseMovieClip;
	import com.maestro.world.GameBoard;
	import com.disney.games.notetris.world.BeatBar;
	import com.disney.games.notetris.world.NotationView;
	import com.disney.games.notetris.world.ScoreColumn;
	import com.disney.ui.sliders.LinearSlider;
	import com.disney.util.Debug;
	import com.maestro.controller.AudioInstrumentController;
	import com.maestro.controller.MeasureController;
	import com.maestro.editor.MIDIEditor;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import com.disney.cars.ui.buttons.PushButtonMicroTintable;
	import com.disney.cars.ui.sliders.HorizontalSliderNormal;
	import com.disney.cars.ui.sliders.VerticalSliderNormal;
	import com.disney.ui.buttons.PushButtonEvent;
	import com.disney.ui.sliders.SliderEvent;
	
	import flash.events.Event;
	
	import com.noteflight.standingwave2.sources.SineSource;
	import com.noteflight.standingwave2.elements.IAudioSource;
	import com.noteflight.standingwave2.elements.AudioDescriptor;
	import com.noteflight.standingwave2.output.AudioPlayer;
	
	import com.maestro.music.MusicManager;
	
	import com.cloudkid.peep.trashstash.BundledGameContainer;
	


    /**
     * Back end for the main Flash.
     */
    public class NoteTrisSkin extends BaseMovieClip
    {
		
		public var gameBoard:GameBoard;
		public var scoreColumn:ScoreColumn;
		public var notationView:NotationView;
		//public var beatBar:BeatBar;
		public var pianoController:AudioInstrumentController;
		public var blocksController:AudioInstrumentController;
		public var funkController:AudioInstrumentController;
		public var editor:MIDIEditor;
		
		//public var trackBar_Click:MovieClip;
		//public var trackBar_Bass:MovieClip;
		
		public var pbStart:PushButtonMicroTintable;
		public var pbPause:PushButtonMicroTintable;
		public var pbMakeTone:PushButtonMicroTintable;
		
		public var slFrequency:HorizontalSliderNormal;
		public var slTempo:VerticalSliderNormal;
		
		public var measureController:MeasureController;
		
		
		private var __app:BundledGameContainer;
		
		public function NoteTrisSkin()
		{
			log("NoteTrisSkin: gameBoard: " + gameBoard, "NoteTris");
			
			pbStart.addEventListener(PushButtonEvent.RELEASE, onButton);
			pbPause.addEventListener(PushButtonEvent.RELEASE, onButton);
			pbMakeTone.addEventListener(PushButtonEvent.RELEASE, onButton);
			
			slFrequency.addEventListener(SliderEvent.ON_CHANGE, onSliderChange);
			slTempo.addEventListener(SliderEvent.ON_CHANGE, onSliderChange);
			
			
			pbStart.labelText = "Start";
			pbPause.labelText = "Pause";
			pbMakeTone.labelText = "Tone";
			
		}
		
		public function init(app:BundledGameContainer):void
		{
			__app = app;
			measureController.init(gameBoard);
		}
		
		private function playSound():void
		{
			var source:IAudioSource = new SineSource(new AudioDescriptor(), .1, 440 + (slFrequency.value * 880));
			var player:AudioPlayer = new AudioPlayer();
			player.play(source);
		}
		
		public function onButton(event:Event):void
		{
			var button:PushButtonMicroTintable = PushButtonMicroTintable(event.target);
			Debug.log("Button: Release: " + button.name, "NoteTris");
			
			switch (button.name)
			{
				case "pbMakeTone":
					playSound();
					break;
					
				case "pbPause":
					var paused:Boolean = gameBoard.togglePaused();
					if (paused)
					{
						pbPause.labelText = "Unpause";
					}
					else 
					{
						pbPause.labelText = "Pause";
					}
					break;
					
				case "pbStart":
					if (MusicManager.instance.playing)
					{
						MusicManager.instance.stopPlayer();
						pbStart.labelText = "Start";
						gameBoard.pause();
					}
					else
					{
						MusicManager.instance.queueSoundtrackMeasures(editor.tempoScale);
						measureController.showMeasureControls();
						gameBoard.restart();
						pbStart.labelText = "Stop";
					}
					break;
					
			}
		}
		
		public function onSliderChange(event:Event):void
		{
			//var slider:LinearSlider = LinearSlider(event.target);
		}
		
		public function update(elapsed:int):void
        {
			
			editor.update(elapsed);
		}
		
    }
}