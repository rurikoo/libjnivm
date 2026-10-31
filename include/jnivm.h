#pragma once
#include <stdexcept>
#include <string>

#include "jnivm/env.h"
#include "jnivm/extends.h"
#include "jnivm/javatypes.h"
#include "jnivm/vm.h"

namespace jnivm {
// for variadic calling convention mismatches
static const char *GetJMethodIDSignature(jmethodID id) {
  return id ? ((jnivm::Method *)id)->signature.data() : nullptr;
}
} // namespace jnivm