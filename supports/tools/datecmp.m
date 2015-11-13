function a=datecmp(y1, m1, d1, y2, m2, d2)
a = 1;
    if y1 == y2 && m1 == m2 && d1 == d2
        a = 0;
    elseif (y1 > y2) || (y1 == y2 && m1 > m2) || (y1 == y2 && m1 == m2 && d1 > d2)
        a = -1;
    end


end
