

###ActionScript 3 realization of A-Star (A*) pathfinding algorithm, with additional asynchronous mode and precalculation mode.

####To start using this lib, you need to implement 2 interfaces in your app:

1. `IAStarPoint` - This must be implemented by every game cell (both walkable and not walkable), contain methods:
    * `function get aStarPointId():String`
    Getter for cell ID, every unique cell must have a unique id (no matter what, it will be used to compare cells)

2. `IAStarGrid` - Interface for your game field to implement, consist of methods below:
    * `function getNearPoints(relativeTo:IAStarPoint):Vector.<IAStarPoint>` 
        Returns Vector of nearby cells. Can be returned only walkable cells, or walkable and unwalkable cells.

    * `function getHeuristicDistance(point1:IAStarPoint, point2:IAStarPoint):Number`
        Returns prediction of distance from one cell to any other cell. Constant can be returned for any pair of piints, but algorithm will be executed much more time.

    * `function getMoveCost(toPoint:IAStarPoint):int`
        Returns hte cost of moving to a given cell (from any other near cells). Not walkable cells must return `0 or any negative number`.


####After you implement these Interfaces, you can use methods below:

- `function AStar(grid:IAStarGrid)` 
Constructor, use it to prepare Algorithm for execution.

- `function findPath(startPoint:IAStarPoint, endPoint:IAStarPoint, fast:Boolean = true):Vector.<IAStarPoint>`  
        Synchronous method to find existing path from startPoint to endPoint. Returns `Vector.<IAStarPoint>` as path if exists, 
        and NULL if endPoint is unreachable.        
  - if `fast == false`, than all cells will be checked, and absolutely shortest path will be found (that not  guaranteed if `fast == true`), also will be enabled caching, that allows you to get path from current start point to any other at shortest time (~0ms)

- `function findPathAsync(startPoint:IAStarPoint, endPoint:IAStarPoint,fast:Boolean = true, callback:Function = null):void`
    Asynchronous version of `findPath()`. Dispatch `AStarEvent.PATH_CALCULATED` event, when algorithm is finished.        
  - `callback:Function` optional complete handler. it must be a function with signature: `function callback(path:Vector:<IAStarPoint>):void {}`

- `function precalculatePoint(startPoint:IAStarPoint):void`  Calculates and caches all possible paths from startPoint. 
        Works just like `findPath()` with `fast` set to `false`, but don't return a result. 

- `function precalculatePointAsync(startPoint:IAStarPoint, callback:Function = null):void` 
    Asynchronous version of `precalculatePoint()`. Dispatch `AStarEvent.PATH_CALCULATED` event, when algorithm is finished.
  - `callback:Function` optional complete handler. it must be a function with no parameters ( signature: `function callback():void {}` )


> Also you can change `ASYNC_ITERATION_STEPS` property on created `AStar` instance to achieve better algorithm asyncronous execution time. The more value, the more frame time will be by calculations, and the less total time will need. Default is `100` steps per frame.
