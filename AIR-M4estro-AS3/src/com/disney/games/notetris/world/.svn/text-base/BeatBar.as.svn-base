package com.disney.games.notetris.world 
{
	import com.disney.base.BaseMovieClip;
	import com.disney.games.notetris.control.GameTimer;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class BeatBar extends BaseMovieClip
	{
		public static var BEATBAR_WIDTH:int;
		public static var BEATBAR_HEIGHT:int;
		
		private var __bpm:Number;
		private var __millisecondsPerBeat:int;
		private var __beatTimer:GameTimer;
		
		
		public var playHead:MovieClip;
		
		public function BeatBar() 
		{
			BEATBAR_WIDTH = this.width;
			BEATBAR_HEIGHT = this.height;
		}
		
		public function init(): void
		{
			__bpm = 98;
			__millisecondsPerBeat = (60 / __bpm) * 1000;
			__beatTimer = new GameTimer(__millisecondsPerBeat);
			
			
		}
		
		public function update(elapsed:Number): void
		{
			if (__beatTimer.isExpired())
			{
				__beatTimer.restartTimer();
				//__soundController.playSound("shoot", false);
			}
			
			//log("BeatBar: syncPosition: " + soundToSync.position + ", " + soundToSync.length, "NoteTrisSound");
			
			//playHead.x = (soundToSync.position / soundToSync.length) * BEATBAR_WIDTH;

		}
	}
	
}