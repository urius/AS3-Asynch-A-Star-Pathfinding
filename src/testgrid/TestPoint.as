/**
 * Created by yuris on 11.12.16.
 */
package testgrid {
import com.twinpixel.astar.IAStarPoint;

import flash.display.Shape;
import flash.text.TextField;

public class TestPoint extends Shape implements IAStarPoint{
    private var _moveCost:int;
    private var _xCoord:int;
    private var _yCoord:int;

    private var _size:int = 40;
    private var _markedAsPath:Boolean = false;
    private var _stepTxt:TextField;

    public function TestPoint(xCoord:int, yCoord:int, moveCost:int) {
        _xCoord = xCoord;
        _yCoord = yCoord;
        _moveCost = moveCost;
    }

    public function get moveCost():int {
        return _moveCost;
    }

    public function get walkable():Boolean {
        return (_moveCost > 0);
    }

    public function get xCoord():int {
        return _xCoord;
    }

    public function get yCoord():int {
        return _yCoord;
    }

    public function render():void {
        this.graphics.clear();
        if(_markedAsPath){
            this.graphics.beginFill(0x0000ff, 0.5);
        } else {
            this.graphics.beginFill((_moveCost > 0)?0x00ff00:0xff0000, 0.5);
        }
        this.graphics.drawRect(0,0, _size, _size);
        this.graphics.endFill();
    }

    public function get size():int {
        return _size;
    }


    override public function toString():String {
        return "["+_xCoord+","+_yCoord+"]";
    }

    public function markAsPath(stepNum:int):void {
        _markedAsPath = true;
        if(_stepTxt == null){
            _stepTxt = new TextField();
            _stepTxt.x = this.x
            _stepTxt.y = this.y;
            _stepTxt.mouseEnabled = false;
            parent.addChild(_stepTxt)
        }
        _stepTxt.text = stepNum+""

        render();
    }
}
}
