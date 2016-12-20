package {

import com.twinpixel.astar.AStar;
import com.twinpixel.astar.IAStarPoint;

import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.Dictionary;
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

       // _aStar.precalculatePoint(_grid.getPoint(0,0))
        //setTimeout(_getPathAStar, 100, _grid, new Point(0,0), new Point(9,0));
        setTimeout(_getPathAStar, 200, _grid, new Point(0,0), new Point(1,14));
//        setTimeout(_getPathAStar, 300, _grid, new Point(0,0), new Point(8,14));
        setTimeout(_getPathAStar, 400, _grid, new Point(0,0), new Point(1,13));
        setTimeout(_getPathAStar, 500, _grid, new Point(0,0), new Point(9, 2));
        setTimeout(_getPathAStar, 800, _grid, new Point(0,0), new Point(4, 29));
    }



    private function _getPathAStar(_grid:TestRectGrid, point1:Point, point2:Point):void {
        var time1:Number = new Date().milliseconds;

        //_aStar = new AStar(_grid);

         var _path:Vector.<IAStarPoint> = _aStar.findPath(_grid.getPoint(point1.x,point1.y), _grid.getPoint(point2.x,point2.y))

        trace(point1 + " - " + point2 + ":  "+"Path finding time: " + (new Date().milliseconds - time1));

        _grid.reset();
        if(_path){
            for (var i:int = 0; i < _path.length; i++) {
                (_path[i] as TestPoint).markAsPath(i);
            }
        } else {
            trace("PATH is NULL")
        }


        var _pointsData:Dictionary = _aStar.$pointsData;
        for each (var point:Object in _pointsData) {
            //(point).point.markAsViewed();
        }

        //_aStar.resetCache();

    }
}
}
