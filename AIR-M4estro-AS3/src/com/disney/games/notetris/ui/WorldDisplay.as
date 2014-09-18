package com.disney.games.notetris.ui
{
    import com.disney.OS;
    import com.disney.geom.Vector3;
    import com.disney.loaders.MediaLoaderResult;
    import com.disney.trumpet3d.geom.TextureCoordinate;
    import com.disney.trumpet3d.geom.Tri;
    import com.disney.trumpet3d.objects.Plane;
    import com.disney.trumpet3d.objects.WorldObject;
    import com.disney.trumpet3d.objects.skeletal.SkeletalAnimation;
    import com.disney.trumpet3d.objects.skeletal.SkeletalAnimationData;
    import com.disney.trumpet3d.objects.skeletal.SkeletalModel;
    import com.disney.trumpet3d.objects.skeletal.SkeletalModelAnimation;
    import com.disney.trumpet3d.pipeline.Screen;
    import com.disney.trumpet3d.pipeline.VectorLayer;
    import com.disney.trumpet3d.pipeline.World;
    import com.disney.trumpet3d.pipeline.WorldCamera;
    import com.disney.trumpet3d.pipeline.WorldCameraPerspective;
    import com.disney.ui.UIControl;
    import com.disney.util.SuperFunction;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.events.MouseEvent;

    /**
     * Display 3D object in the Game.
     */
    public class WorldDisplay extends UIControl
    {
        /** The ground object in the world. **/
        private var ground:WorldObject;

        /** World Texture bitmap data. */
        private var texture:BitmapData;

        /** World the model is in */
        public var world:World;

        /** The stone model. */
        public var stonModel:SkeletalModel;

        /** If we should be updating Trumpet every frame */
        private var __updateTrumpet:Boolean;

        /** Function handler **/
        private var __mouseMoveListener:Function;

        /** Wind set **/
        private var __wind:Vector3;

        /** Ticks to change the wind **/
        private var __ticks:Number = 0;

        /** Death animation **/
        public var animationData:SkeletalAnimationData;

        /** Lock the death animation **/
        public var lock:Boolean = false;

        /** base wind step **/
        private var BASE_STEP:Number = 0.40;

        /**
         * Init.
         */
        public function WorldDisplay()
        {
            super();
        }

        /**
         * Init method for the world display.
         */
        public function init():void
        {
            OS.instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            OS.instance.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

            setupTrumpet();
            lock = true;
        }

        private var location:Vector3 = new Vector3();

        /**
         *   Update due to elapsed time
         *   @param elapsed Number of milliseconds elapsed since the last update
         */
        public function update(elapsed:int):void
        {
            __updateTrumpet = __updateTrumpet && (stonModel != null);

            if (__ticks > 100)
            {
                __ticks = 0;

            }

            if (__ticks <= 0)
            {
                var dir1:Number = Math.random() * 2 - 1;

                var dir2:Number = Math.random() * 2 - 1;
                __wind = new Vector3(BASE_STEP * Math.random() * dir1, BASE_STEP * Math.random() * dir2,
                                     0);
            }

            __ticks++;

            if (__updateTrumpet)
            {

                if (!lock)
                {
                    var cameraView:Vector3 = new Vector3(world.camera.viewPoint.x, world.camera.viewPoint.y,
                                                         world.camera.viewPoint.z);

                    cameraView.z = 0;

                    cameraView.unit();

                    if ((!isNaN(cameraView.x) && !isNaN(cameraView.y)))
                    {
                        cameraView.x = -cameraView.x * BASE_STEP + __wind.x;
                        cameraView.y = -cameraView.y * BASE_STEP + __wind.y;


                        stonModel.translation.x += cameraView.x;
                        stonModel.translation.y += cameraView.y; // = __wind;

                    }
                    else
                    {
                        cameraView.x = __wind.x;
                        cameraView.y = __wind.y;
                        stonModel.translation.x += cameraView.x;
                        stonModel.translation.y += cameraView.y; // = __wind;
                    }

                    location.x += cameraView.x;
                    location.y += cameraView.y;

                    if ((Math.abs(stonModel.translation.y) > 42 || Math.abs(stonModel.translation.x) >
                        42) && animationData)
                    {
                        ani.looping = false;
                        ani.playing = true;
                        stonModel.addAnimation(ani);
                        __updateTrumpet = true;
                        lock = true;
                        onAnimationDone(null);

                    }
                }
                world.update(elapsed);
                world.render();
            }
        }

        /**
         * Model animation.
         */
        private var ani:SkeletalModelAnimation;

        /**
         * Init the game for the given speed.
         * @param speed speed.
         */
        public function initGame(speed:int = 1):void
        {
            BASE_STEP = 0.50 * (1 + speed / 2);

            if (stonModel)
            {
                stonModel.translation = new Vector3(0, 0, 0);

                stonModel.clearAnimation();
            }
        }

        /**
         * Dispatch game over.
         */
        private function onAnimationDone(event:Event):void
        {
            dispatchEvent(new Event("gameOver"));
        }

        /**
         * Generate the animation of the model.
         */
        public function generateAnimation():void
        {
            if (!stonModel || !animationData)
            {
                return;
            }

            var anim:SkeletalAnimation = animationData.realize(stonModel.skeletalModelData.skeleton);
            ani = new SkeletalModelAnimation(stonModel, anim);
//			stonModel.addEventListener("onAnimationDone", onAnimationDone);
        }

        /**
         * Generate the stone in the map.
         */
        public function generateStone():void
        {
            // For test.
            if (!stonModel)
            {
                return;
            }
            stonModel.scale = new Vector3(40, 40, 40);
            stonModel.texture = texture;
            stonModel.layer = world.screen.getLayer(0);
            stonModel.axis = world.camera.upDir.clone();
            stonModel.castsShadow = false;
            stonModel.shadowColor = 0xff0000;
            stonModel.color = 0xffff00;
            stonModel.translation = new Vector3(0, 0, 0);
            stonModel.usingXYZ = true;
            stonModel.xRotation = Math.PI / 2;

            if (!ani)
            {
                generateAnimation();
            }
            world.addObject(stonModel);
            __updateTrumpet = true;
        }

        /**
         *   Set if Trumpet should be updated every frame or not
         *   @param enabled If Trumpet should be updated every frame or not
         */
        public function set updateTrumpet(enabled:Boolean):void
        {
            __updateTrumpet = enabled;
        }

        /**
         *   Setup trumpet for display
         */
        public function setupTrumpet():void
        {
            // Set up the 3D World
            var screen:Screen = new Screen(OS.instance.stage.stageWidth, OS.instance.stage.stageHeight);
            // add a high perfomance 3D layer (fills per triangle)
            screen.layersSprite.addChild(new VectorLayer());
            // add a high quality 3D layer (fills per pixel)
            //screen.layersSprite.addChild(new BitmapLayer(screen.viewportWidth, screen.viewportHeight, 0x000000));

            // 3D Camera
            var camera:WorldCameraPerspective = new WorldCameraPerspective(Math.PI / 4, // FOV
                                                                           1, // Near clipping plane - must be > 0 
                                                                           5000, // Far clipping plane
                                                                           screen.aspect, // Aspect ratio
                                                                           new Vector3(0, 0, 150), // Camera eye
                                                                           new Vector3(0, 0, 0), // Camera target
                                                                           new Vector3(0, -1, 0) // Up vector
                                                                           );

            // Initialize the Trumpet 3D world
            world = new World(screen, camera, null);

            addChild(world);

            __updateTrumpet = true;

            ground = new Plane();

            var tri:Tri = ground.tris[0] as Tri;
            tri.t1 = new TextureCoordinate(0, 0, 0, 0);
            tri.t2 = new TextureCoordinate(0, 1, 0, 0);
            tri.t3 = new TextureCoordinate(1, 1, 0, 0);

            tri = ground.tris[1] as Tri;
            tri.t1 = new TextureCoordinate(0, 0, 0, 0);
            tri.t2 = new TextureCoordinate(1, 0, 0, 0);
            tri.t3 = new TextureCoordinate(1, 1, 0, 0);

            ground.scale = new Vector3(100, 100, 100);
            ground.texture = texture;
            ground.layer = screen.getLayer(0);
            ground.axis = camera.upDir.clone();
            ground.castsShadow = false;
            ground.shadowColor = 0xff0000;
            ground.color = 0xffff00;
            ground.translation = new Vector3(0, 0, -10);

            if (texture)
            {
                ground.texture = texture;
            }
            world.addObject(ground);


        }







        /**
         *   Callback for when the mouse is moved while pressed
         *   @param ev Mouse move event
         *   @param downX X position the mouse was pressed at
         *   @param downY Y position the mouse was pressed at
         *   @param initYaw Yaw angle of the model when the mouse was pressed
         *   @param initPitch Pitch angle of the model when the mouse was pressed
         *   @param initViewPoint View point when the mouse was pressed
         *   @param initAtPoint At point when the mouse was pressed
         */
        private function onMouseMove(ev:MouseEvent, downX:Number, downY:Number, initYaw:Number, initPitch:Number,
                                     initViewPoint:Vector3, initAtPoint:Vector3):void
        {

            var screen:Screen = world.screen;
            var camera:WorldCamera = world.camera;


            var newYaw:Number = initYaw + ((downX - mouseX) / screen.width) * (2 * Math.PI);
            var newPitch:Number = initPitch + ((downY - mouseY) / screen.height) * Math.PI;

            if (Math.abs(newYaw * 180 / Math.PI) > 20 || newPitch * 180 / Math.PI < 70 || newPitch *
                180 / Math.PI > 110)
            {
                return;
            }
//			log(newYaw + ", " + newPitch);
            camera.viewPoint = new Vector3(Math.sin(newPitch) * Math.sin(newYaw), Math.cos(newPitch),
                                           Math.sin(newPitch) * Math.cos(newYaw)).unit().times(camera.viewPoint.magnitude());

            __updateTrumpet = true;
        }


        /**
         *   Callback for when the mouse is wheeled
         *   @param ev Wheel event
         */
        private function onMouseWheel(ev:MouseEvent):void
        {
            var screen:Screen = world.screen;
            var camera:WorldCamera = world.camera;

            const factor:Number = 1;

            var delta:Number = -(ev.delta / Math.abs(ev.delta)) * factor;
            var toAt:Vector3 = camera.viewPoint.clone().minus(camera.atPoint).unit();
            camera.viewPoint = camera.viewPoint.clone().plus(toAt.clone().times(delta));

            log("Change to view point to " + camera.viewPoint.x + ", " + camera.viewPoint.y + ", " +
                camera.viewPoint.z, "NoteTris");

            __updateTrumpet = true;
        }

        /**
         *   Callback for when the mouse is pressed down
         *   @param ev Mouse down event
         */
        private function onMouseDown(ev:MouseEvent):void
        {
            if (!world || world.objects.length <= 0)
            {
                return;
            }

            var camera:WorldCamera = this.world.camera;
            __mouseMoveListener = SuperFunction.create(this, onMouseMove, ev.localX, ev.localY, Math.atan2(camera.viewPoint.x,
                                                                                                           camera.viewPoint.z),
                                                       Math.atan2(Math.sqrt(camera.viewPoint.z * camera.viewPoint.z +
                                                                            camera.viewPoint.x * camera.viewPoint.x),
                                                                  camera.viewPoint.y), camera.viewPoint.clone(),
                                                       camera.atPoint.clone());
            OS.instance.stage.addEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveListener);
            OS.instance.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            OS.instance.stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseUp);

        }

        /**
         *   Callback for when the mouse is released
         *   @param ev Mouse up event
         */
        private function onMouseUp(ev:MouseEvent):void
        {
            // We often get notified when it leaves non-stage things
            if (ev.type == MouseEvent.MOUSE_OUT && ev.target != stage)
            {
                return;
            }

            OS.instance.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            OS.instance.stage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseUp);
            OS.instance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveListener);
            __mouseMoveListener = null;

        }



        /**
         * Remove the event lisenter.
         */
        public function destoryWorld():void
        {


            OS.instance.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            OS.instance.stage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseUp);
            OS.instance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveListener);

            OS.instance.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            OS.instance.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

            if (world)
            {
                world.removeAllEventListeners();
                world.removeAllObjects();
                world.destroy();
            }

            if (ground)
            {
                ground.removeAllEventListeners();
                ground.destroy();
            }

            if (stonModel)
            {
                stonModel.clearAnimation();
                stonModel.removeAllEventListeners();
                stonModel.destroy();
                stonModel = null;

                if (ani)
                {
                    ani.destroy();
                    ani = null;
                }
            }

            if (animationData)
            {
                animationData.destroy();
                animationData = null;
            }

            super.destroy();
        }


    }
}