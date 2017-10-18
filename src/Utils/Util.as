/**
 * Created by Morteza on 4/4/2017.
 */
package Utils
{
import com.adobe.images.PNGEncoder;
import com.greensock.TweenMax;
import com.greensock.plugins.ColorTransformPlugin;
import com.greensock.plugins.TintPlugin;
import com.greensock.plugins.TweenPlugin;

import fl.text.TLFTextField;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.OutputProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.ByteArray;

public class Util
{
    public function Util()
    {
    }

    //convert time format to Number data type
    public static function timeToSec(t:Object):Number
    {
        if (t is Number)
            return Number(t);
        else if (t is String)
        {
            var parts:Array=new Array(3);
            parts=t.split(":",3);
            if (parts[1]==undefined)
                return Number(parts[0]);
            else if (parts[2]==undefined)
                return Number(parts[0])*60+Number(parts[1]);
            else
                return Number(parts[0])*3600+Number(parts[1])*60+Number(parts[2]);
        }
        else
        {
            trace("time type is wrong!");
            return 0;
        }
    }


    /////////////////////// milli Sec to String
    public static function timeFormat(milliSeconds:Number):String
    {
        var t:int = milliSeconds;
        if (t < 1 * 60 * 60 * 1000)
        {
            return addZero(t / 1000 / 60) + " : " + addZero(t / 1000 % 60);
        }
        else
        {
            return String(int(t / 1000 / 60 / 60)) + " : " + addZero(t / 1000 % 3600 / 60)+ " : " + addZero(t / 1000 % 60);
        }
    }

    /////////////// addZero
    public static function addZero(num:Number):String
    {
        if ((num < 10))
        {
            return "0" + int(num);
        }
        else
        {
            return String(int(num));
        }
    }

    public static function drawRect(object:Object, x:int, y:int, width:int, height:int, color:int = 0x333333):void
    {
        object.graphics.beginFill(color);
        object.graphics.drawRect(x, y, width, height);
        object.graphics.endFill();
    }


    public static function removeObjectFromArray(list:Array, item:Object):Boolean
    {
        var length:int = list.length
        for (var i: int = 0; i < length; i++)
        {
            if (list[i] == item)
            {
                removeItemAtIndex(list, i)
                return true;
            }
        }

        return false;
    }

    public static function removeItemAtIndex(list:Array, index:int):void
    {
        list.splice(index, 1);
    }

    public static function pushAtIndex(list:Array, index:int, item:Object):void
    {
        list.splice(index,0, item);
    }

    ///////////////////
    public static function StringToBitmap(text:String, color:uint=0xffffff, font:String="B Yekan", size:int=14 ,width:int= 260, height:int=35):Bitmap
    {
        var fmt:TextFormat = new TextFormat();
        fmt.color = color;
        fmt.font = font;
        fmt.size = size * 3;
        fmt.leftMargin = 0;
        fmt.align = TextFormatAlign.LEFT;

        var txt:TLFTextField = new TLFTextField ;
        txt.defaultTextFormat = fmt;
        txt.width = 1000;
        txt.height = 1000;
        txt.wordWrap = true;
        txt.multiline = true;
        txt.embedFonts = true;
        txt.condenseWhite = true;
        txt.autoSize = TextFieldAutoSize.RIGHT;
        txt.text = text;
        txt.cacheAsBitmap = true;

        var sprite:Sprite = new Sprite();
        sprite.addChild(txt);
        var snapshot:BitmapData = new BitmapData(txt.textWidth, txt.textHeight, true, 0x00000000);
        snapshot.draw(sprite, new Matrix());
        var bit:Bitmap = new Bitmap(snapshot);
        bit.smoothing = true;

        sprite.removeChild(txt);
        sprite.addChild(bit);

        bit.scaleX = bit.scaleY = 1/3;

        return bit;
    }

    public static function textBoxToBitmap(textBox, quality:Number = 3):Bitmap
    {
        if(Main.STAGE)
            Main.STAGE.focus = null;

        if(textBox.textWidth < 1 || textBox.textHeight < 1)
        {
            textBox.text = 'متن پیش فرض';
            trace('ERRORR متنی وجود ندارد')
        }

        var x:Number = textBox.x;
        var y:Number = textBox.y;
        var border:Boolean = textBox.border;
        var scale:Number = textBox.scaleX;
        var parent:Object;
        var index:int;
        if(textBox.parent)
        {
            parent = textBox.parent;
            index = parent.getChildIndex(textBox);
        }
        textBox.scaleX = textBox.scaleY = scale * quality;
        textBox.y = 0;
        //textBox.x = - (textBox.width - textBox.textWidth * quality);
        textBox.x = 0;
        textBox.border = false;

        //var padding:int = 50;
        //textBox.x += padding;

        var sprite:Sprite = new Sprite();
        sprite.addChild(textBox);

        //var snapshot:BitmapData = new BitmapData(textBox.textWidth * quality, padding + textBox.textHeight * quality, true, 0x00000000);
        var snapshot:BitmapData = new BitmapData(textBox.width, textBox.height, true, 0x00000000);
        snapshot.draw(sprite, new Matrix());

        //var bit:Bitmap = new Bitmap(snapshot);
        var bit:Bitmap = new Bitmap(trimAlpha(snapshot));
        bit.smoothing = true;

        textBox.scaleX = textBox.scaleY = scale;
        textBox.border = border;
        textBox.x = x;
        textBox.y = y;
        if(parent)
            parent.addChildAt(textBox, index);

        bit.scaleX = bit.scaleY = 1/quality;
        return bit;
    }

    public static function trimAlpha(source:BitmapData):BitmapData
    {
        var notAlphaBounds:Rectangle = source.getColorBoundsRect(0xFF000000, 0x00000000, false);
        var trimed:BitmapData = new BitmapData(notAlphaBounds.width, notAlphaBounds.height, true, 0x00000000);
        trimed.copyPixels(source, notAlphaBounds, new Point());
        return trimed;
    }

    public static function isParentOf(stage:Stage, parent:Object, child:DisplayObject):DisplayObject
    {
        if(child && child.parent && child.parent != stage)
        {
            if(
                    (parent is Class && child.parent is (parent as Class))
                    || (parent is DisplayObject && child.parent == parent)
                                                                                )
            {
                return child.parent;
            }
            else
            {
                return isParentOf(stage, parent, child.parent);
            }
        }
        else
        {
            return null;
        }
    }

    public static function traceParents(obj:DisplayObject, tab:String = ''):void
    {
        trace(tab , obj, obj.name);
        if(obj.parent)
                traceParents(obj.parent, tab + '\t')
    }



    public static function getObjectIndex(list:Array, item:Object):int
    {
        var length:int = list.length;
        for (var i: int = 0; i < length; i++)
        {
            if (list[i] == item)
            {
                return i;
            }
        }

        return -1;
    }

    public static function tint(item:Object, alpha:Number =.5, color:uint = 0xff0000, duration:Number = 0):void
    {
        TweenPlugin.activate([TintPlugin, ColorTransformPlugin]);
        TweenMax.to(item, duration, {colorTransform:{tint:color, tintAmount:alpha}});
    }

    public static function drawCirc(object:Object, x:int, y:int, radius:int, color:int = 0x333333):void
    {
        object.graphics.beginFill(color);
        object.graphics.drawCircle(x, y, radius);
        object.graphics.endFill();
    }


    public static function targetClass(target:DisplayObject, classType:Class):DisplayObject
    {
        if(target is classType)
                return target;

        return Util.isParentOf(Main.STAGE, classType, target)
    }

    public static function globalToLocalScaleX(item:DisplayObject):Number
    {
        var scale:Number = item.scaleX;
        while(item.parent)
        {
            item = item.parent;
            scale *= item.scaleX;
        }

        return scale;
    }

    public static function globalToLocalScaleY(item:DisplayObject):Number
    {
        var scale:Number = item.scaleY;
        while(item.parent)
        {
            item = item.parent;
            scale *= item.scaleY;
        }

        return scale;
    }

    public static function distanceTwoPoints(x1:Number, y1:Number,  x2:Number, y2:Number):Number
    {
        var dx:Number = x1-x2;
        var dy:Number = y1-y2;
        return Math.sqrt(dx * dx + dy * dy);
    }

    public static function radToDeg(radians:Number):Number
    {
        return radians * 180 / Math.PI;
    }

    public static function degToRad(degree:Number):Number
    {

        return degree * Math.PI / 180;
    }

    public static function pathIsWrong(path:String):Boolean
    {
        for(var i:int = 0; i<path.length; i++)
        {
            if(path.charCodeAt(i) > 1000)
            {
                return true;
            }
        }

        return false;
    }

    public static function isVisible(object:Object):Boolean
    {
        if(object && object is DisplayObject && object.stage)
        {
            var stage:Stage = object.stage;
            while(object != stage)
            {
                if(!object.visible)
                    return false;

                object = object.parent;
            }

            return true;
        }

        return false;
    }

    public static function swapInArray(list:Array, index1:int, index2:int):void
    {
        var item:Object = list[index1];
        list[index1] = list[index2];
        list[index2] = item;
    }


    ////////////////////////////////////////

    public static function saveBitmap(bitmap:DisplayObject, path:String, after:Function):void
    {
        var scaleX:Number = bitmap.scaleX;
        var scaleY:Number = bitmap.scaleY;
        var rotation:Number = bitmap.rotation;

        bitmap.rotation = 0;
        bitmap.scaleX = bitmap.scaleY = 1;

        trace('TEXT SIZE', bitmap.width, bitmap.height);

        var bytes:ByteArray = bitmapToBinary(bitmap);

        bitmap.scaleX = scaleX;
        bitmap.scaleY = scaleY;
        bitmap.rotation = rotation;

        var file:File = new File(path);
        var myStream:FileStream = new FileStream();
        myStream.openAsync(file, FileMode.WRITE);
        myStream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, PROGRESS);
        myStream.addEventListener(Event.CLOSE, CLOSE);
        myStream.writeBytes(bytes);
        myStream.close();

        function PROGRESS(e)
        {
            //trace('PROGRESS', e);
        }

        function CLOSE(e)
        {
            //trace('CLOSE', e);
            after();
        }
    }

    private static function bitmapToBinary(bitmap:DisplayObject):ByteArray
    {
        return PNGEncoder.encode(bitmapToData(bitmap))
    }

    private static function bitmapToData(bit:DisplayObject):BitmapData
    {
        var data:BitmapData = new BitmapData(bit.width, bit.height, true, 0);
        data.draw(bit);
        return data;
    }

    public static function loadBitmap(path:String, func:Function, smoothing:Boolean = true):void
    {
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedFile);

        loader.load(new URLRequest(path));
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);

        function onError(event:IOErrorEvent):void
        {
            trace('Can Not Load File:', path);
            func(null)
        }

        function loadedFile (event:Event):void
        {
            var bit:Bitmap = Bitmap(LoaderInfo(event.target).content);
            bit.smoothing = smoothing;
            func(bit);
        }
    }

    public static function traceObject(obj:Object, t:String =''):void
    {
        for(var i:String in obj)
        {
            if(obj[i] is Number || obj[i] is String || obj[i] is int || obj[i] is uint || obj[i] is Boolean)
            {
                trace(t,i,obj[i])
            }
            else if(obj[i] is Array)
            {
                trace(t,i,'Array:')
                traceArray(obj[i], t+'\t');
            }
            else
            {
                trace(t,i);
                traceObject(obj[i], t+'\t')
            }
        }
    }

    public static function traceArray(list:Array, t:String=''):void
    {
        for(var i:int=0; i<list.length; i++)
        {
            if(list[i] is Array)
            {
                trace(t,i,'Array:');
                traceArray(list[i], t+'\t');
            }
            else if(list[i] is Number || list[i] is String || list[i] is int || list[i] is uint || list[i] is Boolean)
            {
                trace(t, i, list[i]);
            }
            else
            {
                trace(t,'Object:');
                traceObject(list[i], t+'\t')
            }
        }
    }

    public static function displayMatching(obj1:DisplayObject, obj2:DisplayObject):Number
    {
        var sx1:Number = obj1.scaleX;
        var sy1:Number = obj1.scaleY;
        var sx2:Number = obj2.scaleX;
        var sy2:Number = obj2.scaleY;

        obj1.scaleX = obj1.scaleY = 1;
        obj2.scaleX = obj2.scaleY = 1;

        if(obj1.width != obj2.width || obj1.height != obj2.height)
        {
            ret();
            return 0;
        }

        ret();

        function ret()
        {
            obj1.scaleX = sx1;
            obj2.scaleX = sx2;
            obj1.scaleY = sy1;
            obj2.scaleY = sy2;
        }



        var bitmapData1:BitmapData = displayToBitmapData(obj1);
        var bitmapData2:BitmapData = displayToBitmapData(obj2);


        try
        {
            var bmpDataDif:BitmapData = bitmapData1.compare(bitmapData2) as BitmapData;
        }
        catch (e)
        {
            return 0;
        }

        if(!bmpDataDif)
        {
            var b1:Rectangle = obj1.getBounds(obj1);
            var b2:Rectangle = obj2.getBounds(obj2);
            if(b1.width == b2.width && b1.height == b2.height)
                return 1;
            else
                return 0
        }

        var differentPixelCount:int = 0;

        var pixelVector:Vector.<uint> =  bmpDataDif.getVector(bmpDataDif.rect);
        var pixelCount:int = pixelVector.length;


        for (var i:int = 0; i < pixelCount; i++)
        {
            if (pixelVector[i] != 0)
                differentPixelCount ++;
        }
        return (differentPixelCount / pixelCount);
    }

    public static function displayToBitmapData(obj:DisplayObject):BitmapData
    {
        var data:BitmapData;

        if(obj is Bitmap)
        {
            data =  Bitmap(obj).bitmapData;
        }
        else
        {
            data = new BitmapData(obj.width, obj.height);
            data.draw(obj);
        }

        return data;
    }

    public static function objectToBitmap(obj:DisplayObject, width:int=-1, height:int=-1):Bitmap
    {
        if(width == -1)
            width = obj.width;
        if(height == -1)
            height = obj.height;

        var bitmapData:BitmapData = new BitmapData(width, height, true, 0x00000000);
        bitmapData.draw(obj);
        return new Bitmap(bitmapData);
    }


    public static function cloneBitmap(bit:Bitmap):Bitmap
    {
        return new Bitmap(bit.bitmapData);
    }

    public static function globalToLocal(point:Point, sprite:DisplayObject):Point
    {
        var x:Number = point.x;
        var y:Number = point.y;

        var list:Array = [sprite];
        while (sprite.parent != null && !(sprite.parent is Stage))
        {
            sprite = sprite.parent;
            list.push(sprite)
        }

        while(list.length)
        {
            sprite = list.pop();
            x = (x - sprite.x) / sprite.scaleX;
            y = (y - sprite.y) / sprite.scaleY;
        }

        var newPoint:Point = new Point(x, y);
        return newPoint;
    }

    public static function localToGlobal(point:Point, sprite:DisplayObject):Point
    {
        var x:Number = point.x;
        var y:Number = point.y;

        while (sprite != null && !(sprite.parent is Stage))
        {
            x = sprite.x + (x * sprite.scaleX);
            y = sprite.y + (y * sprite.scaleY);

            sprite = sprite.parent;
        }

        var newPoint:Point = new Point(x, y);

        return newPoint;
    }

}
}