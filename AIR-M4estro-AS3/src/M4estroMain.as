package 
{
	//import com.cloudkid.*;
	//import com.cloudkid.animation.Animator;
	//import com.cloudkid.base.*;
	//import com.cloudkid.games.*;
	//import com.cloudkid.util.Debug;
	import com.disney.Application;
	import com.disney.OS;
	import com.disney.loaders.XMLLoader;
	import com.m4estro.ui.KeyboardInstrumentMC;
	import com.m4estro.ui.TestSymbol;
	import com.m4estro.ui.editor.MIDIEditorMC;
	import com.maestro.controller.AudioInstrumentController;
	import com.maestro.editor.MIDIEditor;
	import com.maestro.managers.InputManager;
	import com.maestro.music.MusicManager;
	import com.noteflight.standingwave2.elements.AudioDescriptor;
	import com.noteflight.standingwave2.elements.IAudioSource;
	import com.noteflight.standingwave2.output.AudioPlayer;
	import com.noteflight.standingwave2.sources.SineSource;
	
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	
	import org.wwlib.utils.WwDebug;
	import org.wwlib.utils.WwDeviceInfo;
	
	/*****/
	
	final public class M4estroMain extends Application
	{
		/** This variable should stay null. It ensures that the game class is compiled and put in the finished swf, so that the game can be created when it is needed*/
		//private static const __classExistanceEnforcer:Class = TrashStashGame;
		
		// The game container
		//private var __container:GameContainer;
		
		/** The pattern */
		private var __contentPattern:BitmapData;
		
		private static const PADDING:int = 10;
		
		public static const DEBUG_IP:String = GAME::DEBUG_IP;
		
		//[Embed(source="../../../../../embedded_assets/intro.swf",mimeType="application/octet-stream")]
		//private static var __controlsBytesClass:Class;
		
		private var __intro:MovieClip;
		
		/***** ANDREW TEST */
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
		private var testSymbol:TestSymbol;
		
		/*****/
		
		private var __deviceInfo:WwDeviceInfo;
		private var __debug:WwDebug;
		private var __appDebugStage:MovieClip;
		
		/**
		*   The game container
		*/
		public function M4estroMain()
		{
			/*Accelerometer handling code
				//if accelerometer is available then activate it to control the ball
				if(Accelerometer.isSupported)
				{
					acc = new Accelerometer();
					acc.addEventListener(AccelerometerEvent.UPDATE, accUpdate);
					acc.setRequestedUpdateInterval(30);
				}
			//handler for accelerometer
			private function accUpdate(e:AccelerometerEvent):void
			{
				accX = e.accelerationX;
				accY = e.accelerationY;
				accZ = e.accelerationZ;
			}
			*/
			__appDebugStage = new MovieClip();
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
			
			//com.cloudkid.util.Debug.globalMinLogLevel = LOG_GENERAL;
			__debug.log("Constructor", "BundledGameContainer");
			
			
			new OS(this);
			
			OS.instance.stage.frameRate = 30;
			OS.instance.stage.align = StageAlign.TOP_LEFT;
			OS.instance.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			/****** ANDREW TEST */
			
			//OS.instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, onNote);
			
			__sound = new Sound();
			__sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			__sound.play();
			
			__assetPath = OS.instance.basePath + "assets/";
			__debug.log("init: basePath: " + __assetPath, "BGC");
            
			InputManager.init(OS.instance.stage);
			MusicManager.instance.init(__assetPath);
			
			MusicManager.instance.addEventListener(MusicManager.INSTRUMENT_CONFIG_LOADED, onInstrumentConfigLoaded);
			MusicManager.instance.addEventListener(MusicManager.SONG_LOADED, onSongLoaded);
			

			
			keyboardMC = new KeyboardInstrumentMC();
			addChild(keyboardMC);
			keyboardMC.x = 190;
			keyboardMC.y = 400;
			
			__debug.log("keyboardMC: " + keyboardMC.key28, "BGC");
			__debug.log("keyboardMC: name: " + keyboardMC.key28.name, "BGC");
			keyboardMC.key28.y += 5;
			
			testSymbol = new TestSymbol();
			addChild(testSymbol);
			
			funkController = new AudioInstrumentController();
			funkController.setKeyboardMC(keyboardMC);
			
			
			__midiEditorMC = new MIDIEditorMC();
			addChild(__midiEditorMC);
			__midiEditorMC.y = 30;
			__midiEditor = new MIDIEditor(__midiEditorMC);
			
			
			
            var configURL:String = __assetPath + "music_config.xml";
            __debug.log("init: configURL: " + configURL, "BGC");
            XMLLoader.instance.load(configURL, onConfigLoaded);
			
			/*****/
			
			SYSTEM::MOBILE
			{
				//also available:
				//OS.instance.stage.setAspectRatio(StageAspectRatio.LANDSCAPE);
				//stage.autoOrients (defaults to true)
				//stage.deviceOrientation (defaults to landscape)
				//stage.supportedOrientations (a vector of strings) - uses StageOrientation constants
				//stage.setOrientation(newOrientation:String) - uses StageOrientation constants
				//stage.setAspectRatio(StageAspectRatio.LANDSCAPE); - PORTRAIT is also available
				OS.instance.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChange, false, 100, true); 
			}
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExit);
			SYSTEM::ANDROID
			{
				
				OS.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
			SYSTEM::MOBILE
			{
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivated);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivated);
			}
			
			CONFIG::DEBUG
			{
				OS.instance.totalMemory.visible = true;
				OS.instance.framerate.visible = true;
			}
			
			SYSTEM::MOBILE
			{
				//Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;//Pretty much required if you want to receive TOUCH_TAP events
				
				CONFIG::DEBUG
				{
					//com.cloudkid.util.__debug.useNetworkDebugging(DEBUG_IP);
				}
			}
			
			//var skinBytes:ByteArray = new __controlsBytesClass;
			//BinaryLoader.instance.addToCache("embeddedSkin", skinBytes);
			//MediaLoader.instance.load("embeddedSkin", onIntroLoaded, true);
		}
		
		
		/***** ANDREW TEST */
		
        private function onConfigLoaded(xml:XML):void
        {
            // Store our game config
            __config = xml;

            __debug.log("onConfigLoaded", "BundledGameContainer");
            //MediaLoader.instance.load(assetPath + __config.content.@swf, onContentLoaded);
			
			__instrumentConfigURL = __assetPath + __config.instrument.@config;
			__soundtrackConfigURL = __assetPath + __config.soundtrack.@config;
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
			testSymbol.accelerate();
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
		/*****/
		
		/*
		private function onIntroLoaded(result:MediaLoaderResult): void
		{
			assert(result != null, "No intro to load");
			
			__intro = MovieClip(result.content);
			resizeIntro();
			__intro.stop();
			//addChild(__intro);
			// SAR
			//Animator.play(__intro, "intro", onIntroDone);

		}
		*/
		
		SYSTEM::MOBILE
		{
			private function onActivated(event:Event):void
			{
				log("activated!");
				
				//if(__container && __container.game)
				//{
				//	__container.game.onActivate();
				//}
			}
			
			private function onDeactivated(event:Event):void
			{
				log("deactivated!");
				
				//if(__container && __container.game && __container.game.onDeactivate())
				//{
					//do nothing
				//}
				//else
				//{
					NativeApplication.nativeApplication.exit();
				//}
			}
		}
		/*
		SYSTEM::ANDROID
		{
			private function onKeyDown(event:KeyboardEvent):void
			{
				if(__container && __container.game && __container.game.onSystemKey(event.keyCode))
				{
					event.preventDefault();
					event.stopImmediatePropagation();
					//do nothing, app took care of it
				}
				else if(event.keyCode == Keyboard.BACK)
				{
					event.preventDefault();
					event.stopImmediatePropagation();
					NativeApplication.nativeApplication.exit();
					
					log("Back Pressed");
				}
				else if(event.keyCode == Keyboard.MENU)
				{
					event.preventDefault();
					event.stopImmediatePropagation();

					log("Menu Pressed");
				}
				else if(event.keyCode == Keyboard.SEARCH)
				{
					event.preventDefault();
					event.stopImmediatePropagation();

					log("Search Pressed");
				}
			}
		}
		*/
		
		SYSTEM::MOBILE
		{
			// Is called when the device's orientation changes. NOTE: iOS might consider ROTATED_RIGHT and ROTATED_LEFT to 
			// be landscape mode, while Android does not
			private function onOrientationChange(event:StageOrientationEvent):void 
			{
				//if(__container && __container.game)
				//{
				//	__container.game.onOrientationChange(event.afterOrientation);
				//}

				//event.stopImmediatePropagation();
				//Rotating the OS is inappropriate
				switch (event.afterOrientation)
				{ 
					case StageOrientation.DEFAULT: 
						// re-orient display objects based on 
						// the default (right-side up) orientation.
						if(SYSTEM::IOS)
						{
							event.preventDefault();
						}
						else
						{
							if(event.beforeOrientation == StageOrientation.ROTATED_LEFT || event.beforeOrientation == StageOrientation.ROTATED_RIGHT)
							{
								event.preventDefault();
							}
						}
						break;
					case StageOrientation.ROTATED_RIGHT: 
						// Re-orient display objects based on 
						// right-hand orientation.
						if(SYSTEM::IOS)
						{
						}
						else
						{
							event.preventDefault();
						}
						break;
					case StageOrientation.ROTATED_LEFT: 
						// Re-orient display objects based on 
						// left-hand orientation.
						if(SYSTEM::IOS)
						{
						}
						else
						{
							event.preventDefault();
						}
						break;
					case StageOrientation.UPSIDE_DOWN: 
						// Re-orient display objects based on 
						// upside-down orientation.
						if(SYSTEM::IOS)
						{
							event.preventDefault();
						}
						else
						{
							if(event.beforeOrientation == StageOrientation.ROTATED_LEFT || event.beforeOrientation == StageOrientation.ROTATED_RIGHT)
							{
								event.preventDefault();
							}
						}
						break;
				}
			}
		}
		
		/**
		 * 	According to http://www.adobe.com/devnet/flash/articles/saving_state_air_apps.html
		 * 	this event isn't 100% reliable, sometimes because of the OS, sometimes not, so only
		 * 	saving user data here isn't the best. That project saved every 30-60 seconds and on 
		 * 	big user interactions for minimal loss of user progress.
		 */
		private function onExit(e:Event):void
		{
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, onExit);
			SYSTEM::ANDROID
			{
				OS.instance.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
			SYSTEM::MOBILE//Maybe just iOS?
			{
				NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivated);
				NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, onDeactivated);
			}
			
			destroy();
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			//__container.destroy();
			//__container = null;
		}
		
		/**
		 *   Initialize the application
		 */
		/*
		override public function init(): void
		{
			SoundManager.init();
			
			// Setup the Game container
			__container = new GameContainer();
			__container.addEventListener(GameContainerEvent.START_GAME, onContainerHandler);
			__container.addEventListener(GameContainerEvent.START_LEVEL, onContainerHandler);
			__container.addEventListener(GameContainerEvent.END_LEVEL, onContainerHandler);
			__container.addEventListener(GameContainerEvent.END_GAME, onContainerHandler);
			__container.addEventListener(GameContainerEvent.CLEAR_GAME, onContainerHandler);
			__container.addEventListener(GenericTrackingEvent.TRACK_EVENT, onTrackEvent);
			addChild(__container);
			__container.loadGame(__classExistanceEnforcer, "TrashStashGame", "");
			__container.visible = false;
		}
		*/
		
		private function onIntroDone(): void
		{
			log("onIntroDone");
			removeChild(__intro);
			__intro = null;
			//__container.visible = true;
			//__container.game["introDone"]();
						
		}
		
		public function resizeIntro():void{
			var stageWidth:Number;
			var stageHeight:Number;
			if(SYSTEM::MOBILE)
			{
				stageWidth = Math.max(OS.instance.stage.fullScreenWidth, OS.instance.stage.fullScreenHeight);
				stageHeight = Math.min(OS.instance.stage.fullScreenWidth, OS.instance.stage.fullScreenHeight);
			}
			else//if Air
			{
				stageWidth = 1024;
				stageHeight = 768;
			}

			var scale:Number = stageWidth / __intro.width;
			__intro.scaleX = __intro.scaleY = __intro.scaleX*scale;
			
			if(__intro.height > stageHeight){
				__intro.y -= (__intro.height - stageHeight)/2;
			}
			
		}
		
		/**
		 *   Handle Game container events
		 *   @param ev Game Container event
		 */
		//private function onContainerHandler(ev:GameContainerEvent): void
		//{
		//	SYSTEM::FLASH
		//	{
		//		log(ev.type + " (level:"+ev.level+", score:"+ev.score+")", LOG_INFO);
		//	}
		//}
		
		/**
		 *   Track custom events
		 *   @param ev Track event
		 */
		//private function onTrackEvent(ev:GenericTrackingEvent): void
		//{
		//	SYSTEM::FLASH
		//	{
		//		log(ev.type + " (category:"+ev.category+", action:"+ev.action+", label:"+ev.label+", value:"+ev.value+")", LOG_INFO);
		//	}
		//}
		
		/**
		 *   Update the game
		 *   @param	elapsed Time since last update
		 */
		override public function update(elapsed:int):void
		{
			//if(__container)
			//{
			//	__container.update(elapsed);
			//}
			
			var elapsedSecs:Number = elapsed;
			elapsedSecs = elapsedSecs / 1000;
			
			InputManager.processKeyboardInput();
			
			__midiEditor.update(elapsed);
			
        }
		
	}
}