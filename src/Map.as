/**
 * Created by SalmanPC2 on 10/16/2017.
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
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.text.TextField;

public class Map extends Sprite
{
    public static const KEY:String = "AIzaSyBDHNAK8c5LnvhuGY33vXgG8HeIN6JQcAo";
    private var board:Sprite;
    private var loadList:Array = new Array();
    private var images:Object = new Object();
    private var loading:Boolean = false;
    private var _ZOOM:uint = 1;

    private static const BaseWidth:int = 256;
    private static const W:uint = BaseWidth * 2;

    private const stageWidth:int = 1000;
    private const stageHeight:int = 800;

    var shape1:Shape;
    private const GoogleLogoHeight:Number = 23;
    private var map:Sprite;
    private var mapWidth:int = 256;


    public function Map()
    {
       this.addEventListener(Event.ADDED_TO_STAGE, init)
    }

    private function init(event:Event):void
    {
        shape1 = circle(0,0,2);

        map = new Sprite();
        addChild(map);

        board = new Sprite();
        map.addChild(board);

        stage.addEventListener(MouseEvent.CLICK, click);
        function  click(e)
        {
            trace(board.mouseX, board.mouseY);
            var latlong:LatLong = MapUtils.toLatLong(board.mouseX, board.mouseY, ZOOM)
            trace(latlong.latitude, latlong.longitude)
            var point:Point = MapUtils.toPixel(latlong.latitude, latlong.longitude, ZOOM)
            trace(point)
        }


        board.graphics.lineStyle(0);
        board.graphics.drawRect(0,0,stageWidth,stageHeight);

        var line:Sprite = new Sprite();
        addChild(line);
        line.graphics.lineStyle(1);
        line.graphics.moveTo(0,W/2);
        line.graphics.lineTo(W,W/2);
        line.graphics.moveTo(W/2,0);
        line.graphics.lineTo(W/2,W);

        //new ZoomAndMove(stage, board, true, false);
        new ZoomAndMove(stage, map, true, true);
        //loadImage(36.302655, 59.575926, 2);


        var lat:TextField = new TextField();
        var long:TextField = new TextField();
        var z:TextField = new TextField();

        var bt:Sprite = new Sprite();
        bt.graphics.beginFill(0);
        bt.graphics.drawRect(0,0,50,20);
        bt.graphics.endFill();

        lat.text = long.text = z.text = "0.0";
        lat.type = long.type = z.type = "input";

        lat.text = "36.302655";
        long.text = "59.575926";

        var w:int = 100;
        var h:int = 50;

        lat.width = long.width = z.width = bt.width = w;
        lat.height = long.height = z.height = bt.height = h;

        lat.x = w * 0;
        long.x = w * 1;
        z.x = w * 2;
        bt.x = w * 3;

        lat.y = long.y = z.y = bt.y = 800 - h;

        addChild(lat);
        addChild(long);
        addChild(z);
        addChild(bt);

        bt.addEventListener(MouseEvent.CLICK, onBt);

        function onBt(event:MouseEvent):void
        {
            ZOOM = uint(z.text);
            loadList = [];
            board.removeChildren();

            board.graphics.clear();
            board.graphics.lineStyle(0);
            board.graphics.drawRect(0,0,stageWidth,stageHeight);

            center(uint(lat.text), uint(long.text))

            create();
        }

        create()
    }

    private function center(lat:uint, long:uint):void
    {
        var point:Point = MapUtils.toPixel(lat, long, ZOOM)
        trace(point)
        //board.x = -(point.x * board.scaleX)
        //board.y = -(point.y * board.scaleY)
        shape1.x = point.x// * board.scaleX  + board.x;
        shape1.y = point.y// * board.scaleY + board.y;

    }

    private function create():void
    {
        //trace('create');

        if (ZOOM > 21)
            ZOOM = 21;

        var tiles:int = Math.pow(2,ZOOM);

        var i:Number;
        var j:Number;
        var tileWidth:int = W;
        var tileMid:int = tileWidth/2;
        var columns:int = Math.pow(2,ZOOM) / (tileWidth / BaseWidth);
        mapWidth = columns * tileWidth;
        var centerX:int;
        var centerY:int;
        var tileX:int;
        var tileY:int;
        var centerLat:Number;
        var centerLong:Number;

        setScale();

        for(j = 0; j<tiles*2; j += (W-GoogleLogoHeight-1)/W)
        {
            for(i = 0; i<tiles*2; i += (W-1)/W)
            {
                centerX = ((i*2) +1)* tileMid;
                centerY = ((j*2) +1)* tileMid;

                tileX = i * tileWidth;
                tileY = j * tileWidth;

                var coordinate:LatLong = MapUtils.toLatLong(centerX, centerY, ZOOM);
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

                var name:String = "img" + String(ZOOM) + "l" +String(centerLat) + "g" +String(centerLong) + "i" + String(i) +"j" + String(j);

                var startX:Number = -board.x / board.scaleX;
                var startY:Number = -board.y / board.scaleY;

                var startPoint:Point =  new Point(0, 0);
                var endPoint:Point =  new Point(stageWidth, stageHeight);

                startPoint = board.globalToLocal(startPoint);
                endPoint = board.globalToLocal(endPoint);

                startX = startPoint.x;
                startY = startPoint.y;

                var endX:int = startX + stageWidth/ board.scaleX;
                var endY:int = startY + stageHeight/board.scaleY;

                endX = endPoint.x;
                endY = endPoint.y;


                if(tileX+tileWidth > startX && tileX < endX && tileY+tileWidth > startY && tileY < endY)
                    loadImage(name, centerLat, centerLong, ZOOM, tileX, tileY);
            }
        }
    }

    private function circle(x:int, y:int, radius:int = 10):Shape
    {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(0)
        shape.graphics.drawCircle(0,0,radius);
        shape.graphics.endFill();
        shape.x = x;
        shape.y = y;

        return shape;
    }



    private function loadImage(name:String, lat:Number, long:Number, zoom:uint = 18, x:int=0, y:int=0):void
{
    loadList.push({lat:lat, long:long, x:x, y:y, name:name});
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

        var url:String = "https://maps.googleapis.com/maps/api/staticmap?";
        url += "center=" + lat + "," + long + "&zoom=" + ZOOM +"&size=" + W + "x" + W + "&key=" + KEY;



        if (images[name] != null)
        {
            //trace(name);
            var img:Sprite = images[name];

            board.addChild(img);
            board.addChild(shape1);
            //trace(img.width, img.height, img.x, img.y, img.parent, img.visible);

            loading = false;

            if(loadList.length)
                load()

            return;
        }

        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
        loader.load(new URLRequest(url));


        function imageLoaded(e:Event):void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
            var bit = Bitmap(e.currentTarget.content);
            addImage(bit, lat, long, ZOOM, x, y, name);
        }
    }

    private function addImage(img:Bitmap, lat:Number, long:Number, zoom:uint, x:int, y:int, name:String):void
    {
        //trace(lat, long, zoom);
        //board.removeChildren();

        var holder:Sprite = new Sprite();
        holder.addChild(img);

        var mask:Shape = new Shape();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(0,0,img.width, img.height - GoogleLogoHeight);
        mask.graphics.endFill();
        holder.addChild(mask);

        img.mask = mask;

        holder.x = x;
        holder.y = y;
        board.addChild(holder);
        board.addChild(shape1)
        images[name] = holder;
        //trace(name);

        loading = false;
        if(loadList.length)
            load()
    }

    public function get ZOOM():uint
    {
        return _ZOOM;
    }

    public function set ZOOM(value:uint):void
    {
        _ZOOM = value;
    }

    function setScale()
    {
        var scale:Number = 1024 / mapWidth;
        board.scaleX = board.scaleY = scale;
        //map.x = map.y = 0;
    }
}
}
