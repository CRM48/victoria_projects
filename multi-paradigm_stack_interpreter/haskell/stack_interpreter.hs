module Main where 
import System.Environment
import System.IO  
import Control.Monad
import Text.Read (readMaybe) 
import qualified Debug.Trace as Debug
import Data.Char ( toLower, toUpper )
import Data.Bits (shiftL, shiftR, xor, complement)
import Data.List (isPrefixOf, stripPrefix, transpose)
import qualified Data.Matrix as M -- Should work as long as the Matrix package is included
import qualified Data.Vector as V
import Data.Maybe (fromMaybe)



main :: IO ()
main = do 
        args <- getArgs
        contents <- readFile (head args)
        let filename = head args
        let filenum = drop (length filename - 7) filename
        let groupedContents = split contents
        let output = evaluate groupedContents
        writeFile ("outputs/output-" ++ filenum) (process output) 
        print $ groupedContents
        print output
        
 
-- Method to process output
process :: [[Char]] -> [Char]
process output = "START\n" ++ unlines output ++ "END"

-- Method to split inputs accordingly
split :: [Char] -> [[Char]]

-- go accumulator ([{") processed (data already processed) token (datatype being processed) depth (for square brackets)
split = go "" [] Nothing 0
  where
    -- Base case: Return the processed array
    go acc processed _ _ [] =
      if null acc then processed else processed ++ [acc]

    -- Handling of square braces, continue grouping until equal number of closing braces
    go acc processed (Just '[') depth (c:cs)
      | c == '[' = go (acc ++ [c]) processed (Just '[') (depth + 1) cs
      | c == ']' =
          let newAcc = acc ++ [c]
          in if depth == 1
               then go "" (processed ++ [newAcc]) Nothing 0 cs
               else go newAcc processed (Just '[') (depth - 1) cs
      | otherwise = go (acc ++ [c]) processed (Just '[') depth cs

    -- Handling of curly braces, same as sqaure brace (unlikely to have inner {}, but should still handle it)
    go acc processed (Just '{') depth (c:cs)
      | c == '{' = go (acc ++ [c]) processed (Just '{') (depth + 1) cs
      | c == '}' =
          let newAcc = acc ++ [c]
          in if depth == 1
               then go "" (processed ++ [newAcc]) Nothing 0 cs
               else go newAcc processed (Just '{') (depth - 1) cs
      | otherwise = go (acc ++ [c]) processed (Just '{') depth cs

    -- Handling of strings, just match a closing string
    go acc processed (Just '"') depth (c:cs)
      | c == '"' = go (acc ++ [c]) processed Nothing 0 cs
      | otherwise = go (acc ++ [c]) processed (Just '"') depth cs

    -- When no condition (i.e., [{") add to list, or set condition
    go acc processed Nothing _ (c:cs)
      | c == '['  = go [c] processed (Just '[') 1 cs
      | c == '{'  = go [c] processed (Just '{') 1 cs
      | c == '"'  = go [c] processed (Just '"') 1 cs
      | c == ' ' || c == '\n' =
          if null acc then go "" processed Nothing 0 cs
          else go "" (processed ++ [acc]) Nothing 0 cs
      | otherwise = go (acc ++ [c]) processed Nothing 0 cs


-- Declare stack type
type Stack = [String]

-- Function to evaluate elements in the input array
evaluate :: [String] -> Stack
evaluate tokens = reverse (foldl step [] tokens)
  where
    step :: Stack -> String -> Stack
    step stack token
        | "'" `isPrefixOf` token = tail token : stack
        | "{" `isPrefixOf` token = applyOp "lambda" (token : stack)
        | token `elem` ["+", "-", "*", "/", "**", "%", "DROP", "DUP", "SWAP", "ROT", "ROLL", "ROLLD", "==", "!=", "<", ">", "<=", ">=", "<=>", "IFELSE", "&", "|", "^", "<<", ">>", "!", "x", "TRANSP", "~", "EVAL"] = applyOp token stack
        | otherwise = token : stack

stripQuotes :: String -> Maybe String
stripQuotes s
    | head s == '"' && last s == '"' = Just (init (tail s))
    | otherwise = Nothing

capitalise :: String -> String
capitalise (x:xs) = toUpper x : map toLower xs

parseMatrix :: String -> [[Int]]
parseMatrix str = read str :: [[Int]]


-- Apply Op functions, applies an operation to elements of the stack
applyOp :: String -> Stack -> Stack

applyOp "+" (x:y:rest) = 
    case (readMaybe x :: Maybe Int, readMaybe y :: Maybe Int) of
        (Just xInt, Just yInt) -> show (yInt + xInt) : rest
        _ -> case (readMaybe x :: Maybe Float, readMaybe y :: Maybe Float) of
            (Just xFloat, Just yFloat) -> show (yFloat + xFloat) : rest
            (Just xFloat, Nothing) -> show (xFloat + fromIntegral (read y :: Int)) : rest
            (Nothing, Just yFloat) -> show (yFloat + fromIntegral (read x :: Int)) : rest
            _ -> case (stripQuotes x, stripQuotes y) of
                (Just xStr, Just yStr) -> ('"' : (yStr ++ xStr) ++ "\"") : rest
                _ -> case (readMaybe x :: Maybe [[Int]], readMaybe y :: Maybe [[Int]]) of
                    (Just xList, Just yList) ->
                        let xMat = M.fromLists xList
                            yMat = M.fromLists yList
                            zMat = M.elementwise (+) xMat yMat
                        in show (M.toLists zMat) : rest
                    _ -> case (readMaybe x :: Maybe [Int], readMaybe y :: Maybe [Int]) of
                        (Just xList, Just yList) ->
                            let xVec = V.fromList xList
                                yVec = V.fromList yList
                                zVec = V.zipWith (+) xVec yVec
                            in show (V.toList zVec) : rest


applyOp "-" (x:y:rest) = 
    case (readMaybe x :: Maybe Int, readMaybe y :: Maybe Int) of
        (Just xInt, Just yInt) -> show (yInt - xInt) : rest
        _ -> case (readMaybe x :: Maybe Float, readMaybe y :: Maybe Float) of
            (Just xFloat, Just yFloat) -> show (yFloat - xFloat) : rest
            (Just xFloat, Nothing) -> show (xFloat - fromIntegral (read y :: Int)) : rest
            (Nothing, Just yFloat) -> show (yFloat - fromIntegral (read x :: Int)) : rest

applyOp "*" (x:y:rest) = 
    case (readMaybe x :: Maybe Int, readMaybe y :: Maybe Int) of
        (Just xInt, Just yInt) -> show (yInt * xInt) : rest
        _ -> case (readMaybe x :: Maybe Int, stripQuotes y) of
            (Just xInt, Just yStr) ->
                let repeatedString = concat(replicate xInt yStr)
                in ('"' : repeatedString ++ "\"") : rest
            _ -> case (readMaybe x :: Maybe Float, readMaybe y :: Maybe Float) of
                (Just xFloat, Just yFloat) -> show (yFloat * xFloat) : rest
                (Just xFloat, Nothing) -> show (xFloat * fromIntegral (read y :: Int)) : rest
                (Nothing, Just yFloat) -> show (yFloat * fromIntegral (read x :: Int)) : rest
                _ -> case (readMaybe x :: Maybe [[Int]], readMaybe y :: Maybe [[Int]]) of
                    (Just xList, Just yList) ->
                        let xMat = M.fromLists xList
                            yMat = M.fromLists yList
                            zMat = xMat * yMat
                        in show (M.toLists zMat) : rest
                    _ -> case (readMaybe x :: Maybe [Int], readMaybe y :: Maybe [Int]) of
                        (Just xList, Just yList) ->
                            let xVec = V.fromList xList
                                yVec = V.fromList yList
                                dot = V.sum (V.zipWith (*) xVec yVec)
                            in show dot : rest
                        _ -> case (readMaybe x :: Maybe [[Int]], readMaybe y :: Maybe [Int]) of
                            (Just xList, Just yList) -> show (vectorTimesMatrix yList xList) : rest
                            _ -> case (readMaybe x :: Maybe [Int], readMaybe y :: Maybe [[Int]]) of
                                (Just xList, Just yList) -> show (matrixTimesVector yList xList) : rest

applyOp "/" (x:y:rest) = 
    case (readMaybe x :: Maybe Int, readMaybe y :: Maybe Int) of
        (Just xInt, Just yInt) -> show (yInt `div` xInt) : rest
        _ -> case (readMaybe x :: Maybe Float, readMaybe y :: Maybe Float) of
            (Just xFloat, Just yFloat) -> show (yFloat / xFloat) : rest
            (Just xFloat, Nothing) -> show (xFloat / fromIntegral (read y :: Int)) : rest
            (Nothing, Just yFloat) -> show (yFloat / fromIntegral (read x :: Int)) : rest

applyOp "**" (x:y:rest) = 
    case (readMaybe x :: Maybe Int, readMaybe y :: Maybe Int) of
        (Just xInt, Just yInt) -> show (yInt ^ xInt) : rest
        _ -> case (readMaybe x :: Maybe Float, readMaybe y :: Maybe Float) of
            (Just xFloat, Just yFloat) -> show (yFloat ** xFloat) : rest
            (Just xFloat, Nothing) -> show (xFloat ** fromIntegral (read y :: Int)) : rest
            (Nothing, Just yFloat) -> show (yFloat ** fromIntegral (read x :: Int)) : rest

applyOp "%" (x:y:rest) = 
    case (readMaybe x :: Maybe Int, readMaybe y :: Maybe Int) of
        (Just xInt, Just yInt) -> show (yInt `mod` xInt) : rest
        _ -> case (readMaybe x :: Maybe Float, readMaybe y :: Maybe Float) of
            (Just xFloat, Just yFloat) -> show (floatMod xFloat yFloat) : rest
            (Just xFloat, Nothing) -> show (floatMod (fromIntegral (read y :: Int)) xFloat) : rest
            (Nothing, Just yFloat) -> show (floatMod (fromIntegral (read x :: Int)) yFloat ) : rest


applyOp "DROP" (_:rest) = rest
applyOp "DUP" (x:rest) = x : x : rest
applyOp "SWAP" (x:y:rest) = y : x : rest
applyOp "ROT" (x:y:z:rest) = z : x : y : rest


applyOp "ROLL" (n:stack) =
  case readMaybe n :: Maybe Int of
    Just nInt ->
      if nInt > 0 && nInt <= length stack then
        let (toRotate, rest) = splitAt nInt stack
            rotated = last toRotate : init toRotate
        in rotated ++ rest
      else stack

applyOp "ROLLD" (n:stack) =
  case readMaybe n :: Maybe Int of
    Just nInt ->
      if nInt > 0 && nInt <= length stack then
        let (toRotate, rest) = splitAt nInt stack
            rotated = tail toRotate ++ [head toRotate]
        in rotated ++ rest
      else stack

applyOp op (x:y:rest)
  | op `elem` ["==", "!=", "<", ">", "<=", ">="] = compareValues op y x : rest

applyOp "<=>" (x:y:rest)
    | compareValues "<" x y == "true" = "-1" : rest 
    | compareValues ">" x y == "true"  = "1" : rest
    | otherwise = "0" : rest

applyOp "IFELSE" (x:y:z:rest)
    | x == "true" = z:rest
    | x == "false" = y:rest
    | otherwise = rest

applyOp "&" (x:y:rest) = 
    case (readMaybe (capitalise x) :: Maybe Bool, readMaybe (capitalise y) :: Maybe Bool) of
        (Just xBool, Just yBool) -> map toLower (show (yBool && xBool)) : rest

applyOp "|" (x:y:rest) = 
    case (readMaybe (capitalise x) :: Maybe Bool, readMaybe (capitalise y) :: Maybe Bool) of
        (Just xBool, Just yBool) -> map toLower (show (yBool || xBool)) : rest

applyOp "^" (x:y:rest) = 
    case (readMaybe (capitalise x) :: Maybe Bool, readMaybe (capitalise y) :: Maybe Bool) of
        (Just xBool, Just yBool) -> map toLower (show ((yBool || xBool) && not (yBool && xBool))) : rest
        _ -> case (readMaybe x :: Maybe Int, readMaybe y :: Maybe Int) of
            (Just nInt, Just xInt) -> show (xInt `xor` nInt) : rest

applyOp "<<" (n:x:rest) = 
    case (readMaybe n :: Maybe Int, readMaybe x :: Maybe Int) of
        (Just nInt, Just xInt) -> show (xInt `shiftL` nInt) : rest

applyOp ">>" (n:x:rest) = 
    case (readMaybe n :: Maybe Int, readMaybe x :: Maybe Int) of
        (Just nInt, Just xInt) -> show (xInt `shiftR` nInt) : rest

applyOp "!" (x:rest) = 
    case (readMaybe (capitalise x) :: Maybe Bool) of
        (Just xBool) -> map toLower(show (not xBool)) : rest

applyOp "~" (x:rest) = 
    case (readMaybe x :: Maybe Int) of
        (Just xInt) -> show (complement xInt) : rest

applyOp "x" (x:y:rest) = 
    case (readMaybe x :: Maybe [Int], readMaybe y :: Maybe [Int]) of
        (Just xList, Just yList) -> show (crossProduct yList xList) : rest

applyOp "TRANSP" (x:rest) = 
    case (readMaybe x :: Maybe [[Int]]) of
        (Just xList) ->
            let xMat = M.fromLists xList
                transMat = M.transpose xMat
            in show (M.toLists transMat) : rest

applyOp "EVAL" (x:rest) =
    if head x == '{' then applyOp "lambda" (x : rest) else applyOp x rest

applyOp "lambda" (x:rest) = parseLambda x rest

applyOp _ stack = stack

-- Used for modular of floats
floatMod :: Float -> Float -> Float
floatMod y x = x - fromIntegral (floor (x / y)) * y

-- Cross product for vectors (Vector didn't include, and V3 was not importing properly)
crossProduct :: [Int] -> [Int] -> [Int]
crossProduct [a1, a2, a3] [b1, b2, b3] =
    [a2 * b3 - a3 * b2,
     a3 * b1 - a1 * b3,
     a1 * b2 - a2 * b1]

-- Matrix/Vector and Vector/Matric multiplications
matrixTimesVector :: [[Int]] -> [Int] -> [Int]
matrixTimesVector mat vec = map (sum . zipWith (*) vec) mat

vectorTimesMatrix :: [Int] -> [[Int]] -> [Int]
vectorTimesMatrix vec mat = map (sum . zipWith (*) vec) (transpose mat)

-- Deling with lambdas
parseLambda :: String -> [String] -> [String]
parseLambda lambda stack = 
    let stripped = init (tail lambda)
        list = split stripped
        numVars = read (head list) :: Int
        expr = drop 2 list
        (args, rest) = splitAt numVars stack
        varMap = zip (map (\i -> "x" ++ show i) [0..]) (reverse args)
        replaced = unwords $ map (\tok -> fromMaybe tok (lookup tok varMap)) expr
        replacedWithSelf = map (\tok -> if tok == "SELF" then "'" ++ lambda else tok) (split replaced)
        perform = evaluate replacedWithSelf
    in (reverse perform ++ rest)


-- Method for comparisons, must be int pair, float pair, float/int bool pair, or string pair (for == and != only)
compareValues :: String -> String -> String -> String
compareValues op x y =
    case (readMaybe x :: Maybe Int, readMaybe y :: Maybe Int) of
        (Just xInt, Just yInt) -> result (cmp xInt yInt)
        _ -> case (readMaybe x :: Maybe Float, readMaybe y :: Maybe Float) of
            (Just xFloat, Just yFloat) -> result (cmp xFloat yFloat)
            (Just xFloat, Nothing) -> result (cmp xFloat (fromIntegral (read y :: Int)))
            (Nothing, Just yFloat) -> result (cmp yFloat (fromIntegral (read x :: Int)))
            _ -> case (readMaybe (capitalise x) :: Maybe Bool, readMaybe (capitalise y) :: Maybe Bool) of
                (Just xBool, Just yBool) -> result (cmp xBool yBool)
                _ -> case (stripQuotes x, stripQuotes y) of
                    (Just xStr, Just yStr) -> result (cmp xStr yStr)
    where
        result True = "true"
        result False = "false"

        cmp :: Ord a => a -> a -> Bool
        cmp = case op of
            "==" -> (==)
            "!=" -> (/=)
            "<"  -> (<)
            ">"  -> (>)
            "<=" -> (<=)
            ">=" -> (>=)