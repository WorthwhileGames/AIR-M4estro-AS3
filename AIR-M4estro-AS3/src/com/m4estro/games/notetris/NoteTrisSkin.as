package com.m4estro.games.notetris
{
    import com.JacksonMattJon.ui.buttons.PushButton;
    import com.JacksonMattJon.ui.buttons.PushButtonEvent;
    import com.JacksonMattJon.ui.sliders.HorizontalSlider;
    import com.JacksonMattJon.ui.sliders.SliderEvent;
    import com.JacksonMattJon.ui.sliders.VerticalSlider;
    import com.m4estro.games.notetris.world.NotationView;
    import com.m4estro.games.notetris.world.ScoreColumn;
    import com.m4estro.vc.BaseMovieClip;
    import com.maestro.controller.AudioInstrumentController;
    import com.maestro.controller.MeasureController;
    import com.maestro.editor.MIDIEditor;
    import com.maestro.music.MusicManager;
    import com.maestro.world.GameBoard;
    import com.noteflight.standingwave3.elements.AudioDescriptor;
    import com.noteflight.standingwave3.elements.IAudioSource;
    import com.noteflight.standingwave3.output.AudioPlayer;
    import com.noteflight.standingwave3.sources.SineSource;
    
    import flash.events.Event;

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
		
		public var pbStart:PushButton;
		public var pbPause:PushButton;
		public var pbMakeTone:PushButton;
		
		public var slFrequency:HorizontalSlider;
		public var slTempo:VerticalSlider;
		
		public var measureController:MeasureController;
		
		
		private var __app:M4estroMain;
		
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
		
		public function init(app:M4estroMain):void
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
			var button:PushButton = PushButton(event.target);
			log("Button: Release: " + button.name, "NoteTris");
			
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