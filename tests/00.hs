
fac :: Int -> Int

constant   ::   Int
constant= 0

strange ::   Int -> Int -> Int
strange _ a_ = a_ `mod` 3


division :: Double -> Double -> Double
division a b = a / b + 0.5 -- comment

fac 0 = 1
fac n | n > 0 = n * (fac (n - 1))

    -- one line comment

multiplication ::Int -> Int->Int
multiplication n' _3| n'>0= 0
multiplication n' k  | n' < 1 && (k > 0) = 1

main ::     IO()

main = print (fac (fac (5+2 * (3 - 4))))
