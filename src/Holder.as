/**
 * Created by SalmanPC2 on 10/18/2017.
 */
package
{
import Utils.Util;

import flash.display.Sprite;
import flash.geom.Point;

public class Holder extends Sprite
{
    public function Holder()
    {
        super();
    }

    function refresh()
    {
        if(!parent || !parent.visible)
                return;

        var x1:int = 0;
        var y1:int = 0;
        var x2:int = width;
        var y2:int = height;

        var p1:Point = new Point(x1, y1);
        var p2:Point = new Point(x2, y2);

        p1 = Util.localToGlobal(p1, this);
        p2 = Util.localToGlobal(p2, this);

        x1 = p1.x;
        x2 = p2.x;
        y1 = p1.y;
        y2 = p2.y;

        if (x2 < 0 || x1 >= Main.Stage_Width-1 || y2 < 0 || y1 >= Main.Stage_Height-1)
        {
            visible = false;
        }
        else
        {
            visible = true;
            Map2.visibles++;
        }
    }
}
}
