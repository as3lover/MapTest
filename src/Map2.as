/**
 * Created by SalmanPC2 on 10/17/2017.
 * 
 */
package
{
import Utils.LatLong;
import Utils.MapUtils;
import Utils.ZoomAndMove;

import flash.display.Bitmap;

import flash.display.Loader;
import flash.display.Shape;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.net.URLRequest;

public class Map2 extends Sprite
{
    private const MAX_LEVEL:uint = 21;
    private const MIN_LEVEL:uint = 1;
    private var levels:Array = new Array((MAX_LEVEL - MIN_LEVEL + 1));
    private var map:Sprite = new Sprite();

    private var _level:uint = 0;
    private const defaultSize:int = 1024;
    private const BaseWidth:uint = 256;
    private var tileWidth:uint = BaseWidth * 2;
    private const GoogleLogoHeight:uint = 23;
    private const stageWidth:uint = 1000;
    private const stageHeight:uint = 800;
    private var loadList:Array = new Array();
    private var loading:Boolean = false;
    public static const KEY:String = "AIzaSyBDHNAK8c5LnvhuGY33vXgG8HeIN6JQcAo";
    private var images:Object = new Object();
    
    public function Map2()
    {
        this.addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void
    {
        addChild(map);
        new ZoomAndMove(stage, map, true, true, refresh);
        refresh();

    }

    private function refresh():void
    {
        if(setLevel())
            create();
    }

    private function create():void
    {
        var tiles:int = Math.pow(2,level);

        var i:Number;
        var j:Number;
        var tileMid:int = tileWidth/2;
        var centerX:int;
        var centerY:int;
        var tileX:int;
        var tileY:int;
        var centerLat:Number;
        var centerLong:Number;


        for(j = 0; j<tiles*2; j += (tileWidth-GoogleLogoHeight-1)/tileWidth)
        {
            for(i = 0; i<tiles*2; i += (tileWidth-1)/tileWidth)
            {
                centerX = ((i*2) +1)* tileMid;
                centerY = ((j*2) +1)* tileMid;

                tileX = i * tileWidth;
                tileY = j * tileWidth;

                var coordinate:LatLong = MapUtils.toLatLong(centerX, centerY, level);
                centerLat = coordinate.latitude;
                centerLong = coordinate.longitude;

                if(tileX >= mapWidth - tileMid)
                {
                    i = tiles*2;
                    continue;
                }

                if (tileY >= mapWidth)
                {
                    return;
                }

                var name:String = "img" + String(level) + "l" +String(centerLat) + "g" +String(centerLong) + "i" + String(i) +"j" + String(j);

                var startX:Number;
                var startY:Number;
                var endX:int;
                var endY:int;

                var startPoint:Point =  new Point(0, 0);
                var endPoint:Point =  new Point(stageWidth, stageHeight);

                startPoint = topSheet.globalToLocal(startPoint);
                endPoint = topSheet.globalToLocal(endPoint);

                startX = startPoint.x;
                startY = startPoint.y;

                endX = endPoint.x;
                endY = endPoint.y;


                if(tileX+tileWidth > startX && tileX < endX && tileY+tileWidth > startY && tileY < endY)
                    loadImage(name, centerLat, centerLong, level, tileX, tileY);
            }
        }
    }

    private function loadImage(name:String, lat:Number, long:Number, level:uint = 18, x:int=0, y:int=0):void
    {
        loadList.push({lat:lat, long:long, x:x, y:y, name:name, level:level});
        load()
    }

    function load()
    {
        if(loading || loadList.length == 0)
            return;

        loading = true;
        var l = loadList[0];
        loadList.removeAt(0);

        var lat = l.lat;
        var long = l.long;
        var x = l.x;
        var y = l.y;
        var name = l.name;
        var level = l.level;

        var url:String = "https://maps.googleapis.com/maps/api/staticmap?";
        url += "center=" + lat + "," + long + "&zoom=" + level +"&size=" + tileWidth + "x" + tileWidth + "&key=" + KEY;



        if (images[name] != null)
        {
            var img:Sprite = images[name];

            levelSheet(level).addChild(img);

            loading = false;

            if(loadList.length)
                load();

            return;
        }

        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
        loader.load(new URLRequest(url));


        function imageLoaded(e:Event):void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
            var bit = Bitmap(e.currentTarget.content);
            addImage(bit, lat, long, level, x, y, name);
        }
    }

    private function addImage(img:Bitmap, lat:Number, long:Number, level:uint, x:int, y:int, name:String):void
    {
        var holder:Sprite = new Sprite();
        holder.addChild(img);

        var mask:Shape = new Shape();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(0,0,img.width, img.height - GoogleLogoHeight);
        mask.graphics.endFill();
        holder.addChild(mask);

        img.mask = mask;

        var sheet:Sprite = levelSheet(level);

        holder.x = x;
        holder.y = y;
        sheet.addChild(holder);
        images[name] = holder;

        loading = false;
        if(loadList.length)
            load()
    }



    private function setLevel():Boolean
    {
        var oldLevel = level;
        level = Math.floor(map.scaleX / 4);

        if (oldLevel == level)
            return false;
        else
            return true;
    }

    public function get level():uint
    {
        return _level;
    }

    public function set level(value:uint):void
    {
        if (value < MIN_LEVEL)
            value = MIN_LEVEL;
        else if (value > MAX_LEVEL)
            value = MAX_LEVEL;

        if(value == _level)
            return;

        trace("Change Level", _level, value)
        _level = value;

        setTopSheet();
    }

    private function setTopSheet():void
    {
        map.addChild(topSheet);
    }

    private function get topSheet():Sprite
    {
        return levelSheet(level);
    }

    private function levelSheet(level:uint):Sprite
    {
        var index = level - MIN_LEVEL;
        var sheet:Sprite = levels[index];
        if (sheet == null)
        {
            sheet = new Sprite();
            levels[index] = sheet;

            var scale:Number = defaultSize / mapWidth;
            sheet.scaleX = sheet.scaleY = scale;
        }

        return sheet
    }

    public function get mapWidth():uint
    {
        var columns:int = Math.pow(2,level) / (tileWidth / BaseWidth);
        return columns * tileWidth;
    }
}
}