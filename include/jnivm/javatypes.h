#pragma once
#include "array.h"
#include "bytebuffer.h"
#include "class.h"
#include "object.h"
#include "string.h"
#include "throwable.h"

namespace jnivm {
namespace java {
namespace lang {
using Array = jnivm::Array<void>;
using Object = jnivm::Object;
using String = jnivm::String;
using Class = jnivm::Class;
using Throwable = jnivm::Throwable;
namespace reflect {
using Method = jnivm::Method;
using Field = jnivm::Field;
} // namespace reflect
} // namespace lang
namespace nio {
using ByteBuffer = jnivm::ByteBuffer;
}
} // namespace java
namespace internal {
namespace lang {
using Global = jnivm::Global;
using Weak = jnivm::Weak;
} // namespace lang
} // namespace internal
} // namespace jnivm