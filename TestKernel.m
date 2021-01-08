function [out] = TestKernel(x,a)

if abs(x) <= 1
    out = (a+2)*(abs(x)^3) - (a + 3)*(x^2) + 1;
elseif 1 < abs(x) && abs(x) < 2
    out = a*(abs(x)^3) - 5*a*(x^2) + 8*a*abs(x) - 4*a;
else
    out = 0;
end

end