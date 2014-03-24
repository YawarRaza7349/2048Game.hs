import Data.List
import Data.Maybe
import Data.Ratio
import System.Random

data Direction = DirUp | DirDown | DirLeft | DirRight deriving (Eq)

type Tile = Maybe Int
type Row = [Tile]
type Board = [Row]

chunks :: Int -> [a] -> [[a]]
chunks s l | s <= 0 = undefined
           | [] <- l = []
           | otherwise = t : (chunks s d) where (t,d) = splitAt s l

fillEmpties :: [[Int]] -> Board
fillEmpties = map ((take 4) . (++(repeat Nothing)) . map (\x -> Just x))

shiftBoardLeft :: Board -> [[Int]]
shiftBoardLeft = map catMaybes

mergeTiles :: [[Int]] -> [[Int]]
mergeTiles = map $ concat . map ((map sum) . (chunks 2)) . group

makeMoveLeft :: Board -> Board
makeMoveLeft = fillEmpties . mergeTiles . shiftBoardLeft

makeMove :: Direction -> Board -> Board
makeMove DirLeft = makeMoveLeft
makeMove DirRight = (map reverse) . makeMoveLeft . (map reverse)
makeMove DirUp = transpose . makeMoveLeft . transpose
makeMove DirDown = reverse . (makeMove DirUp) . reverse

possibleUnitBoards :: Int -> [Board]
possibleUnitBoards i = map (chunks 4) $ zipWith (++) (inits l) (map ((Just i):) $ tails l) where l = replicate 15 Nothing

overlapBoards :: Board -> Board -> Board
overlapBoards = zipWith $ zipWith $ (\f s -> listToMaybe $ take 1 $ catMaybes [f,s])

possibleMoves :: [(Int, Board)]
possibleMoves = zip (repeat 9) (possibleUnitBoards 2) ++ zip (repeat 1) (possibleUnitBoards 4)

possibleNextMoves :: Board -> [(Int, Board)]
possibleNextMoves b = zip is $ map (overlapBoards b) bs where (is, bs) = unzip possibleMoves

possibleNextMovesNonRepeat :: Board -> [(Int, Board)]
possibleNextMovesNonRepeat b = filter ((/= b) . snd) $ possibleNextMoves b

weightsToCondProb :: [Int] -> [(Int, Int)]
weightsToCondProb ws = zipWith (,) ws $ map sum $ tails ws

chooseRandomNextBoardHelper :: StdGen -> [((Int, Int), Board)] -> (Board, StdGen)
chooseRandomNextBoardHelper g (((n, d), b):pbs) = if r < n then (b, ng) else chooseRandomNextBoardHelper g pbs where (r, ng) = randomR (0, d-1) g

chooseRandomNextBoard :: StdGen -> [(Int, Board)] -> (Board, StdGen)
chooseRandomNextBoard g wbs = chooseRandomNextBoardHelper g $ zip (weightsToCondProb ws) bs where (ws, bs) = unzip wbs

randomMove :: (Board, StdGen) -> (Board, StdGen)
randomMove p@(b, g) = if nxt == [] then p else chooseRandomNextBoard g nxt where nxt = possibleNextMovesNonRepeat b

movableBoard :: Board -> Bool
movableBoard b = any (any isNothing . concat) $ map (flip makeMove b) [DirUp, DirLeft]

pureGame :: StdGen -> [Direction] -> [Board]
pureGame gn ds = map head $ group $ e ++ (take 1 f) where (e, f) = span movableBoard $ map (fst . ($ (randomMove $ randomMove (replicate 4 $ replicate 4 Nothing, gn)))) (scanl (flip (.)) id $ map (\d o@(b, g) -> let nxt = makeMove d b in if nxt == b then o else randomMove (nxt, g)) ds)

showBoard :: Board -> String
showBoard b = intercalate "\n" $ map (intercalate " ") $ transpose $ map (\c -> map (reverse . take (maximum (map length c)) . (++(repeat ' ')) . reverse) c) ns where ns = transpose $ map (map (\x -> case x of Just y -> show y; Nothing -> "_")) b

readDirection :: Char -> Maybe Direction
readDirection = flip lookup [('a', DirLeft), ('d', DirRight), ('w', DirUp), ('s', DirDown)]

main :: IO ()
main = do myGen <- getStdGen
          interact $ concat . map ('\n':) . map (++"\n") . map showBoard . pureGame myGen . mapMaybe readDirection