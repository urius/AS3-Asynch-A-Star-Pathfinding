/**
 * Created by yuris on 09.12.16.
 */
package com.twinpixel.astar {
public interface IAStarGrid {
    function getNearPoints(relativeTo:IAStarPoint):Vector.<IAStarPoint>

    function getHeuristicDistance(point1:IAStarPoint, point2:IAStarPoint):Number;

}
}
