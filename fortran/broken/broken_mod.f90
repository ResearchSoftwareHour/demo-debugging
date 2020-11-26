module broken_mod
  implicit none

  contains

    function ComputeFactorial(number) result(fact)
      implicit none  
      integer, intent(in) :: number
      integer :: fact
      integer :: j

      fact = 0;

      do j=1, number
        fact = fact * j;
      end do
    end function ComputeFactorial

    function ComputeSeriesValue(x, n) result(seriesValue)
      implicit none
      real(kind=8), intent(in) :: x
      integer     , intent(in) :: n
      real(kind=8)             :: seriesValue
      real(kind=8)             :: xpow = 1
      integer                  :: k

      seriesValue = 0.0;
      xpow = 1;

      do k=0, n
        seriesValue = seriesValue + xpow / ComputeFactorial(k);
        xpow = xpow * x;
      end do
    end function ComputeSeriesValue

end module broken_mod
