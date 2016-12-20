/**
 * Created by yuris on 09.12.16.
 */
package com.twinpixel.astar {


import flash.utils.Dictionary;
import flash.utils.setTimeout;

public class AStar {
    private var _grid:IAStarGrid;

    private var _calculatedStartPoints:StartPoints;
    public function AStar(grid:IAStarGrid) {
        _grid = grid;
        _calculatedStartPoints = new StartPoints();
    }


    private var _$pointsData:ReachablePoints;
    public function findPath(startPoint:IAStarPoint, endPoint:IAStarPoint, fast:Boolean = true):Vector.<IAStarPoint> {
        var reachablePointsData:ReachablePoints;

        if(_calculatedStartPoints.pointIsCalculated(startPoint) && endPoint){
            reachablePointsData = _calculatedStartPoints.getReachablesFrom(startPoint);
            var _reachablePointData:PointData = reachablePointsData.getPointData(endPoint)
            if(_reachablePointData != null){
                return _restorePath(_reachablePointData);
            } else {
                return null //Path is UNREACHABLE
            }
        }

        if(fast){
            reachablePointsData = new ReachablePoints(startPoint);// CACHING is off
        } else {
            reachablePointsData = _calculatedStartPoints.createReachables(startPoint);
        }

        _$pointsData = reachablePointsData;

        var openList:Vector.<PointData> = new Vector.<PointData>();
        var closedList:Vector.<PointData> = new Vector.<PointData>();

        reachablePointsData.createOrUpdatePointData(startPoint, endPoint?_grid.getHeuristicDistance(startPoint,endPoint):0, _grid.getMoveCost(startPoint));
        openList.push(reachablePointsData.getPointData(startPoint));

        var currentPoint:PointData = null;
        var neighbours:Vector.<IAStarPoint>;
        var neighbourData:PointData;
        var neighbour:IAStarPoint;
        var moveCost:int = 0;

        while(openList.length > 0){
            currentPoint = _pickPointWithMinF(openList, true);
            closedList.push(currentPoint);

            if(fast){
                if(currentPoint.point == endPoint){
                    break;
                }
            }

            neighbours = _grid.getNearPoints(currentPoint.point);

            for each(neighbour in neighbours){
                moveCost = _grid.getMoveCost(neighbour);
                if(moveCost > 0 && _isInList(neighbour,reachablePointsData, closedList) == false){
                    var g:int = currentPoint.g + moveCost;
                    var h:Number = endPoint?_grid.getHeuristicDistance(neighbour, endPoint):0;

                    if(_isInList(neighbour,reachablePointsData, openList)){
                        neighbourData = reachablePointsData.getPointData(neighbour);
                        if(g + h < neighbourData.f()){
                            neighbourData.prevPointData = currentPoint;
                        }
                    } else {
                        neighbourData = reachablePointsData.createOrUpdatePointData(neighbour, h, moveCost);
                        neighbourData.prevPointData = currentPoint;
                        openList.push(neighbourData);
                    }
                }
            }
        }

        //if(_pointsData[endPoint]){
        if(endPoint && reachablePointsData.getPointData(endPoint)){
            //return _restorePath(_pointsData[endPoint] as PointData);
            return _restorePath(reachablePointsData.getPointData(endPoint));
        }
        return null; //Path is UNREACHABLE or we are using calculate function
    }


    public function precalculatePoint(startPoint:IAStarPoint):void {
        findPath(startPoint, null, false);
    }

    public function findPathAsync(startPoint:IAStarPoint, endPoint:IAStarPoint, callback:Function):void {

        var reachablePointsData:ReachablePoints = new ReachablePoints(startPoint);

        var openList:Vector.<PointData> = new <PointData>[];
        var closedList:Vector.<PointData> = new <PointData>[];

        openList.push(reachablePointsData.createOrUpdatePointData(startPoint, _grid.getHeuristicDistance(startPoint,endPoint), _grid.getMoveCost(startPoint)));

        _findPathAsyncCore(reachablePointsData, openList, closedList, endPoint, callback);

    }

    private function _findPathAsyncCore(reachablePointsData:ReachablePoints, openList:Vector.<PointData>, closedList:Vector.<PointData>, endPoint:IAStarPoint, callback:Function):void {
        var currentPoint:PointData;
        var neighbours:Vector.<IAStarPoint>;
        var neighbourData:PointData;
        var neighbour:IAStarPoint;
        var moveCost:int = 0;

        var steps:int = 100;

        while (steps > 0){
            steps --;
            if(openList.length > 0){
                currentPoint = _pickPointWithMinF(openList);
                closedList.push(currentPoint);

                neighbours = _grid.getNearPoints(currentPoint.point);

                for each(neighbour in neighbours){
                    moveCost = _grid.getMoveCost(neighbour);
                    if(moveCost > 0 && _isInList(neighbour,reachablePointsData, closedList) == false){
                        var g:int = currentPoint.g + moveCost;
                        var h:Number = endPoint?_grid.getHeuristicDistance(neighbour, endPoint):0;

                        if(_isInList(neighbour,reachablePointsData, openList)){
                            neighbourData = reachablePointsData.getPointData(neighbour);
                            if(g + h < neighbourData.f()){
                                neighbourData.prevPointData = currentPoint;
                            }
                        } else {
                            neighbourData = reachablePointsData.createOrUpdatePointData(neighbour, h, moveCost);
                            neighbourData.prevPointData = currentPoint;
                            openList.push(neighbourData);
                        }
                    }
                }
            } else {
                callback(_restorePath(reachablePointsData.getPointData(endPoint)));
                return;
            }
        }
        if(steps <= 0){
            setTimeout(_findPathAsyncCore, 0, reachablePointsData,openList,closedList,endPoint,callback);
        }

    }


    public function resetCache(quick:Boolean = false):void {
        _calculatedStartPoints.clear(quick);
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

    private function _isInList(point:IAStarPoint, reachablesData:ReachablePoints, list:Vector.<PointData>):Boolean {
        //var pointData:PointData = _pointsData[point];
        var pointData:PointData = reachablesData.getPointData(point);
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
        return _$pointsData.$raw;
    }
}
}

import flash.utils.Dictionary;

class StartPoints{

    private const _startPointsDict:Dictionary = new Dictionary();
    public function StartPoints():void {
    }

    public function pointIsCalculated(startPoint:IAStarPoint):Boolean {
        return (_startPointsDict[startPoint] != null);
    }

    public function createReachables(from:IAStarPoint):ReachablePoints {
        _startPointsDict[from] = new ReachablePoints(from);
        return _startPointsDict[from]
    }

    public function getReachablesFrom(from:IAStarPoint):ReachablePoints {
        if(pointIsCalculated(from) == false){
            _startPointsDict[from] = new ReachablePoints(from);
        }
        return _startPointsDict[from];
    }

    public function clear(quick:Boolean):void {
        for (var point:Object in _startPointsDict) {
            if(quick) {
                (_startPointsDict[point] as ReachablePoints).clear();
            }
            delete _startPointsDict[point];
        }
    }
}

class ReachablePoints {
    private var _from:IAStarPoint;

    private const _reachables:Dictionary = new Dictionary();
    public function ReachablePoints(from:IAStarPoint) {
        _from = from;
    }

    public function createOrUpdatePointData(point:IAStarPoint, heuristicDistance:int, moveCost:int):PointData {
        if(_reachables[point] == null){
            _reachables[point] = new PointData(point, heuristicDistance, moveCost);
        } else {
            (_reachables[point] as PointData).heuristicDistance = heuristicDistance
        }

        return _reachables[point];
    }

    public function getPointData(point:IAStarPoint):PointData {
        return _reachables[point];
    }

    public function get from():IAStarPoint {
        return _from;
    }

    public function get $raw():Dictionary {
        return _reachables;
    }

    public function clear():void {
        for (var point:Object in _reachables) {
            delete _reachables[point];
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
    public function set heuristicDistance(value:Number):void {
        _heuristicDistance = value;
    }

    public function get point():IAStarPoint {
        return _point;
    }
}
