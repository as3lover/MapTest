/**
 * Created by SalmanPC2 on 10/16/2017.
 */
package Utils
{
import com.greensock.TweenLite;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;

public class ZoomAndMove
{
    private var stage:Stage;
    private var obj:Sprite;
    private var lastScaleX:Number;
    private var lastScaleY:Number;
    private var mouseDown:Boolean;
    private var MouseX:Number;
    private var MouseY:Number;
    private var _onUpdtae:Function;

    public function ZoomAndMove(stage:Stage, obj:Sprite, zoom:Boolean = true, move:Boolean = true, onUpdtae:Function = null)
    {
        if(obj == null || stage == null)
        {
            trace("ERROR >> ZoomAndMove: null object");
            return;
        }
        
        _onUpdtae = onUpdtae;

        this.stage = stage;
        this.obj = obj;

        lastScaleX = obj.scaleX;
        lastScaleY = obj.scaleY;

        if(zoom)
            obj.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);

        //remove
        if(zoom)
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
        //

        if(move)
            obj.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
    }

    private function onDown(event:MouseEvent):void
    {
        mouseDown = true;
        updateMousePos();
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
        obj.startDrag();
        stage.addEventListener(MouseEvent.MOUSE_UP, onUp)
    }

    private function onMove(event:MouseEvent):void
    {
        onUpdtae();
    }

    private function onUp(e:MouseEvent):void
    {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
        mouseDown = false;
        obj.stopDrag();
    }


    private function onWheel(e:MouseEvent):void
    {
        var scale:Number = 1 - (-e.delta / 25);
        lastScaleX = lastScaleX * scale;
        lastScaleY = lastScaleY * scale;

        updateMousePos();

        var moving:Boolean = mouseDown;

        var bmx:Number = obj.mouseX;
        var bmy:Number = obj.mouseY;



        TweenLite.to(obj, .5, {scaleX: lastScaleX, scaleY: lastScaleY, onUpdate:update});

        function update():void
        {
            if(moving != mouseDown)
            {
                if(mouseDown)
                {
                    bmx = obj.mouseX;
                    bmy = obj.mouseY;
                }
                moving = mouseDown
            }

            if(mouseDown)
                updateMousePos();

            obj.x = MouseX - (bmx * obj.scaleX);
            obj.y = MouseY - (bmy * obj.scaleY);

            onUpdtae();

        }
    }

    private function onUpdtae():void
    {
        if(_onUpdtae != null)
            _onUpdtae();
    }

    private function updateMousePos():void
    {
        MouseX = obj.parent.mouseX;
        MouseY = obj.parent.mouseY;
    }
}
}
