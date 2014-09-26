package com.m4estro.games.notetris.control
{
    import com.m4estro.vc.BaseMovieClip;
    import com.JacksonMattJon.ui.buttons.PushButton;
    import com.JacksonMattJon.ui.buttons.PushButtonEvent;

    /**
     * Back end of the game tips.
     */
    public class GameTips extends BaseMovieClip
    {
        /** Previous button. **/
        public var prev:PushButton;

        /** Next button */
        public var next:PushButton;

//		
        /**
         * Init method.
         */
        public function GameTips()
        {
            super();
            stop();
            prev.addEventListener(PushButtonEvent.RELEASE, gotoPrev);
            next.addEventListener(PushButtonEvent.RELEASE, gotoNext);
            prev.enabled = false;
        }

        /**
         * Navigate to the next screen.
         *
         * @param event param
         */
        private function gotoNext(event:PushButtonEvent):void
        {
            if (currentFrame < 3)
            {
                gotoAndStop(currentFrame + 1);
            }

            if (currentFrame >= 3)
            {
                next.enabled = false;
            }
            else
            {
                next.enabled = true;
            }

            if (currentFrame <= 1)
            {
                prev.enabled = false;
            }
            else
            {
                prev.enabled = true;
            }

        }

        /**
         * Navigate to the last screen.
         *
         * @param event param
         */
        private function gotoPrev(event:PushButtonEvent):void
        {
            if (currentFrame > 1)
            {
                gotoAndStop(currentFrame - 1);
            }

            if (currentFrame >= 3)
            {
                next.enabled = false;
            }
            else
            {
                next.enabled = true;
            }

            if (currentFrame <= 1)
            {
                prev.enabled = false;
            }
            else
            {
                prev.enabled = true;
            }

        }

    }
}