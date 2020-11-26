#include <iostream>

void function_leaky() {

  double *my_array = new double[1000];

  // do some work ...

  // we forget to deallocate the array
  // delete[] my_array;
}

void function_out_of_bounds() {

  double *some_array = new double[1000];

  // out of bounds access
  some_array[1111] = 123.0;

  delete[] some_array;
}

void function_use_after_free() {

  double *another_array = new double[1000];

  // do some work ...

  // deallocate it, good!
  delete[] another_array;

  // however, we accidentally use the array
  // after it has been deallocated
  std::cout << "not sure what we get: " << another_array[123] << std::endl;
}

int main() {
  function_leaky();
  function_out_of_bounds();
  function_use_after_free();
}
