program memleak
  implicit none

  call foo()

contains

  subroutine foo
    implicit none
    integer, dimension(:), pointer :: x

    allocate(x(10))

    x(1000) = 0         ! heap block overrun
    return            ! x not deallocated
  end subroutine foo

end program memleak
