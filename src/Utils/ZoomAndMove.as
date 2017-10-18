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
    private var minScale:Number;
    private var maxScale:Number;
    private var insideX:Number;
    private var insideY:Number;

    public function ZoomAndMove(stage:Stage, obj:Sprite, zoom:Boolean = true, move:Boolean = true, onUpdtae:Function = null)
    {
        if(obj == null || stage == null)
        {
            trace("ERROR >> ZoomAndMove: null object");
            return;
        }

        minScale = Math.max(Main.Stage_Width, Main.Stage_Height)/Map2.defaultSize;
        //maxScale = Math.min(Main.Stage_Width, Main.Stage_Height)/Map2.defaultSize;

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
        //TweenLite.killTweensOf(obj);
        //lastScaleX = obj.scaleX;
        //lastScaleY = obj.scaleY;

        insideX = obj.mouseX;
        insideY = obj.mouseY;

        mouseDown = true;
        updateMousePos();
        stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
        stage.addEventListener(MouseEvent.MOUSE_UP, onUp);

        function move(event:MouseEvent):void
        {
            if(!mouseDown)
            {
                onUp(null);
                return;
            }

            updateMousePos();
            obj.x = newX(MouseX - (insideX * obj.scaleX));
            obj.y = newX(MouseY - (insideY * obj.scaleY));
            onUpdate();
        }

        function onUp(e:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);
            mouseDown = false;
            obj.stopDrag();
            onUpdate();
        }
    }

    private function newX(x:Number):Number
    {
        if(x > 0)
            x = 0;
        else if(x + obj.width < Main.Stage_Width)
            x = Main.Stage_Width - obj.width;

        return x
    }

    private function newY(y:Number):Number
    {
        if(y > 0)
            y = 0;
        else if(y + obj.height < Main.Stage_Height)
            y = Main.Stage_Height - obj.height;

        return y
    }


    private function onWheel(e:MouseEvent):void
    {
        var scale:Number = 1 - (-e.delta / 25);

        lastScaleX = lastScaleX * scale;
        lastScaleY = lastScaleY * scale;

        if(lastScaleX < minScale)
            lastScaleX = lastScaleY = minScale;

        updateMousePos();

        var moving:Boolean = mouseDown;

        insideX = obj.mouseX;
        insideY = obj.mouseY;

        TweenLite.to(obj, .5, {scaleX: lastScaleX, scaleY: lastScaleY, onUpdate:update, onComplete:complete});

        function update():void
        {
            if(moving != mouseDown)
            {
                if(mouseDown)
                {
                    insideX = obj.mouseX;
                    insideY = obj.mouseY;
                }
                moving = mouseDown
            }

            if(mouseDown)
                updateMousePos();

            obj.x = newX(MouseX - (insideX * obj.scaleX));
            obj.y = newY(MouseY - (insideY * obj.scaleY));
        }

        function complete():void
        {
            onUpdate();
        }
    }

    private function onUpdate():void
    {
        if(_onUpdtae != null)
            _onUpdtae();
    }

    private function updateMousePos():void
    {
        MouseX = obj.parent.mouseX;
        MouseY = obj.parent.mouseY;
    }

    public function reset():void
    {
        TweenLite.killTweensOf(obj);
        mouseDown = false;
    }
}
}
