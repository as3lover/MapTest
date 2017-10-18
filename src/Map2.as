/**
 * Created by SalmanPC2 on 10/17/2017.
 * 
 */
package
{
import Utils.LatLong;
import Utils.MapUtils;
import Utils.MathUtil;
import Utils.Util;
import Utils.ZoomAndMove;

import flash.display.Bitmap;
import flash.display.DisplayObject;

import flash.display.Loader;
import flash.display.Shape;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class Map2 extends Sprite
{
    private const MAX_LEVEL:uint = 21;
    private const MIN_LEVEL:uint = 1;
    private var sheets:Array = new Array((MAX_LEVEL - MIN_LEVEL + 1));
    private var map:Sprite = new Sprite();

    private var _level:uint = 0;
    public static const defaultSize:int = 1024*4;
    private const BaseWidth:uint = 256;
    private var tileWidth:uint = BaseWidth * 2;
    private const GoogleLogoHeight:uint = 23;
    private const stageWidth:uint = Main.Stage_Width;
    private const stageHeight:uint = Main.Stage_Height;
    private var loadList:Array = new Array();
    private var loading:Boolean = false;
    public static const KEY:String = "AIzaSyBDHNAK8c5LnvhuGY33vXgG8HeIN6JQcAo";
    private var images:Object = new Object();
    private var zoomAndMove:ZoomAndMove;
    private var tempTime:int = 0;
    public static var visibles:int = 0;
    private var checkSheetsTimeout:uint;

    public function Map2()
    {
        this.addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void
    {
        addChild(map);
        var mask:Shape = new Shape();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(0,0,defaultSize,defaultSize);
        mask.graphics.endFill();
        map.addChild(mask);
        map.mask = mask;

        zoomAndMove = new ZoomAndMove(stage, map, true, true, refresh);
        refresh();

        stage.addEventListener(MouseEvent.CLICK, onClick)

    }

    private function onClick(event:MouseEvent):void
    {
        trace(map.x, map.y)
    }

    private function refresh():void
    {
        var size:int = defaultSize * map.scaleX;

        if(map.x > 0)
        {
            if(size >= stageWidth)
            {
                map.x = 0;
            }
            else if (map.x + size > stageWidth)
            {
                map.x = stageWidth - size;
            }
        }
        else if(map.x + size < stageWidth)
        {
            map.x = stageWidth - size;
        }

        if(map.y > 0)
        {
            if(size >= stageHeight)
            {
                map.y = 0;
            }
            else if (map.y + size > stageHeight)
            {
                map.y = stageHeight - size;
            }
        }
        else if(map.y + size < stageHeight)
        {
            map.y = stageHeight - size;
        }

        refreshVisibles();

        if(setLevel() || true)
            create();
    }

    private function refreshVisibles():void
    {
        visibles = 0;
        var cnt:int=0;
        for(var i:String in images)
        {
            var holder:Holder = images[i];
            holder.refresh();
            cnt++
        }
        trace("Visibles:", visibles, cnt);
    }

    private function create():void
    {
        trace("create");
        loadList = [];
        //zoomAndMove.reset();
        //map.x = map.y = 0;

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



        var startX:Number;
        var startY:Number;
        var endX:int;
        var endY:int;

        var startPoint:Point =  new Point(0, 0);
        var endPoint:Point =  new Point(stageWidth, stageHeight);

        //startPoint = topSheet.globalToLocal(startPoint);
        //endPoint = topSheet.globalToLocal(endPoint);

        startPoint = Util.globalToLocal(startPoint, topSheet);
        endPoint = Util.globalToLocal(endPoint, topSheet);


        startX = startPoint.x;
        startY = startPoint.y;

        endX = endPoint.x;
        endY = endPoint.y;


        var x1:int;
        var y1:int;

        var x2:int;
        var y2:int;

        x1 = Math.floor(startX / tileWidth);
        y1 = Math.floor(startY / tileWidth);

        x2 = Math.floor(endX / tileWidth);
        y2 = Math.floor(endY / tileWidth);

        trace(topSheet.scaleX, startX, startY, x1, x2, y1, y2, (x2-x1+1)*(y2-y1+1));

        //for(j = y1; j <= y2; j++)
        for(j = y1; j <= y2+1; j += (tileWidth-GoogleLogoHeight-1)/tileWidth)
        {
            //for(i = x1; i <= x2; i++)
            for(i = x1; i <= x2+1; i += (tileWidth-1)/tileWidth)
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

                //if(tileX+tileWidth > startX && tileX < endX && tileY+tileWidth > startY && tileY < endY)
                    loadImage(name, centerLat, centerLong, level, tileX, tileY);
            }
        }
    }



    private function loadImage(name:String, lat:Number, long:Number, level:uint = 18, x:int=0, y:int=0):void
    {
        //trace("push: ", name);
        loadList.push({lat:lat, long:long, x:x, y:y, name:name, level:level});
        setTimeout(load,1)//load()
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
            //trace("exist: ", name);
            var img:Sprite = images[name];

            levelSheet(level).addChild(img);

            loading = false;

            if(loadList.length)
                setTimeout(load,1)//load();
            else
            {
                clearTimeout(checkSheetsTimeout)
                checkSheetsTimeout = setTimeout(checkSheets,10);
            }

            return;
        }

        //trace("load: ", name);

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

    private function checkSheets():void
    {
        clearTimeout(checkSheetsTimeout);

        if (loadList.length)
        {
            checkSheetsTimeout = setTimeout(checkSheets, 100);
            return
        }

        trace("checkSheets");

        for(var i:int = sheets.length-1; i>-1; i--)
        {
            var s:Sprite = sheets[i];
            if(s == null) continue;
            s.visible = false;
        }
        topSheet.visible = true;
        refreshVisibles();
    }



    private function addImage(img:Bitmap, lat:Number, long:Number, level:uint, x:int, y:int, name:String):void
    {
        img.smoothing = true;
        //trace("loaded: ", name);
        var holder:Holder = new Holder();
        holder.addChild(img);

        var mask:Shape = new Shape();
        mask.graphics.beginFill(0);
        //mask.graphics.lineStyle(0)
        mask.graphics.drawRect(0,0,img.width, img.height - GoogleLogoHeight);
        mask.graphics.endFill();
        holder.addChild(mask);
/*
        var line:Shape = new Shape();
        line.graphics.lineStyle(0);
        line.graphics.drawRect(0,0,img.width, img.height - GoogleLogoHeight);
        holder.addChild(line);
*/
        img.mask = mask;

        ////////////
        var temp:Sprite = new Sprite();
        temp.addChild(holder);
        var newBit:Bitmap = Util.objectToBitmap(temp, tileWidth, tileWidth-GoogleLogoHeight);
        newBit.smoothing = true;
        holder.removeChildren();
        holder.addChild(newBit);
        ////////////

        var sheet:Sprite = levelSheet(level);

        holder.x = x;
        holder.y = y;
        sheet.addChild(holder);
        images[name] = holder;

        holder.name = "holder"
        holder.addEventListener(MouseEvent.CLICK, onHolder)

        loading = false;
        if(loadList.length)
            setTimeout(load,1)//load()
        else
            checkSheets();
    }

    private function onHolder(e:MouseEvent):void
    {
        if(e.target.name is Holder)
        {
            var obj:Holder = e.target as Holder;
            trace(obj.x,obj.y,obj.width, obj.height, obj.parent.name)
            //obj.parent.parent.addChild(obj.parent);
            var bit:Bitmap = Util.objectToBitmap(obj);
            bit.x = 1500 - bit.width;
            bit.y = 900 - bit.height;
            stage.removeChildren(1)
            stage.addChild(bit);
        }
    }



    private function setLevel():Boolean
    {
        var oldLevel = level;
        //level = Math.floor(map.scaleX / 4);
        level = getLevelByMapScale(map.scaleX);

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
        value = correctLevel(value);

        if(value == _level)
            return;

        trace("Change Level:", _level, "-->",  value)
        _level = value;

        setTopSheet();
    }

    private function setTopSheet():void
    {
        map.addChild(topSheet);
        topSheet.visible = true;
    }

    private function get topSheet():Sprite
    {
        return levelSheet(level);
    }

    private function levelSheet(level:uint):Sprite
    {
        var index = level - MIN_LEVEL;
        var sheet:Sprite = sheets[index];

        if (sheet == null)
        {
            sheet = new Sprite();
            sheet.name = "sheet " + String(index+1);
            sheets[index] = sheet;

            sheet.scaleX = sheet.scaleY = getSheetScale(level);
        }

        return sheet
    }

    private function getSheetScale(level:uint):Number
    {
        var scale:Number = defaultSize / getMapWidth(level);
        return scale;
    }

    private function getMapWidthByScale(scale:Number):Number
    {
        return defaultSize / scale
    }



    //////////////////////////////
    //////////////////////////////
    //////////////////////////////
    private function getLevelByMapScale(mapScale:Number):uint
    {
        var sheetScale:Number = 0.75 / mapScale;
        return getLevelBySheetScale(sheetScale);
    }

    private function getLevelBySheetScale(sheetScale:Number):uint
    {
        var mapWidth = defaultSize / sheetScale;
        return getLevelByMapWidth(mapWidth)
    }

    private function getLevelByMapWidth(mapWidth:int):uint
    {
        /*columns = Math.pow(2,level) / (tileWidth / BaseWidth);
        mapWidth = columns * tileWidth;*/

        var towPowLevel:Number;
        /*var columns:Number = mapWidth / tileWidth;
        var tile_base:Number = tileWidth / BaseWidth;
        towPowLevel = columns * tile_base;*/
        towPowLevel = mapWidth / BaseWidth;
       return correctLevel(MathUtil.logx(towPowLevel, 2));
    }

    ///////////////
    ///////////////
    ///////////////

    private function correctLevel(level:Number):uint
    {
        level = Math.round(level);

        if (level < MIN_LEVEL)
            level = MIN_LEVEL;
        else if (level > MAX_LEVEL)
            level = MAX_LEVEL;

        return level;
    }

    private function get mapWidth():uint
    {
        return getMapWidth(level)
    }

    private function getMapWidth(level:uint):uint
    {
        var columns:int = Math.pow(2,level) / (tileWidth / BaseWidth);
        return columns * tileWidth;
    }
}
}
