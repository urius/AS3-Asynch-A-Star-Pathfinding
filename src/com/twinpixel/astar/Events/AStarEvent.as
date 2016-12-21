/**
 * Created by yuris on 21.12.16.
 */
package com.twinpixel.astar.Events {
import com.twinpixel.astar.IAStarPoint;

import flash.events.Event;

public class AStarEvent extends Event {

    public static const PATH_CALCULATED:String = "PATH_CALCULATED";

    private var _path:Vector.<IAStarPoint>;
    public function AStarEvent(type:String, path:Vector.<IAStarPoint>) {
        super(type, false, false);
        _path = path;
    }


    public function get path():Vector.<IAStarPoint> {
        return _path;
    }
}
}
