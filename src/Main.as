package {

import fl.text.TLFTextField;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;

import flashx.textLayout.edit.EditManager;
import flash.events.KeyboardEvent;

[SWF(width="1000", height="800", frameRate="60", backgroundColor="#808080")]
public class Main extends Sprite
{
    private var i:uint = 0;
    public function Main()
    {
        var map:Map2 = new Map2();
        addChild(map);

        //myFunc();

        if(i == 0)
            return;

        while(numChildren < 5)
        {
            create()
        }

        setFocus(0);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKey)
    }

    private function myFunc():void
    {

        var mapWidth:int = 256;
        var mapHeight:int = 256;

        for (var i:Number = -1000; i<1000; i+=.3)
        {
            var m:Number = i;
            var y:Number = mToY(m);
            m = yToM(y);

            var i2 = Math.round(i);
            m = Math.round(m);

            if(m != i2)
            {
                trace("Error", m,i,y);
            }
            else
            {
                trace("okkkkkkkkkkkkkkkkkk", m,i,y);
            }

        }

        function mToY(m:Number):Number
        {
            return m * Math.PI/180;
            return Math.log(m);
            return (mapHeight/2)-(mapWidth*m/(2*Math.PI))
        }

        function yToM(y:Number):Number
        {
            return (y * 180) / Math.PI;
            return Math.exp(y);
            return (((mapHeight/2) - y) * 2 * Math.PI)/mapWidth;
        }


        /*
        getXY(0,0,256,256)

        function getXY(lat:Number, lng:Number,mapWidth, mapHeight)
        {
            var screenX:Number = ((lng + 180) * (mapWidth  / 360));
            var screenY:Number = (((lat * -1) + 90) * (mapHeight/ 180));

            trace(screenX,screenY);
        }
        */
    }

    private function onKey(e:KeyboardEvent):void
    {
        trace(e.charCode, e.keyCode);
        if (numChildren == 0)
                return;

        if (e.charCode == 9)
        {
            i++;
            if(i >= numChildren)
                    i = 0;
            setFocus(i)
        }
    }

    private function setFocus(i:uint):void
    {
        var tf:TLFTextField = getChildAt(i) as TLFTextField;
        tf.textFlow.interactionManager = new EditManager();
        var index2:uint = tf.text.length;
        tf.textFlow.interactionManager.selectRange(0, index2);
        tf.textFlow.interactionManager.setFocus();
    }

    private function create():void
    {
        var txt:TLFTextField = new TLFTextField();
        //txt.text = "به نام خدا";
        txt.border = true;
        txt.height = 50;
        txt.multiline = false;
        txt.tabEnabled = false;
        txt.tabIndex = numChildren;
        txt.y = height + 5;
        txt.x = 10;
        txt.addEventListener(MouseEvent.MOUSE_UP, onTextClick);
        txt.addEventListener(FocusEvent.FOCUS_IN, onFocus);
        addChild(txt);
    }

    private function onFocus(e:FocusEvent):void
    {
        check(e)
    }

    private function onTextClick(e:MouseEvent):void
    {
        check(e)
    }

    private function check(e:Event):void
    {
        var obj:DisplayObject;
        if (e.target  is DisplayObject)
            obj = e.target as DisplayObject;
        trace(obj);
        while (obj && obj.parent)
        {
            obj = obj.parent;
            if (obj is TLFTextField)
            {
                i = TLFTextField(obj).tabIndex;
                return
            }
        }
    }
}
}
