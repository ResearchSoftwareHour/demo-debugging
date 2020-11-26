program broken
  use broken_mod
  implicit none
! This program compute the values of the following series:
! (x^0)/0! + (x^1)/1! + (x^2)/2! + (x^3)/3! + (x^4)/4! + ........ + (x^n)/n! 

  real(kind=8) :: series
  real(kind=8) :: x
  integer      :: n


  print*, 'Compute (x^0)/0! + (x^1)/1! + (x^2)/2! + (x^3)/3! + (x^4)/4! + ........ + (x^n)/n!'

  print*, "Please enter the value of x : "
  read*,x
  
  print*, "Please enter an integer value for n : " 
  read*, n

  series = ComputeSeriesValue(x, n);
  print*, "The value of the series for the values entered is ", series 

end program broken
