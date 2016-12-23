/**
 * Created by yuris on 09.12.16.
 */
package com.twinpixel.astar {


import com.twinpixel.astar.Events.AStarEvent;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

[Event (name="PATH_CALCULATED", type="com.twinpixel.astar.Events.AStarEvent")]
public class AStar extends EventDispatcher{
    private var _grid:IAStarGrid;

    /**
     * Defines, how many steps will be executed during one async iteration
     * the less value, the less frame time will be occupied by the algorithm, and more total time will need to finish
     */
    public var ASYNC_ITERATION_STEPS:uint = 100;

    private var _calculatedStartPoints:StartPoints;

    /**
     * Init algorithm
     * @param grid
     * User defined grid of path cells, must implement IAStarGrid interface
     */
    public function AStar(grid:IAStarGrid) {
        _grid = grid;
        _calculatedStartPoints = new StartPoints();
    }

    /**
     * Synchronous
     * SLOW method!
     * Calculates and caches all possible paths from a given point.
     * @param startPoint - Start Point for calculated paths
     */
    public function precalculatePoint(startPoint:IAStarPoint):void {
        findPath(startPoint, null, false);
    }

    private var _$pointsData:ReachablePoints;

    /**
     * Synchronous
     * Calculates shortest possible path, using heuristic function
     * @param startPoint
     * @param endPoint
     * @param fast
     * if true, algorithm will stop, when first time meets endPoint. Caching is disabled
     * if false, algorithm will check all possible cells, and return absolutely shortest path.
     * Caching is enabled. Behaviour is similar to  precalculatePoint() function
     * @return result path, presented as Vector.<IAStarPoint>
     */
    public function findPath(startPoint:IAStarPoint, endPoint:IAStarPoint, fast:Boolean = true):Vector.<IAStarPoint> {
        if(_calculatedStartPoints.pointIsCalculated(startPoint) && endPoint){
            return _getCalculatedPath(startPoint, endPoint);
        }

        //if fast == true, caching is OFF
        var reachablePointsData:ReachablePoints = fast ? new ReachablePoints(startPoint) : _calculatedStartPoints.createReachables(startPoint);

        _$pointsData = reachablePointsData;

        var openList:Vector.<PointData> = new Vector.<PointData>();
        var startPointData:PointData = reachablePointsData.createOrUpdatePointData(startPoint, endPoint ? _grid.getHeuristicDistance(startPoint,endPoint) : 0, _grid.getMoveCost(startPoint));
        _addToOpenList(startPointData, openList);

        var currentPoint:PointData = null;

        while(openList.length > 0){
            currentPoint = _pickPointWithMinF(openList, true);
            _addToClosedList(currentPoint);

            if(fast){
                if(currentPoint.point.aStarPointId == endPoint.aStarPointId){
                    break;
                }
            }
            _coreProcessNeighbours(reachablePointsData, _grid, openList, currentPoint, endPoint);
        }

        return _restorePath(reachablePointsData.getPointData(endPoint));
    }

    private function _addToClosedList(pointData:PointData):void {
        pointData.inClosedList = true;
    }

    private function _addToOpenList(pointData:PointData, openList:Vector.<PointData>):void {
        openList.push(pointData)
        pointData.inOpenList = true;
    }

    private function _getCalculatedPath(startPoint:IAStarPoint, endPoint:IAStarPoint):Vector.<IAStarPoint> {
        var reachablePointsData:ReachablePoints = _calculatedStartPoints.getReachablesFrom(startPoint);
        return _restorePath(reachablePointsData.getPointData(endPoint));
    }

    /**
     * Asynchronous
     * Similar to precalculatePoint(), but don't block main loop.
     * Dispatch AStarEvent.PATH_CALCULATED event, when finish.
     * @param startPoint
     * @param callback
     * Callback function, that will be called on finish.
     * Signature: function callback() {}
     */
    public function precalculatePointAsync(startPoint:IAStarPoint, callback:Function = null):void {
        findPathAsync(startPoint, null, false, function (path:Vector.<IAStarPoint>):void {
            if(callback && callback.length == 0) {
                callback();
            } else if (callback){
                throw new Error("[precalculatePointAsync] Callback must be a function without parameters'");
            }
        })
    }

    /**
     * Asynchronous
     * Async version of findPath()
     * Dispatch AStarEvent.PATH_CALCULATED event, when finish.
     * @param startPoint
     * @param endPoint
     * @param fast
     * @param callback
     * Callback function, that will be called on finish.
     * Signature: function callback(path:Vector:<IAStarPoint>) {}
     */
    public function findPathAsync(startPoint:IAStarPoint, endPoint:IAStarPoint,fast:Boolean = true, callback:Function = null):void {
        if(_calculatedStartPoints.pointIsCalculated(startPoint) && endPoint){
            _dispatchResult(_getCalculatedPath(startPoint, endPoint), callback);
            return;
        }

        var reachablePointsData:ReachablePoints = fast ? new ReachablePoints(startPoint) : _calculatedStartPoints.getReachablesFrom(startPoint);

        var openList:Vector.<PointData> = new <PointData>[];
        var startPointData:PointData = reachablePointsData.createOrUpdatePointData(startPoint, endPoint ? _grid.getHeuristicDistance(startPoint,endPoint) : 0, _grid.getMoveCost(startPoint));
        _addToOpenList(startPointData, openList);

        _findPathAsyncCore(reachablePointsData, openList, endPoint, fast, callback);
    }

    private function _findPathAsyncCore(reachablePointsData:ReachablePoints, openList:Vector.<PointData>, endPoint:IAStarPoint, fast:Boolean, callback:Function):void {
        var currentPoint:PointData;

        var steps:int = ASYNC_ITERATION_STEPS;
        while (steps > 0){
            steps --;
            if(openList.length > 0){
                currentPoint = _pickPointWithMinF(openList, true);
                _addToClosedList(currentPoint);

                if(fast){
                    if(endPoint && currentPoint.point.aStarPointId == endPoint.aStarPointId){
                        _dispatchResult(_restorePath(reachablePointsData.getPointData(endPoint)), callback);
                        return;
                    }
                }
                _coreProcessNeighbours(reachablePointsData, _grid, openList, currentPoint, endPoint);
            } else {
                _dispatchResult(_restorePath(reachablePointsData.getPointData(endPoint)), callback);
                return;
            }
        }
        if(steps <= 0){
            setTimeout(_findPathAsyncCore, 0, reachablePointsData,openList,endPoint, fast, callback);
        }
    }

    private function _dispatchResult( result:Vector.<IAStarPoint>, callback:Function):void {
        dispatchEvent(new AStarEvent(AStarEvent.PATH_CALCULATED, result));
        if(callback && callback.length == 1){
            callback(result);
        } else if (callback){
            throw new Error("[findPathAsync] Callback must be a function with 1 parameter with type 'Vector.<IAStarPoint>'");
        }
    }


    private function _coreProcessNeighbours(reachablePointsData:ReachablePoints, _grid:IAStarGrid, openList:Vector.<PointData>, currentPoint:PointData, endPoint:IAStarPoint):void {
        var neighbours:Vector.<IAStarPoint>;
        var neighbourData:PointData;
        var neighbour:IAStarPoint;
        var moveCost:int = 0;

        neighbours = _grid.getNearPoints(currentPoint.point);

        for each(neighbour in neighbours){
            moveCost = _grid.getMoveCost(neighbour);
            if(moveCost > 0 && _isInClosedList(neighbour,reachablePointsData) == false){
                var g:int = currentPoint.g + moveCost;
                var h:Number = endPoint?_grid.getHeuristicDistance(neighbour, endPoint):0;

                if(_isInOpenList(neighbour,reachablePointsData)){
                    neighbourData = reachablePointsData.getPointData(neighbour);
                    if(g + h < neighbourData.f()){
                        neighbourData.prevPointData = currentPoint;
                    }
                } else {
                    neighbourData = reachablePointsData.createOrUpdatePointData(neighbour, h, moveCost);
                    neighbourData.prevPointData = currentPoint;
                    _addToOpenList(neighbourData, openList);
                }
            }
        }
    }

    /**
     * CLear all cached data
     * Use it, if some of your path costs was changed or
     * if you no longer need to calculate paths
     * @param quick
     * if true, then removes only heads of data structures, more work to Garbage Collector
     * if false, then will be executed deep cleaning
     */
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

    private function _isInClosedList(point:IAStarPoint, reachablesData:ReachablePoints):Boolean {
        var pointData:PointData = reachablesData.getPointData(point);
        if(pointData != null){
            return pointData.inClosedList;
        }
        return false;
    }

    private function _isInOpenList(point:IAStarPoint, reachablesData:ReachablePoints):Boolean {
        var pointData:PointData = reachablesData.getPointData(point);
        if(pointData != null){
            return pointData.inOpenList;
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

        if(remove) {
            points.removeAt(_resultIndex);
            _result.inOpenList = false;
        }

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
            (_reachables[point] as PointData).heuristicDistance = heuristicDistance;
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


    private var _inOpenList:Boolean = false;
    private var _inClosedList:Boolean = false;

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

    public function get inOpenList():Boolean {
        return _inOpenList;
    }

    public function get inClosedList():Boolean {
        return _inClosedList;
    }

    public function set inOpenList(value:Boolean):void {
        _inOpenList = value;
    }

    public function set inClosedList(value:Boolean):void {
        _inClosedList = value;
    }
}
