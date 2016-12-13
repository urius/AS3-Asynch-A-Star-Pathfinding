/**
 * Created by yuris on 09.12.16.
 */
package com.twinpixel.astar {


import flash.utils.Dictionary;

public class AStar {
    private var _grid:IAStarGrid;

    public function AStar(grid:IAStarGrid) {
        _grid = grid;
    }


    private var _pointsData:Dictionary;
    public function findPath(startPoint:IAStarPoint, endPoint:IAStarPoint):Vector.<IAStarPoint> {
        _pointsData = new Dictionary();

        var openList:Vector.<PointData> = new Vector.<PointData>();
        var closedList:Vector.<PointData> = new Vector.<PointData>();

        _pointsData[startPoint] = new PointData(startPoint, _grid.getHeuristicDistance(startPoint,endPoint), _grid.getMoveCost(startPoint));
        openList.push(_pointsData[startPoint]);


        var currentPoint:PointData = null;
        var neighbours:Vector.<IAStarPoint>;

        var neighbourData:PointData;
        var neighbour:IAStarPoint

        var moveCost:int = 0;

        while(openList.length > 0){
            currentPoint = _pickPointWithMinF(openList, true);
            closedList.push(currentPoint);

            if(currentPoint.point == endPoint){
                break;
            }

            neighbours = _grid.getNearPoints(currentPoint.point);


            for each(neighbour in neighbours){
                moveCost = _grid.getMoveCost(neighbour);
                if(moveCost > 0 && _isInList(neighbour, closedList) == false){
                    var g:int = currentPoint.g + moveCost;
                    var h:Number = _grid.getHeuristicDistance(neighbour, endPoint);

                    if(_isInList(neighbour, openList)){
                        neighbourData = _pointsData[neighbour] as PointData;
                        if(g + h < neighbourData.f()){
                            neighbourData.prevPointData = currentPoint;
                        }
                    } else {
                        neighbourData = new PointData(neighbour, h, moveCost)
                        _pointsData[neighbour] = neighbourData;
                        neighbourData.prevPointData = currentPoint;
                        openList.push(neighbourData);
                    }
                }
            }
        }
        if(_pointsData[endPoint]){
            return _restorePath(_pointsData[endPoint] as PointData);
        }
        return null
    }

    private function _restorePath(endPointData:PointData):Vector.<IAStarPoint> {
        var _bufPoint:PointData = endPointData
        var _result:Vector.<IAStarPoint> = new <IAStarPoint>[];
        _result.push(_bufPoint.point);
        while(_bufPoint.prevPointData){
            _bufPoint = _bufPoint.prevPointData
            _result.unshift(_bufPoint.point);
        }

        return _result;
    }

    private function _isInList(point:IAStarPoint, list:Vector.<PointData>):Boolean {
        var pointData:PointData = _pointsData[point];
        if(pointData != null){
            if(list.indexOf(pointData) >= 0){
                return true
            }
        }
        return false;
    }

    private function _pickPointWithMinF(points:Vector.<PointData>, remove:Boolean = true):PointData {
        var _bufPoint:PointData;
        var _resultIndex:int = 0;
        var _result:PointData = points[_resultIndex];
        for (var i:int = 0; i < points.length; i++) {
            _bufPoint = points[i];
            if(_bufPoint.f() < _result.f()){
                _resultIndex = i;
                _result = _bufPoint
            }
        }

        if(remove) points.removeAt(_resultIndex);

        return _result;
    }

    public function get $pointsData():Dictionary {
        return _pointsData;
    }
}
}

import com.twinpixel.astar.IAStarPoint;


class PointData{
    private var _point:IAStarPoint;
    private var _prevPointData:PointData = null;
    private var _heuristicDistance:Number;
    private var _g:int = 0;
    private var _f:Number = 0;
    private var _moveCost:int;

    public function PointData(point:IAStarPoint, heuristicDistance:Number, moveCost:int):void {
        _point = point;
        _moveCost = moveCost;
        _g = 0;
        _heuristicDistance = heuristicDistance;
        _f = _g + _heuristicDistance;
    }

    public function get prevPointData():PointData {
        return _prevPointData;
    }

    public function set prevPointData(value:PointData):void {
        _prevPointData = value;
        _g = _prevPointData.g + _moveCost;
        _f = _g + _heuristicDistance;
    }

    //cost of moving to current point + heuristic cost to goal
    public function f():Number {
        return _f;
    }
    //total cost of moving to this point
    public function get g():int {
        return _g;
    }
    //heuristic distance to the goal point
    public function get heuristicDistance():Number {
        return _heuristicDistance;
    }

    public function get point():IAStarPoint {
        return _point;
    }
}
