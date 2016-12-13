package {

import com.twinpixel.astar.AStar;
import com.twinpixel.astar.IAStarPoint;

import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import testgrid.TestPoint;

import testgrid.TestRectGrid;

[SWF (width = 800, height = 800)]
public class Main extends Sprite {

    public function Main() {
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);

        var _grid:TestRectGrid = new TestRectGrid();
        _grid.x = 50;
        _grid.y = 50;
        addChild(_grid);

        setTimeout(_getPathAStar, 200, _grid);
    }



    private function _getPathAStar(_grid:TestRectGrid):void {
        var time1:Number = new Date().milliseconds;


         var _aStar:AStar = new AStar(_grid);
         var _path:Vector.<IAStarPoint> = _aStar.findPath(_grid.getPoint(0,0), _grid.getPoint(1,14))
         trace(_path);
         for (var i:int = 0; i < _path.length; i++) {
            (_path[i] as TestPoint).markAsPath(i);
         }

        trace("Path finding time: " + (new Date().milliseconds - time1));

        var _pointsData:Dictionary = _aStar.$pointsData;
        for each (var point:Object in _pointsData) {
            (point).point.markAsViewed();
        }
    }
}
}
