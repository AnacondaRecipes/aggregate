#include "double-conversion/double-conversion.h"

using namespace double_conversion;

int main (void) {
  const int flags = StringToDoubleConverter::ALLOW_CASE_INSENSIBILITY;
  const double junk_value = 3.1415;
  StringToDoubleConverter converter(flags, junk_value, junk_value, "inf", "nan");

  const char test_string[] = "1.5";
  int processed_length;

  double test_value = converter.StringToFloat(test_string, 3 /* length */,
                                              &processed_length);
  if (processed_length != 3) {
    return 1;
  }
  if (test_value != 1.5) {
    return 2;
  }
  return 0;
}

