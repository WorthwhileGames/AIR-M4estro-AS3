package com.cloudkid.peep.trashstash
{
	import com.cloudkid.games.*;
	import com.cloudkid.loaders.*;
	import com.cloudkid.peep.peepgame.PeepGame;
	import com.cloudkid.peep.trashstash.ui.TrashStashGameSkin;
	import com.cloudkid.sound.SoundManager;
	import com.cloudkid.tasks.*;
	import com.cloudkid.util.BindUtils;
	import com.cloudkid.util.MathUtils;
	
	import flash.events.Event;
	
	public class TrashStashGame extends PeepGame
	{
		
		private static var __instance:TrashStashGame;
		
		private var __taskManager:TaskManager;
		/** The skin for the game */
		public var skin:TrashStashGameSkin;
		
		public var level1:XMLList;
		public var level2:XMLList;
		public var level3:XMLList;
		public var level4:XMLList;
		public var level5:XMLList;
		public var level6:XMLList;
		public var level7:XMLList;
		
		public var currentLevelId:uint = 0;
		public var currentCategory:String;
		
		public var currentItems:Vector.<uint>;
		public var currentCorrectItems:Vector.<uint>;
		
		public function TrashStashGame()
		{

			
			__instance = this;

			isAndroid = SYSTEM::ANDROID;
			isMobile = SYSTEM::MOBILE;
			isFlash = SYSTEM::FLASH;
			isIOS = SYSTEM::IOS;
			
			currentItems = new Vector.<uint>();
			currentCorrectItems = new Vector.<uint>();
			
		}
		
		
		/**
		 *   Get the singleton instance of this game
		 */
		public static function get instance():TrashStashGame
		{
			return __instance;
		}
		
		/**
		 *   Initializes the game.  Invoked by the GameContainer.
		 *   @param container The game container that owns the game.
		 */	
		override public function init(gameContainer:GameContainer): void
		{
			super.init(gameContainer);
			
			var tasks:Array = [
				new LoadTask('config', XMLLoader.instance, assetPath + "assets/config.xml", onConfigLoaded),
				new LoadTask('skin', MediaLoader.instance, assetPath + "assets/TrashStashGameSkin.swf", onSkinLoaded)
			];
			
			__taskManager = new TaskManager(tasks);
			__taskManager.addEventListener(TaskManager.ALL_TASKS_DONE, onTasksCompleted);
			__taskManager.startNext();
		}
		
		/**
		 *   Callback when all the tasks has finished
		 *   @param ev Tasks completed event
		 */
		private function onTasksCompleted(ev:Event): void
		{
			if(__isDestroyed) return;
		}
		

		/**
		 *   Media loader callback for skin
		 *   @param result Contains the skin
		 */
		private function onSkinLoaded(result:MediaLoaderResult, task:LoadTask, manager:TaskManager): void
		{
			if(__isDestroyed) return;
			
			assert(result != null, "Media loader result is null, probably bad url");
			
			skin = BindUtils.bind(result.content, TrashStashGameSkin);
			
			assert(skin != null, "Unable to bind the SWF to the code. Make sure the class package matches. Also try rerunning Fluent.");
			
			peepSkin = skin;
			
			skin.init();
		}
		
		private function onConfigLoaded(config:XML, task:LoadTask, manager:TaskManager): void
		{
			if ( __isDestroyed ) return;
			
			log("Got the config file");
			
			assert(config != null, "No config.xml");
			
			var sounds:XMLList = config.sounds;
			SoundManager.instance.loadXMLContext(sounds, null, assetPath + sounds.@baseDir);
			
			
			var levels:XMLList = config.levels;
			
			level1 = levels.level.(@id == "1").category;
			level2 = levels.level.(@id == "2").category;
			level3 = levels.level.(@id == "3").category;
			level4 = levels.level.(@id == "4").category;
			level5 = levels.level.(@id == "5").category;
			level6 = levels.level.(@id == "6").category;
			level7 = levels.level.(@id == "7").category;
		}
		
		public function nextRound(moveOn:Boolean):void
		{
			if(moveOn)
			{
				if(currentLevelId < 7)
				{
					currentLevelId++
				}
				else
				{
					currentLevelId = 1;
				}
			}
			
			var tempLevel:XMLList = this["level" + String(currentLevelId)];
			
			var tempIndex:uint = MathUtils.slowRandomValue(1, tempLevel.length()) - 1;
			currentCorrectItems.length = 0;
			currentItems.length = 0;
			
			currentCategory = tempLevel[tempIndex].@name;
			
			for each(var object:XML in tempLevel[tempIndex].object)
			{
				currentItems.push(uint(object.@frame));
				if(object.@correct == "true")
				{
					currentCorrectItems.push(uint(object.@frame));
					
				}
			}
			
			shuffleVector(currentItems);
			
		}
		
		private function shuffleVector(vector:Vector.<uint>):void
		{
			var i:uint = vector.length;
			
			var j:uint;
			var o:*;
			while (--i)
			{
				j = int(Math.random() * (i + 1));
				if(j >= vector.length)
					j = vector.length - 1;
				o = vector[i];
				vector[i] = vector[j];
				vector[j] = o;
			}
		}

		override public function destroy():void
		{
			if(__isDestroyed) return;
			
			super.destroy();
			
			if(__taskManager)
			{
				__taskManager.removeEventListener(TaskManager.ALL_TASKS_DONE, onTasksCompleted);
				__taskManager.destroy();
				__taskManager = null;
			}
			if(skin)
			{
				skin.destroy();
				skin = null;
			}
		}
	}
}