
% --- Declaración dinámica para el predicado estudiante/4 ---
% Permite modificar la base de datos de estudiantes en tiempo de ejecución
:- dynamic estudiante/4.



% --- Imprime minutos totales en formato hh:mm ---
imprimir_horas_minutos(MinutosTotales) :-
    Horas is MinutosTotales // 60,
    Minutos is MinutosTotales mod 60,
    write(Horas), write(':'),
    (Minutos < 10 -> write('0'); true), write(Minutos).


% --- Calcula la duración de permanencia de un estudiante en el campus ---
calcular_duracion_en_campus(ID_Estudiante, Duracion) :-
    estudiante(ID_Estudiante, _, HoraEntrada, HoraSalida),
    HoraSalida =\= 0,
    Duracion is HoraSalida - HoraEntrada.


% --- Imprime la información de un estudiante en formato legible ---
imprimir_info_estudiante(estudiante(ID, Nombre, HoraEntrada, HoraSalida)) :-
    write('ID: '), write(ID), write(' | Nombre: '), write(Nombre),
    (
        HoraEntrada =:= 0, HoraSalida =:= 0 ->
            write(' | Estado: No ha entrado'), nl
        ;
        HoraSalida =:= 0 ->
            write(' | Entrada: '), imprimir_horas_minutos(HoraEntrada),
            write(' | Estado: En el campus'), nl
        ;
            Duracion is HoraSalida - HoraEntrada,
            write(' | Entrada: '), imprimir_horas_minutos(HoraEntrada),
            write(' | Salida: '), imprimir_horas_minutos(HoraSalida),
            write(' | Duracion: '), imprimir_horas_minutos(Duracion), write(' h'), nl
    ), nl.



% --- Registrar la entrada de un estudiante (Check-in) ---
registrar_entrada_estudiante :-
    write('Ingrese el ID del estudiante: '), read(ID_Estudiante),
    (estudiante(ID_Estudiante, Nombre, HoraEntrada, HoraSalida) ->
        ((HoraEntrada =\= 0, HoraSalida =:= 0) ->
            write('El/La estudiante ya esta registrado como presente en el campus.'), nl
        ;
            get_time(Timestamp),
            stamp_date_time(Timestamp, date(_,_,_,Horas,Minutos,_,_,_,_), 'local'),
            MinutosEntrada is Horas * 60 + Minutos,  % Guardar en minutos para facilitar cálculos
            retract(estudiante(ID_Estudiante, Nombre, _, _)),
            assertz(estudiante(ID_Estudiante, Nombre, MinutosEntrada, 0)),
            write('Entrada registrada correctamente a las '), imprimir_horas_minutos(MinutosEntrada), write(' h'), nl,
            guardar_datos_estudiantes
        )
    ;
        write('El ID ingresado no corresponde a un estudiante registrado.'), nl
    ).
    


% --- Buscar información de un estudiante por su ID ---
buscar_estudiante_por_id :-
    write('Ingrese el ID del estudiante: '), read(ID_Estudiante),
    (estudiante(ID_Estudiante, Nombre, HoraEntrada, HoraSalida) ->
        (HoraSalida =:= 0 ->
            write('El/La estudiante '), write(Nombre), write(' esta actualmente en el campus. Hora de entrada: '), imprimir_horas_minutos(HoraEntrada), nl
        ;
            calcular_duracion_en_campus(ID_Estudiante, Duracion),
            write('El/La estudiante '), write(Nombre), write(' ya salio del campus. Hora de salida: '), imprimir_horas_minutos(HoraSalida),
            write(' | Duracion: '), imprimir_horas_minutos(Duracion), write(' h'), nl
        )
    ;
        write('No se encontro un estudiante con ese ID.'), nl
    ).


