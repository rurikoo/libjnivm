#include <cstdarg>
#include <jni.h>
#include <vector>

namespace jnivm {
std::vector<jvalue> JValuesfromValist(va_list list, const char *signature);
}