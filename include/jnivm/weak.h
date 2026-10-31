#pragma once
namespace jnivm {
class Weak;
}
#include <jnivm/extends.h>
#include <jnivm/object.h>
namespace jnivm {
class Weak : public Extends<Object> {
public:
  std::weak_ptr<Object> wrapped;
};

class Global : public Extends<Object> {
public:
  std::shared_ptr<Object> wrapped;
};
} // namespace jnivm