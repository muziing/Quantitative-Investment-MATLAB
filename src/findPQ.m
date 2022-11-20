% 基于AIC BIC 暴力选定ARMA阶数
function [p, q] = findPQ(data, pmax, qmax)
    data = reshape(data, length(data), 1);
    LOGL = zeros(pmax + 1, qmax + 1);
    PQ = zeros(pmax + 1, qmax + 1);

    for p = 0:pmax

        for q = 0:qmax
            model = arima(p, 0, q);
            [~, ~, logL] = estimate(model, data); %指定模型的结构
            LOGL(p + 1, q + 1) = logL;
            PQ(p + 1, q + 1) = p + q; %计算拟合参数的个数
        end

    end

    LOGL = reshape(LOGL, (pmax + 1) * (qmax + 1), 1);
    PQ = reshape(PQ, (pmax + 1) * (qmax + 1), 1);
    m2 = length(data);
    [aic, bic] = aicbic(LOGL, PQ + 1, m2);
    aic0 = reshape(aic, (pmax + 1), (qmax + 1));
    bic0 = reshape(bic, (pmax + 1), (qmax + 1));

    aic1 = min(aic0(:));
    index = aic1 == aic0;
    [pp, qq] = meshgrid(0:pmax, 0:qmax);
    p0 = pp(index);
    q0 = qq(index);

    aic2 = min(bic0(:));
    index = aic2 == bic0;
    [pp, qq] = meshgrid(0:pmax, 0:qmax);
    p1 = pp(index);
    q1 = qq(index);

    if p0^2 + q0^2 > p1^2 + q1^2
        p = p1;
        q = q1;
    else
        p = p0;
        q = q0;
    end

end
