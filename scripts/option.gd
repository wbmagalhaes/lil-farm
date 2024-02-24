class_name Option

enum NoneSome { None = 0, Some = 1 }

var _none_some: NoneSome
var _value

func _init(value):
	self._value = value
	self._none_some = NoneSome.Some if value != null else NoneSome.None

static func Some(value):
	assert(value != null, "Error: value must be Some")
	return Option.new(value)

static func None():
	return Option.new(null)

func is_some() -> bool:
	return _none_some == NoneSome.Some

func is_none() -> bool:
	return _none_some == NoneSome.None

func fold(is_some_callback: Callable, is_none_callback: Callable):
	if self.is_some():
		return is_some_callback.call(_value)

	return is_none_callback.call()