% --- Registrar la salida de un estudiante (Check-out) ---
registrar_salida_estudiante :-
    write('Ingrese el ID del estudiante: '), read(ID_Estudiante),
    get_time(Timestamp),
    stamp_date_time(Timestamp, date(_,_,_,Horas,Minutos,_,_,_,_), 'local'),
    MinutosSalida is Horas * 60 + Minutos,
    (estudiante(ID_Estudiante, Nombre, MinutosEntrada, 0) ->
        retract(estudiante(ID_Estudiante, Nombre, MinutosEntrada, 0)),
        assertz(estudiante(ID_Estudiante, Nombre, MinutosEntrada, MinutosSalida)),
        write('Salida registrada correctamente a las '), imprimir_horas_minutos(MinutosSalida), write(' h'), nl,
        guardar_datos_estudiantes
    ;
        write('No se encontro un registro de entrada pendiente para este estudiante.'), nl
    ).

% --- Nueva opción: Calcular tiempo de permanencia de un estudiante ---
calcular_tiempo_permanencia_estudiante :-
    write('Ingrese el ID del estudiante: '), read(ID_Estudiante),
    (estudiante(ID_Estudiante, Nombre, HoraEntrada, HoraSalida) ->
        (HoraSalida =:= 0 ->
            write('El/La estudiante '), write(Nombre), write(' aun no ha registrado su salida.'), nl
        ;
            Duracion is HoraSalida - HoraEntrada,
            write('Tiempo de permanencia de '), write(Nombre), write(': '), imprimir_horas_minutos(Duracion), write(' h'), nl
        )
    ;
        write('No se encontro un estudiante con ese ID.'), nl
    ).


% --- Listar todos los estudiantes registrados ---
listar_estudiantes_registrados :-
    findall(estudiante(ID, Nombre, Entrada, Salida), estudiante(ID, Nombre, Entrada, Salida), ListaEstudiantes),
    write('Listado de estudiantes registrados:'), nl,
    maplist(imprimir_info_estudiante, ListaEstudiantes).


% --- Guardar todos los estudiantes en el archivo de texto ---

guardar_datos_estudiantes :-
    prolog_load_context(directory, Dir),
    directory_file_path(Dir, 'UniversityProlog.txt', FilePath),
    open(FilePath, write, Archivo),
    forall(
        estudiante(ID, Nombre, Entrada, Salida),
        (writeq(Archivo, estudiante(ID, Nombre, Entrada, Salida)), write(Archivo, '.'), nl(Archivo))
    ),
    close(Archivo).



% --- Cargar los datos de estudiantes desde el archivo de texto ---
cargar_datos_estudiantes :-
    prolog_load_context(directory, Dir),
    directory_file_path(Dir, 'UniversityProlog.txt', FilePath),
    (exists_file(FilePath) -> consult(FilePath) ; true).



% --- Menú principal de la aplicación ---
mostrar_menu :-
    write('Bienvenido al sistema de registro de estudiantes'), nl,
    write('1. Registrar entrada'), nl,
    write('2. Buscar estudiante'), nl,
    write('3. Registrar salida'), nl,
    write('4. Calcular tiempo de estancia'), nl,
    write('5. Listar todos los estudiantes'), nl,
    write('6. Salir'), nl,
    write('Seleccione una opcion: '), read(Opcion), ejecutar_opcion_menu(Opcion).

% --- Lógica para ejecutar la opción seleccionada en el menú ---
ejecutar_opcion_menu(1) :- registrar_entrada_estudiante, mostrar_menu.
ejecutar_opcion_menu(2) :- buscar_estudiante_por_id, mostrar_menu.
ejecutar_opcion_menu(3) :- registrar_salida_estudiante, mostrar_menu.
ejecutar_opcion_menu(4) :- calcular_tiempo_permanencia_estudiante, mostrar_menu.
ejecutar_opcion_menu(5) :- listar_estudiantes_registrados, mostrar_menu.
ejecutar_opcion_menu(6) :- write('Saliendo del sistema...'), nl.
ejecutar_opcion_menu(_) :- write('Opcion no valida. Intente de nuevo.'), nl, mostrar_menu.


% --- Punto de entrada principal ---
iniciar_aplicacion :-
    cargar_datos_estudiantes,
    mostrar_menu.

:- iniciar_aplicacion.
