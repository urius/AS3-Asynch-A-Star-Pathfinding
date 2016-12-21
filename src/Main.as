package {

import com.twinpixel.astar.AStar;
import com.twinpixel.astar.Events.AStarEvent;
import com.twinpixel.astar.IAStarPoint;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.Dictionary;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import testgrid.TestPoint;

import testgrid.TestRectGrid;

[SWF (width = 1000, height = 800)]
public class Main extends Sprite {
    private var _aStar:AStar;

    public function Main() {
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);

        var _grid:TestRectGrid = new TestRectGrid();
        _grid.x = 50;
        _grid.y = 50;
        addChild(_grid);

        _aStar = new AStar(_grid);

        //_aStar.precalculatePoint(_grid.getPoint(0,0))
        _aStar.precalculatePointAsync(_grid.getPoint(0,0), function (path:Vector.<IAStarPoint>){_findAsync(_grid)})
        //setTimeout(_getPathAStar, 100, _grid, new Point(0,0), new Point(9,0));
        //setTimeout(_getPathAStar, 200, _grid, new Point(0,0), new Point(1,14));
        //setTimeout(_getPathAStar, 300, _grid, new Point(0,0), new Point(8,14));
        //setTimeout(_getPathAStar, 400, _grid, new Point(0,0), new Point(1,13));
        //setTimeout(_getPathAStar, 500, _grid, new Point(0,0), new Point(9, 2));
        //setTimeout(_getPathAStar, 800, _grid, new Point(0,0), new Point(4, 29));
        //setTimeout(_getPathAStar, 800, _grid, new Point(0,0), new Point(0, 29));

        addEventListener(Event.ENTER_FRAME, _frameCounter)
        //_findAsync(_grid);
    }



    private var _framesPassed:int = 0;
    private function _frameCounter(event:Event):void {
        _framesPassed ++;
    }

    private function _findAsync(_grid:TestRectGrid):void {
        var time1:int = getTimer();
        var frames1:int = _framesPassed;
        trace("Async Path start, time: " + time1);
        _aStar.findPathAsync(_grid.getPoint(0,0), _grid.getPoint(0,29), true, findPathAsyncHandler)

        function findPathAsyncHandler(path:Vector.<IAStarPoint>):void {
            var _time2:int = getTimer();
            trace(_time2 + "  Async Path finding time: " + (_time2 - time1) + " frames passed:"+(_framesPassed - frames1));
            drawPath(_grid, path);

            _findAsync2(_grid);
        }
    }

    private function _findAsync2(_grid:TestRectGrid):void {
        var time1:int = getTimer();
        var frames1:int = _framesPassed;
        trace("Async Path start, time: " + time1);
        _aStar.findPathAsync(_grid.getPoint(0,0), _grid.getPoint(8,29),  true, findPathAsyncHandler)

        function findPathAsyncHandler(path:Vector.<IAStarPoint>):void {
            var _time2:int = getTimer();
            trace(_time2 + "  Async Path finding time: " + (_time2 - time1) + " frames passed:"+(_framesPassed - frames1));
            drawPath(_grid, path);
        }
    }





    private function _getPathAStar(_grid:TestRectGrid, point1:Point, point2:Point):void {
        var time1:int = getTimer();;

        //_aStar = new AStar(_grid);

         var _path:Vector.<IAStarPoint> = _aStar.findPath(_grid.getPoint(point1.x,point1.y), _grid.getPoint(point2.x,point2.y), false)

        trace(point1 + " - " + point2 + ":  "+"Path finding time: " + (getTimer() - time1));

        drawPath(_grid, _path);

        var _pointsData:Dictionary = _aStar.$pointsData;
        for each (var point:Object in _pointsData) {
            //(point).point.markAsViewed();
        }

        //_aStar.resetCache();

    }

    public function drawPath(_grid:TestRectGrid, _path:Vector.<IAStarPoint>):void {
        _grid.reset();
        if(_path){
            for (var i:int = 0; i < _path.length; i++) {
                (_path[i] as TestPoint).markAsPath(i);
            }
        } else {
            trace("PATH is NULL")
        }
    }
}
}
