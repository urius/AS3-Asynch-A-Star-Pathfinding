/**
 * Created by yuris on 11.12.16.
 */
package testgrid {
import com.twinpixel.astar.IAStarGrid;
import com.twinpixel.astar.IAStarPoint;

import flash.display.Sprite;

public class TestRectGrid extends Sprite implements IAStarGrid{
    private var _grid:Vector.<Vector.<TestPoint>> = new Vector.<Vector.<TestPoint>>();

    public function TestRectGrid() {
        createGrid();
        renderGrid();
    }

    private function renderGrid():void {
        for (var i:int = 0; i < _grid.length; i++) {
            for (var j:int = 0; j < _grid[i].length; j++) {
                _grid[i][j].render();
            }
        }
    }
    private function createGrid():void {

        var _bufPoint:TestPoint;
        for (var i:int = 0; i < 40; i++) {
            _grid[i] = new Vector.<TestPoint>();
            for (var j:int = 0; j < 30; j++) {
                var _walkable:int = 1;
                if((j == 4 && i < 8) || (j == 8 && i>2) || (j==12 && i <8)){
                    _walkable = 0;
                }
                if( i == 10 && j >18 && j < 28){
                    _walkable = 0;
                }
                if( (i == 16 || i == 22 || i== 28 || i == 36) && j >8 && j < 18){
                    _walkable = 0;
                }
                if( (i == 18 || i == 24 || i== 32) && j >12 && j < 22){
                    _walkable = 0;
                }
                if( j == 22 && i > 10 && i < 38){
                    _walkable = 0;
                }
                if( j == 24 && i > 12){
                    _walkable = 0;
                }
                if( j == 28 && i< 38){
                    _walkable = 0;
                }
                if(i == 2 && j > 28){
                    _walkable = 0;
                }
                _bufPoint = new TestPoint(i,j,_walkable);
                _bufPoint.x = (2 + _bufPoint.size) * i;
                _bufPoint.y = (2 + _bufPoint.size) * j;
                _grid[i][j] = _bufPoint;
                addChild(_bufPoint);
            }
        }
    }

    public function reset():void {
        for (var i:int = 0; i < _grid.length; i++) {
            for (var j:int = 0; j < _grid[i].length; j++) {
                _grid[i][j].reset();
            }
        }
    }


    public function getPoint(x:int, y:int):TestPoint {
        return _grid[x][y];
    }

    public function getNearPoints(relativeTo:IAStarPoint):Vector.<IAStarPoint> {
        var _result:Vector.<IAStarPoint> = new <IAStarPoint>[];
        var _targetPoint:TestPoint = relativeTo as TestPoint;
        var _newX:int;
        var _newY:int;
        for (var i:int = -1; i <= 1; i += 1) {
            for (var j:int = -1; j <= 1; j += 1) {
                if((i == 0 && j == 0) || (i != 0 && j != 0)){
                    continue;
                }
                _newX = _targetPoint.xCoord + i;
                _newY = _targetPoint.yCoord + j;
                if(_newX >= 0 && _newX < _grid.length){
                    if(_newY >= 0 && _newY < _grid[0].length){
                        if(_grid[_newX][_newY]){
                            _result.push(_grid[_newX][_newY]);
                        }
                    }
                }
            }
        }
        return _result;
    }

    public function getHeuristicDistance(point1:IAStarPoint, point2:IAStarPoint):Number {
        var _targetPoint1:TestPoint = point1 as TestPoint;
        var _targetPoint2:TestPoint = point2 as TestPoint;

        //return Math.sqrt(Math.pow(_targetPoint1.xCoord - _targetPoint2.xCoord, 2) + Math.pow(_targetPoint1.yCoord - _targetPoint2.yCoord, 2));
        return (Math.pow(_targetPoint1.xCoord - _targetPoint2.xCoord, 2) + Math.pow(_targetPoint1.yCoord - _targetPoint2.yCoord, 2));
    }

    public function getMoveCost(toPoint:IAStarPoint):int {
        return (toPoint as TestPoint).moveCost;
    }
}
}
