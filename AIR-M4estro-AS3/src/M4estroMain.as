package 
{
	import com.m4estro.ui.KeyboardInstrumentMC;
	import com.m4estro.ui.editor.MIDIEditorMC;
	import com.maestro.controller.AudioInstrumentController;
	import com.maestro.editor.MIDIEditor;
	import com.maestro.music.MusicManager;
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.sources.SineSource;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.filesystem.File;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.wwlib.utils.WwDebug;
	import org.wwlib.utils.WwDeviceInfo;
	
	/*****/
	
	[SWF(backgroundColor="#999999", width="1024", height="768", frameRate="59")]
	final public class M4estroMain extends Sprite// extends Application
	{
		
		private var __assetPath:String = "na";
        private var __config:XML;
		private var __instrumentConfigURL:String;
		private var __soundtrackConfigURL:String;
		
		private var __notes:Vector.<KSNote> = new Vector.<KSNote>();
		private var __sound:Sound;
		private var __max:Number = 1;
		private var __temp:Vector.<KSNote> = new Vector.<KSNote>();

		private var __midiEditorMC:MIDIEditorMC;
		private var __midiEditor:MIDIEditor;
		
		private var keyboardMC:KeyboardInstrumentMC;
		private var funkController:AudioInstrumentController;
		
		/*****/
		
		private var __prevTime:int;
		private var __frameTime:int;
		private var __totalSeconds:Number;
		private var __frameRate:Number;
		
		private var __deviceInfo:WwDeviceInfo;
		private var __debug:WwDebug;
		private var __appFlashStage:MovieClip;
		private var __appDebugStage:MovieClip;
		
		/**
		*   The game container
		*/
		public function M4estroMain()
		{
			
			__appFlashStage = new MovieClip();
			__appDebugStage = new MovieClip();
			
			stage.addChild(__appFlashStage);
			stage.addChild(__appDebugStage);
			
			__deviceInfo = WwDeviceInfo.init();
			WwDebug.init(__appDebugStage);
			__debug = WwDebug.instance;
			
			__debug.msg("os: " + __deviceInfo.os,"3");
			__debug.msg("devStr: " + __deviceInfo.devString,"3");
			__debug.msg("device: " + __deviceInfo.device,"3");
			__debug.msg("bgX: " + __deviceInfo.stageX,"3");
			__debug.msg("bgY: " + __deviceInfo.stageY,"3");
			__debug.msg("bgWidth: " + __deviceInfo.stageWidth,"3");
			__debug.msg("bgHeight: " + __deviceInfo.stageHeight,"3");
			__debug.msg("canvasX: " + __deviceInfo.canvasX,"3");
			__debug.msg("canvasY: " + __deviceInfo.canvasY,"3");
			__debug.msg("resolutionX: " + __deviceInfo.resolutionX,"3");
			__debug.msg("resolutionY: " + __deviceInfo.resolutionY,"3");
			__debug.msg("isDebugger: " + __deviceInfo.isDebugger,"3");
			__debug.msg("screenDPI: " + __deviceInfo.screenDPI,"3");			
			__debug.show = true;
			
			__appFlashStage.scaleX =  __deviceInfo.assetScaleFactor;
			__appFlashStage.scaleY =  __deviceInfo.assetScaleFactor;
			__appFlashStage.x =  __deviceInfo.stageX;
			__appFlashStage.y =  __deviceInfo.stageY;
						
			__appDebugStage.scaleX =  __deviceInfo.assetScaleFactor;
			__appDebugStage.scaleY =  __deviceInfo.assetScaleFactor;
			__appDebugStage.x =  __deviceInfo.stageX;
			__appDebugStage.y =  __deviceInfo.stageY;
			
			__debug.log("Constructor", "M4estroMain");
			
			__sound = new Sound();
			__sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			__sound.play();
			
			__assetPath = File.applicationDirectory.resolvePath("assets/").url;
			__debug.log("init: basePath: " + __assetPath, "BGC");
            
			MusicManager.instance.init(__assetPath);
			
			MusicManager.instance.addEventListener(MusicManager.INSTRUMENT_CONFIG_LOADED, onInstrumentConfigLoaded);
			MusicManager.instance.addEventListener(MusicManager.SONG_LOADED, onSongLoaded);
			

			
			keyboardMC = new KeyboardInstrumentMC();
			__appFlashStage.addChild(keyboardMC);
			keyboardMC.x = 190;
			keyboardMC.y = 400;
			
			__debug.log("keyboardMC: " + keyboardMC.key28, "BGC");
			__debug.log("keyboardMC: name: " + keyboardMC.key28.name, "BGC");
			keyboardMC.key28.y += 5;
			
			funkController = new AudioInstrumentController();
			funkController.setKeyboardMC(keyboardMC);
			
			
			__midiEditorMC = new MIDIEditorMC();
			__appFlashStage.addChild(__midiEditorMC);
			__midiEditorMC.y = 30;
			__midiEditor = new MIDIEditor(__midiEditorMC);

			var configURL:String = __assetPath + "/music_config.xml";
            __debug.log("init: configURL: " + configURL, "BGC");
			
			var url_request:URLRequest = new URLRequest(configURL);
			var loader:URLLoader = new URLLoader(url_request);
			loader.addEventListener(Event.COMPLETE, onConfigLoaded);
			
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			var total_milliseconds:int = getTimer();
			__frameTime = total_milliseconds - __prevTime;
			__prevTime = total_milliseconds;
			__frameRate = 1000.0 / __frameTime;
			__totalSeconds = total_milliseconds / 1000.0;
			WwDebug.fps = __frameRate;
			
			if (__midiEditor) __midiEditor.update(__frameTime);
		}
				
        private function onConfigLoaded(event:Event):void
        {
			var xml:XML = new XML(event.target.data);
            // Store our game config
            __config = xml;

            __debug.log(xml, "onConfigLoaded");
            //MediaLoader.instance.load(assetPath + __config.content.@swf, onContentLoaded);
			
			__instrumentConfigURL = __assetPath + "/" + __config.instrument.@config;
			__soundtrackConfigURL = __assetPath + "/" + __config.soundtrack.@config;
			__debug.log("onConfigLoaded: Instrument Config URL: " + __instrumentConfigURL, "BundledGameContainer");
			__debug.log("onConfigLoaded: Soundtrack Config URL: " + __soundtrackConfigURL, "BundledGameContainer");
			
			MusicManager.instance.loadInstruments(__instrumentConfigURL);
        }
		
		public function onInstrumentConfigLoaded(event:Event):void
		{
			__debug.log("onInstrumentConfigLoaded", "BundledGameContainer");
			//MusicManager.instance.initializeInstrumentController(pianoController, "piano");
			//MusicManager.instance.initializeInstrumentController(blocksController, "lead3");
			MusicManager.instance.initializeInstrumentController(funkController, "bassline");
			
			MusicManager.instance.loadSoundtrack(__soundtrackConfigURL);
		}
		
		public function onSongLoaded(event:Event):void
		{
			__debug.log("onSongLoaded", "BundledGameContainer");
			//MusicManager.instance.playSoundtrack(1);
		}
		
		private function onNote(event:MouseEvent):void
		{
			__debug.log("onNote", "BGC");
			//var note:KSNote = new KSNote(60 + this.mouseX * 1.4);
			//__notes.push(note);
			
			//playSound();
			
			//MusicManager.instance.playSoundtrack(1.0);
			//testSymbol.accelerate();
		}
		
		private function playSound():void
		{
			var scale:Number = this.mouseX / 512;
			var source:IAudioSource = new SineSource(new AudioDescriptor(), .1, 440 + (scale * 880));
			var player:AudioPlayer = new AudioPlayer();
			player.play(source);
		}
		
		private function onSampleData(event:SampleDataEvent):void
		{
			var note:KSNote
			for each(note in __notes)
			{
				if (note.doRemove)
				{
					__temp.push(note);
				}
			}
			for each(note in __temp)
			{
				__notes.splice(__notes.indexOf(note), 1);
			}
			__temp.length = 0;
			for ( var c:int = 0; c < 2048; c++ )
			{
				var v:Number = 0;
				for each(note in __notes)
				{
					v += note.getNextSample();
				}
				if (Math.abs(v) > __max)
				{
					__max = Math.abs(v);
				}
				v /= __max;
				event.data.writeFloat(v);
				event.data.writeFloat(v);
			}
		}		
	}
}