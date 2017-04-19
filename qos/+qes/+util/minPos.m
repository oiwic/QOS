function d = minPos(l,c,r)
% returns the minmum position of this parabola, bounded by -1 and 1.
% l, c, r are the values of a parabola at -1, 0, 1.

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

% model: f(x) = a*x^2 + b*x + c
% 


    d = l+r-2*c;
<<<<<<< HEAD
    if d <= 0
        d = 0;
=======
    if d < 0
%         if r == c
%             d = 0;
%         elseif r > c
%             d = -1;
%         else
%             d = 1;
%         end
        d=0;
>>>>>>> bd34fc82e0f2203a3dcb472421ae7d9756ab687d
        return;
    end
%     if d == 0
%         if r == c
%             d = 0;
%         elseif r > c
%             d = -1;
%         else
%             d = 1;
%         end
%         return;
%     end
    d = 0.5*(l -r)/d;
    if d > 1
        d = 1;
    elseif d < -1
        d = -1;
    end
end