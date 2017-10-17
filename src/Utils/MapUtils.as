/**
 * Created by SalmanPC2 on 10/16/2017.
 *
 */
package Utils
{
import flash.geom.Point;

public class MapUtils
{
    public static const PI:Number = Math.PI;

    public static function toPixel(latitude:Number, longitude:int, zoomLevel:int):Point
    {
        var mapWidth:int = 256 * Math.pow(2 , zoomLevel);
        var mapHeight:int = mapWidth;

        var x:Number = (longitude+180)*(mapWidth/360);

        // convert from degrees to radians
        var latRad = latitude * PI/180;

        // get y value
        var mercN = Math.log(Math.tan((PI/4)+(latRad/2)));
        var y:Number = (mapHeight/2)-(mapWidth*mercN/(2*PI));

        return new Point(x, y);
    }

    public static function toLatLong(x:Number, y:int, zoomLevel:int):LatLong
    {
        var mapWidth:int = 256 * Math.pow(2 , zoomLevel);
        var mapHeight:int = mapWidth;

        var long:Number = ((x*360)/mapWidth) -180;
        var mercN:Number = (((mapHeight/2) - y) * 2 * PI)/mapWidth;
        var tan:Number = Math.exp(mercN);
        tan = Math.atan(tan);
        var rad:Number = 2 * (tan - (PI/4));
        var lat:Number = (rad * 180) / PI;

        return new LatLong(lat, long)
    }
}
}
