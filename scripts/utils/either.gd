class_name Either

enum LeftRight { Left = 0, Right = 1 }

var _left_right: LeftRight
var _value

func _init(left_right: LeftRight, value):
	_left_right = left_right
	_value = value

static func Left(value):
	return Either.new(LeftRight.Left, value)

static func Right(value):
	return Either.new(LeftRight.Right, value)

func is_left() -> bool:
	return _left_right == LeftRight.Left

func is_right() -> bool:
	return _left_right == LeftRight.Right

func fold(is_left_callback: Callable, is_right_callback: Callable):
	if self.is_left():
		return is_left_callback.call(_value)

	return is_right_callback.call(_value)
