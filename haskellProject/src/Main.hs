module Main (main) where

import Data.Time.LocalTime (LocalTime, getZonedTime, zonedTimeToLocalTime, diffLocalTime, localTimeOfDay)
import Prelude hiding (id)
import System.IO (readFile')
import Text.Printf (printf)

main :: IO ()
main = do
    loadedList <- loadData "University.txt"
    menuHs loadedList

data Student = Student
    { studentName :: String
    , studentId   :: Int
    , entryTime   :: Maybe LocalTime
    , exitTime    :: Maybe LocalTime
    } deriving (Show, Read)

formatDuration :: RealFrac a => a -> String
formatDuration duration =
    let totalSecs = round duration :: Integer
        hours = totalSecs `div` 3600
        mins = (totalSecs `mod` 3600) `div` 60
        secs = totalSecs `mod` 60
    in printf "%02d:%02d:%02d" hours mins secs

formatTimeOnly :: LocalTime -> String
formatTimeOnly time = 
    let tod = localTimeOfDay time
    in take 8 (show tod)

sameId :: Int -> Student -> Bool
sameId targetId s = targetId == studentId s

checkIn :: Int -> LocalTime -> [Student] -> (String, [Student])
checkIn targetId ciTime studentList =
    case filter (sameId targetId) studentList of
        [] -> ("La/El estudiante no está matriculado", studentList)
        (s : _) -> case entryTime s of
            Just _ -> ("La/El estudiante ya se encuentra dentro del campus", studentList)
            Nothing -> 
                let updatedList = map (\x -> if sameId targetId x
                                             then x { entryTime = Just ciTime }
                                             else x) studentList
                in ("La/El estudiante entró a las " ++ formatTimeOnly ciTime, updatedList)

searchStudent :: Int -> [Student] -> String
searchStudent targetId studentList =
    case filter (sameId targetId) studentList of
        [] -> "La/El estudiante no está matriculado en el sistema"
        (s : _) -> case (entryTime s, exitTime s) of
            (Just ciTime, Nothing) -> 
                "La/El estudiante " ++ studentName s ++ " está dentro del campus. Ingreso a las: " ++ formatTimeOnly ciTime
            _ -> "La/El estudiante no ha ingresado o ya ha salido"

checkOut :: Int -> LocalTime -> [Student] -> (String, [Student])
checkOut targetId coTime studentList = 
    case filter (sameId targetId) studentList of
        [] -> ("La/El estudiante no está matriculado", studentList)
        (s : _) -> case entryTime s of
            Nothing -> ("La/El estudiante no ha ingresado al campus", studentList)
            Just _ ->
                let updatedList = map (\x -> if sameId targetId x
                                             then x { exitTime = Just coTime }
                                             else x) studentList
                in ("La/El estudiante salió a las " ++ formatTimeOnly coTime, updatedList)

calcTime :: LocalTime -> LocalTime -> String
calcTime inTime outTime =   
    let duration = diffLocalTime outTime inTime
    in "Tiempo en el campus: " ++ formatDuration duration

listAllStudents :: [Student] -> String
listAllStudents studentList = 
    let formatTime Nothing = "No registrado"
        formatTime (Just t) = formatTimeOnly t
        formatStudent s = " | ID: " ++ show (studentId s) ++ " | Nombre: " ++ studentName s ++ " | Entrada: " ++ formatTime (entryTime s) ++ " | Salida: " ++ formatTime (exitTime s)
    in unlines (map formatStudent studentList)

saveData :: [Student] -> FilePath -> IO ()
saveData studentList filePath = writeFile filePath (show studentList)

loadData :: FilePath -> IO [Student]
loadData filePath = do
    content <- readFile' filePath
    return (read content :: [Student])

menuHs :: [Student] -> IO ()
menuHs studentList = do
    putStrLn "Bienvenido al sistema de registro de estudiantes"
    putStrLn "1. Registrar entrada"
    putStrLn "2. Buscar estudiante"
    putStrLn "3. Registrar salida"
    putStrLn "4. Calcular tiempo de estancia"
    putStrLn "5. Listar todos los estudiantes"
    putStrLn "6. Salir"
    option <- getLine
    case option of
        "1" -> do
            putStrLn "Ingrese el ID del estudiante:"
            id <- read <$> getLine
            zonedTime <- getZonedTime
            let ciTime = zonedTimeToLocalTime zonedTime
            let (message, updatedList) = checkIn id ciTime studentList
            putStrLn message
            saveData updatedList "University.txt"
            menuHs updatedList
        "2" -> do
            putStrLn "Ingrese el ID del estudiante a buscar:"
            id <- read <$> getLine
            putStrLn (searchStudent id studentList)
            menuHs studentList
        "3" -> do
            putStrLn "Ingrese el ID del estudiante que sale:"
            id <- read <$> getLine
            zonedTime <- getZonedTime
            let coTime = zonedTimeToLocalTime zonedTime
            let (message, updatedList) = checkOut id coTime studentList
            putStrLn message
            saveData updatedList "University.txt"
            menuHs updatedList
        "4" -> do
            putStrLn "Ingrese el ID del estudiante para calcular el tiempo de estancia:"
            id <- read <$> getLine
            case filter (sameId id) studentList of
                [] -> putStrLn "El estudiante no está matriculado"
                (Student _ _ Nothing _ : _) -> putStrLn "El estudiante no ha ingresado"
                (Student _ _ (Just _) Nothing : _) -> putStrLn "El estudiante aún no ha salido"
                (Student _ _ (Just ciTime) (Just coTime) : _) -> putStrLn (calcTime ciTime coTime)
            menuHs studentList
        "5" -> do
            putStrLn "--- DATOS EN EL ARCHIVO ---"
            putStr (listAllStudents studentList)
            menuHs studentList
        "6" -> putStrLn "Saliendo del sistema."
        _ -> do
            putStrLn "Opción no válida, por favor intente de nuevo."
            menuHs studentList