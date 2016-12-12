package {

import com.twinpixel.astar.AStar;
import com.twinpixel.astar.IAStarPoint;

import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;

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

        _getPathAStar(_grid);
    }



    private function _getPathAStar(_grid:TestRectGrid):void {
         var _path:Vector.<IAStarPoint> = new AStar(_grid).findPath(_grid.getPoint(0,0), _grid.getPoint(1,14))
         trace(_path);
         for (var i:int = 0; i < _path.length; i++) {
            (_path[i] as TestPoint).markAsPath(i);
         }
    }
}
}
