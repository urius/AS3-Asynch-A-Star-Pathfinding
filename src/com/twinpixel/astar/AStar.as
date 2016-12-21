/**
 * Created by yuris on 09.12.16.
 */
package com.twinpixel.astar {


import com.twinpixel.astar.Events.AStarEvent;

import flash.events.DataEvent;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

[Event (name="PATH_CALCULATED", type="com.twinpixel.astar.Events.AStarEvent")]
public class AStar extends EventDispatcher{
    private var _grid:IAStarGrid;



    private var _calculatedStartPoints:StartPoints;
    public function AStar(grid:IAStarGrid) {
        _grid = grid;
        _calculatedStartPoints = new StartPoints();
    }

    public function precalculatePoint(startPoint:IAStarPoint):void {
        findPath(startPoint, null, false);
    }

    private var _$pointsData:ReachablePoints;
    public function findPath(startPoint:IAStarPoint, endPoint:IAStarPoint, fast:Boolean = true):Vector.<IAStarPoint> {
        if(_calculatedStartPoints.pointIsCalculated(startPoint) && endPoint){
            return _getCalculatedPath(startPoint, endPoint);
        }

        //if fast == true, caching is OFF
        var reachablePointsData:ReachablePoints = fast ? new ReachablePoints(startPoint) : _calculatedStartPoints.createReachables(startPoint);

        _$pointsData = reachablePointsData;

        var openList:Vector.<PointData> = new Vector.<PointData>();
        var closedList:Vector.<PointData> = new Vector.<PointData>();

        openList.push(reachablePointsData.createOrUpdatePointData(startPoint, endPoint ? _grid.getHeuristicDistance(startPoint,endPoint) : 0, _grid.getMoveCost(startPoint)));

        var currentPoint:PointData = null;

        while(openList.length > 0){
            currentPoint = _pickPointWithMinF(openList, true);
            closedList.push(currentPoint);

            if(fast){
                if(currentPoint.point.aStarPointId == endPoint.aStarPointId){
                    break;
                }
            }
            _coreProcessNeighbours(reachablePointsData, _grid, openList, closedList, currentPoint, endPoint);
        }

        return _restorePath(reachablePointsData.getPointData(endPoint));
    }

    private function _getCalculatedPath(startPoint:IAStarPoint, endPoint:IAStarPoint):Vector.<IAStarPoint> {
        var reachablePointsData:ReachablePoints = _calculatedStartPoints.getReachablesFrom(startPoint);
        return _restorePath(reachablePointsData.getPointData(endPoint));
    }


    public function findPathAsync(startPoint:IAStarPoint, endPoint:IAStarPoint,fast:Boolean = true, callback:Function = null):void {
        if(_calculatedStartPoints.pointIsCalculated(startPoint) && endPoint){
            _dispathResult(_getCalculatedPath(startPoint, endPoint), callback);
            return;
        }

        var reachablePointsData:ReachablePoints = fast ? new ReachablePoints(startPoint) : _calculatedStartPoints.getReachablesFrom(startPoint);

        var openList:Vector.<PointData> = new <PointData>[];
        var closedList:Vector.<PointData> = new <PointData>[];

        openList.push(reachablePointsData.createOrUpdatePointData(startPoint, _grid.getHeuristicDistance(startPoint,endPoint), _grid.getMoveCost(startPoint)));

        _findPathAsyncCore(reachablePointsData, openList, closedList, endPoint, fast, callback);
    }

    private function _findPathAsyncCore(reachablePointsData:ReachablePoints, openList:Vector.<PointData>, closedList:Vector.<PointData>, endPoint:IAStarPoint, fast:Boolean, callback:Function):void {
        var currentPoint:PointData;

        var steps:int = 100;
        while (steps > 0){
            steps --;
            if(openList.length > 0){
                currentPoint = _pickPointWithMinF(openList);
                closedList.push(currentPoint);

                if(fast){
                    if(endPoint && currentPoint.point.aStarPointId == endPoint.aStarPointId){
                        _dispathResult(_restorePath(reachablePointsData.getPointData(endPoint)), callback);
                        return;
                    }
                }
                _coreProcessNeighbours(reachablePointsData, _grid, openList, closedList, currentPoint, endPoint);
            } else {
                _dispathResult(_restorePath(reachablePointsData.getPointData(endPoint)), callback);
                return;
            }
        }
        if(steps <= 0){
            setTimeout(_findPathAsyncCore, 0, reachablePointsData,openList,closedList,endPoint, fast, callback);
        }
    }

    private function _dispathResult( result:Vector.<IAStarPoint>, callback:Function):void {
        dispatchEvent(new AStarEvent(AStarEvent.PATH_CALCULATED, result));
        if(callback && callback.length == 1){
            callback(result);
        }
    }


    private function _coreProcessNeighbours(reachablePointsData:ReachablePoints, _grid:IAStarGrid, openList:Vector.<PointData>, closedList:Vector.<PointData>,  currentPoint:PointData, endPoint:IAStarPoint):void {
        var neighbours:Vector.<IAStarPoint>;
        var neighbourData:PointData;
        var neighbour:IAStarPoint;
        var moveCost:int = 0;

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

    public function resetCache(quick:Boolean = false):void {
        _calculatedStartPoints.clear(quick);
    }

    private function _restorePath(endPointData:PointData):Vector.<IAStarPoint> {
        if(endPointData == null) return null;

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
