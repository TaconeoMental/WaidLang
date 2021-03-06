require_relative 'waid_object'
require_relative 'ffi'

builtin_length = Proc.new do |str|
  if isStr(str)
    next returnValue(WaidInteger.new(str.Value.length))
  elsif str.is_a?(WaidArray)
    next returnValue(WaidInteger.new(str.Values.length))
  end
  next returnValue(WaidNull.new, WaidString.new("Not iterable"))
end

builtin_toStr = Proc.new do |obj|
  WaidString.new(obj.inspect.to_s)
end

builtin_toNum = Proc.new do |str|
  is_number = true if Float(str.inspect) rescue false
  if is_number
    num = str.Value.to_f
    if num % 1 == 0
      next returnValue(WaidInteger.new(num.to_i))
    else
      next returnValue(WaidFloat.new(str.Value.to_f))
    end
  end
  next returnValue(WaidNull.new, WaidString.new("nan"))
end

load_primitive = Proc.new do |location|
  if not isStr(location)
    next returnValue
  end

  object, library = location.Value.split("@")

  library = File.expand_path(File.dirname(__FILE__)) + "/lib/" + library
  if not library or not object
    next returnValue(error="Could not parse object@library")
  end
  library += ".rb"

  if not File.file?(library)
    next returnValue(error="Could not find library file")
  end

  require File.expand_path(library)

  $MODULE.StackFrame.getName(object)
end

builtin_ffi_module = WaidForeignModule.new("ffi")
builtin_ffi_module.define_primitive("load_primitive", WaidForeignFunction.new(load_primitive, 1))

$builtins = {
  "length" => WaidBuiltin.new(builtin_length, 1),
  "toNum" => WaidBuiltin.new(builtin_toNum, 1),
  "toStr" => WaidBuiltin.new(builtin_toStr, 1),
  "ffi" => builtin_ffi_module
}
