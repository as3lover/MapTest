/**
 * Created by SalmanPC2 on 10/16/2017.
 *
 */
package Utils
{

public class LatLong
{
    private var _lat:Number;
    private var _long:Number;

    public function LatLong(latitude:Number = 0, longitude:Number = 0)
    {
        _lat = latitude;
        _long = longitude;
    }

    public function get latitude():Number
    {
        return _lat;
    }

    public function set latitude(value:Number):void
    {
        _lat = value;
    }

    public function get longitude():Number
    {
        return _long;
    }

    public function set longitude(value:Number):void
    {
        _long = value;
    }
}
}
