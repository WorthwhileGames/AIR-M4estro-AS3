package com.cloudkid.peep.trashstash.ui
{
	import com.cloudkid.OS;
	import com.cloudkid.animation.*;
	import com.cloudkid.base.BaseSprite;
	import com.cloudkid.games.Game;
	import com.cloudkid.peep.peepgame.PeepGameSkin;
	import com.cloudkid.peep.trashstash.MusicLoop;
	import com.cloudkid.peep.trashstash.TrashStashGame;
	import com.cloudkid.sound.SoundManager;
	import com.cloudkid.ui.buttons.Button;
	import com.cloudkid.util.BindUtils;
	import com.cloudkid.util.MathUtils;
	import com.cloudkid.util.SpriteUtils;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.StageWebView;
	import flash.text.ReturnKeyLabel;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	public class TrashStashGameSkin extends PeepGameSkin
	{
		public var startPanel:MovieClip;
		public var gamePanel:GamePanel;

		private var __gameInstance:TrashStashGame = TrashStashGame.instance;
		
		private var __currentSound:String;
		private var __reminderTimer:Timer;
		
		private var __isEnabled:Boolean;
		
		private var __isPerfect:Boolean;
		
		
		public function TrashStashGameSkin()
		{
		}
		
		override public function init():void
		{
			infoPath = "assets/html/index.html";
			startPanel.stop();
			gamePanel.init();
			gamePanel.stop();
			
			__reminderTimer = new Timer(30000);
			__reminderTimer.addEventListener(TimerEvent.TIMER, rememberGoal);

			super.init();
		}
		override public function startIntro():void{
			__isEnabled = true;
			gamePanel.toss.visible = false;
			Animator.play(startPanel, "start", startGame, null, false);
			var sound:MusicLoop = new MusicLoop;
			sound.play(0, int.MAX_VALUE, new SoundTransform(0.15));
		}
		private function startGame():void{
			startPanel.visible = false;
			SoundManager.instance.play("sortingmood", NaN, junkInYerTrunk);
		}
		
		private function junkInYerTrunk():void{
			__isPerfect = true;
			__gameInstance.nextRound(__isPerfect);
			Animator.play(gamePanel.chirp, "start", null, null, false);
			Animator.play(gamePanel.raccoon, "start", playToss, null, false);
		}
		
		private function playToss():void
		{	
			populateTossAnim();
			gamePanel.toss.visible = true;
			playRandomRacoonLine();
			Animator.play(gamePanel.toss, "start", playTossDone, null, false);
			setEnabled(false);
			
		}
		
		private function playTossDone():void{
			populateJunkPile();
			gamePanel.toss.visible = false;
			__currentSound = "canyoufind";
			SoundManager.instance.play("canyoufind", NaN , goalVO);
			__reminderTimer.start();
			Animator.play(gamePanel.chirp, "move", playIdle);
			Animator.play(gamePanel.raccoon, "watch");
		}
		
		private function playIdle():void
		{
			Animator.play(gamePanel.chirp, "wait");
			Animator.play(gamePanel.raccoon, "idle");
		}

		private function playRandomRacoonLine():void
		{
			var tempInt:uint = MathUtils.slowRandomValue(1,3);
			
			switch(tempInt)
			{
				case 1:
				{
					SoundManager.instance.play("raccoon_herecomes");
					break;
				}
				case 2:
				{
					SoundManager.instance.play("raccoon_lookbelow");
					break;
				}
				case 3:
				{
					SoundManager.instance.play("raccoon_watchout");
					break;
				}
					
			}
		}
		
		private function populateTossAnim():void
		{
			var i:uint = 1;
			for each (var itemId:uint in __gameInstance.currentItems)
			{
				gamePanel.toss["fly" + i].gotoAndStop(itemId);
				i++;
			}
		}
		private function populateJunkPile():void{
			
			var i:uint = 1;
			for each (var itemId:uint in __gameInstance.currentItems)
			{
				gamePanel["obj" + i].visible = true;
				gamePanel["obj" + i].gotoAndStop(itemId);
				gamePanel["obj" + i].addEventListener(MouseEvent.MOUSE_DOWN, moveItemToSlot);
				i++;
			}
			setEnabled(false);
			
		}
		
		private function moveItemToSlot(e:MouseEvent):void
		{			
			if(!gamePanel.slot1.visible)
			{
				gamePanel.slot1.gotoAndStop(e.target.currentFrame);
				e.target.visible = false;
				e.target.removeEventListener(MouseEvent.MOUSE_DOWN, moveItemToSlot);
				gamePanel.slot1.visible = true;
				gamePanel.slot1.addEventListener(MouseEvent.MOUSE_DOWN, putItemBack);
				gamePanel.slot1.buttonMode = true;
			}
			else if(!gamePanel.slot2.visible)
			{
				gamePanel.slot2.gotoAndStop(e.target.currentFrame);
				e.target.visible = false;
				e.target.removeEventListener(MouseEvent.MOUSE_DOWN, moveItemToSlot);
				gamePanel.slot2.visible = true;
				gamePanel.slot2.addEventListener(MouseEvent.MOUSE_DOWN, putItemBack);
				gamePanel.slot2.buttonMode = true;
			}
			else if(!gamePanel.slot3.visible)
			{
				gamePanel.slot3.gotoAndStop(e.target.currentFrame);
				e.target.visible = false;
				e.target.removeEventListener(MouseEvent.MOUSE_DOWN, moveItemToSlot);
				gamePanel.slot3.visible = true;
				gamePanel.slot3.addEventListener(MouseEvent.MOUSE_DOWN, putItemBack);
				gamePanel.slot3.buttonMode = true;
			}
			else if(!gamePanel.slot4.visible)
			{
				gamePanel.slot4.gotoAndStop(e.target.currentFrame);
				e.target.visible = false;
				e.target.removeEventListener(MouseEvent.MOUSE_DOWN, moveItemToSlot);
				gamePanel.slot4.visible = true;
				gamePanel.slot4.addEventListener(MouseEvent.MOUSE_DOWN, putItemBack);
				gamePanel.slot4.buttonMode = true;
			}
			else
			{
				if(SoundManager.instance.isSoundPlaying(__currentSound))
					SoundManager.instance.stop(__currentSound);
					
				__currentSound = "putback";
				SoundManager.instance.play("putback");
			}
			
			if(gamePanel.slot1.visible && gamePanel.slot2.visible && gamePanel.slot3.visible && gamePanel.slot4.visible)
			{
				setEnabled(false);
				checkAnswers();
			}
		}
		
		private function putItemBack(e:MouseEvent):void
		{
			var itemId:uint = e.target.currentFrame;
			var i:uint = 1;
			e.target.removeEventListener(MouseEvent.MOUSE_DOWN, putItemBack);
			e.target.visible = false;
			setEnabled(true);
			for each (var item:uint in __gameInstance.currentItems)
			{
				if(!gamePanel["obj" + i].visible && gamePanel["obj" + i].currentFrame == itemId)
				{
					gamePanel["obj" + i].visible = true;
					gamePanel["obj" + i].addEventListener(MouseEvent.MOUSE_DOWN, moveItemToSlot);
				}
				i++;
			}
		}
		
		private function checkAnswers():void
		{
			var numRight:uint = 0;
			
			for each(var correctId:uint in __gameInstance.currentCorrectItems)
			{
				if(gamePanel.slot1.currentFrame == correctId)
				{
					numRight++
				}
				if(gamePanel.slot2.currentFrame == correctId)
				{
					numRight++
				}
				if(gamePanel.slot3.currentFrame == correctId)
				{
					numRight++
				}
				if(gamePanel.slot4.currentFrame == correctId)
				{
					numRight++
				}
			}
			
			if(numRight >= 4)
			{
				gamePanel.slot1.mouseEnabled = gamePanel.slot2.mouseEnabled = gamePanel.slot3.mouseEnabled = gamePanel.slot4.mouseEnabled = false;
				if(SoundManager.instance.isSoundPlaying(__currentSound))
					SoundManager.instance.stop(__currentSound);
					
				__currentSound = "foundfour";
				Animator.play(gamePanel.chirp, "success");
				SoundManager.instance.play("foundfour", NaN , letsGoAgain);
			}
			else if(numRight == 3)
			{
				if(SoundManager.instance.isSoundPlaying(__currentSound))
					SoundManager.instance.stop(__currentSound);
					
				__currentSound = "3right";
				SoundManager.instance.play("3right", NaN , putBackVO);
			}
			else if(numRight == 2)
			{
				if(SoundManager.instance.isSoundPlaying(__currentSound))
					SoundManager.instance.stop(__currentSound);
					
				__currentSound = "2right";
				SoundManager.instance.play("2right", NaN , putBackVO);
			}
			else if(numRight == 1)
			{
				if(SoundManager.instance.isSoundPlaying(__currentSound))
					SoundManager.instance.stop(__currentSound);
					
				__currentSound = "1right";
				SoundManager.instance.play("1right", NaN , putBackVO);
			}
			else
			{
				if(SoundManager.instance.isSoundPlaying(__currentSound))
					SoundManager.instance.stop(__currentSound);
					
				__currentSound = "0right";
				SoundManager.instance.play("0right", NaN , putBackVO);
			}
			if(__isPerfect)
				__isPerfect = numRight >= 4;
		}
		
		private function putBackVO():void
		{
			if(SoundManager.instance.isSoundPlaying(__currentSound))
				SoundManager.instance.stop(__currentSound);
				
			__currentSound = "putback";	
			SoundManager.instance.play("putback");
		}
		private function rememberGoal(e:TimerEvent = null):void{
			if(!SoundManager.instance.isSoundPlaying(__currentSound))
			{
				__currentSound = "remember";
				SoundManager.instance.play("remember", NaN , goalVO);
			}			
		}
		private function goalVO():void
		{
			if(SoundManager.instance.isSoundPlaying(__currentSound))
				SoundManager.instance.stop(__currentSound);
				
			__currentSound = __gameInstance.currentCategory;
			SoundManager.instance.play(__gameInstance.currentCategory);
			
			setEnabled(true);
		}
		private function letsGoAgain():void
		{
			var coinFlip:Boolean = MathUtils.slowRandomValue(0,1) == 1;
			if(SoundManager.instance.isSoundPlaying(__currentSound))
				SoundManager.instance.stop(__currentSound);
			if(coinFlip)
			{
				__currentSound = "goagain";
				SoundManager.instance.play("goagain", NaN, cleanUpAndMoveOn);
			}
			else
			{
				__currentSound = "goagain2";
				SoundManager.instance.play("goagain2", NaN, cleanUpAndMoveOn);
			}
			
		}
		
		private function cleanUpAndMoveOn():void
		{
			gamePanel.slot1.mouseEnabled = gamePanel.slot2.mouseEnabled = gamePanel.slot3.mouseEnabled = gamePanel.slot4.mouseEnabled = true;
			
			__reminderTimer.reset();
			__gameInstance.nextRound(__isPerfect);
			__isPerfect = true;
			playToss();
			gamePanel.slot1.visible = gamePanel.slot2.visible = gamePanel.slot3.visible = gamePanel.slot4.visible = false;
		}

		override public function setPaused(paused:Boolean):void
		{
			super.setPaused(paused);
			if(paused)
			{
				__reminderTimer.stop();
			}
			else
			{
				__reminderTimer.start();
			}
		}
		
		public function setEnabled(enable:Boolean):void
		{
			if(__isEnabled == enable)
				return;
			
			for(var i:uint = 0; i< __gameInstance.currentItems.length; i++)
			{
				gamePanel["obj" + String(i + 1)].mouseEnabled = enable;
				gamePanel["obj" + String(i + 1)].buttonMode = enable;
			}
			//gamePanel.mouseEnabled = enable;
			__isEnabled = enable;
		}
		
	}
}