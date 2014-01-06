with Gol_logic; use Gol_logic;

package body Gol_concurrent is

   -- WORKER
   ----------------------------------------------------------------------
   task body Worker is
      whole_board          : Array2D (1 .. MAX_SIZE, 1 .. MAX_SIZE);
      local_board_copy     : Array2D (1 .. MAX_SIZE, 1 .. MAX_SIZE / 2);
      next_iteration_board : Array2D (1 .. MAX_SIZE, 1 .. MAX_SIZE / 2);
      column_start_range   : Integer;
      column_end_range     : Integer;
      worker_number        : Integer;
      alive_tmp            : Integer;
      cell_state_tmp       : Float;
   begin
      for I in 1 .. ITERATIONS loop

         -- entry sluzy do wypelnienia czastki calej tablicy - kazdy worker ma
         -- lokalna kopie swojej czesci
         -- param board: cala tablica
         -- param column_to: na ktorej kolumnie konczy sie czesc
         -- param column_from: od ktorej kolumny zaczyna sie czesc
         -- current worker number: nadzorca nadaje workerom numery
         accept fill_board_part (
           board                  : Array2D;
            column_from           : Integer;
            column_to             : Integer;
            current_worker_number : Integer) do

            whole_board        := board;
            column_start_range := column_from;
            column_end_range   := column_to;
            worker_number      := current_worker_number;

            for I in 1 .. MAX_SIZE loop
               for J in column_from .. column_to loop
                  local_board_copy (I, J -
                                       (current_worker_number - 1) *
                                       MAX_SIZE /
                                       NUMBER_OF_WORKERS) := board (I, J);
               end loop;
            end loop;
         end fill_board_part;

	Ada.Text_IO.Put_Line("]]] Worker numer " & Integer'Image(worker_number) & " otrzymal swoj fragment tablicy..");

         -- entry sluzy do uruchomienia mechanizmu przetwarzania czesci tablicy
         accept process_data;

         for I in 1 .. local_board_copy'Length (1) loop
            for J in 1 .. local_board_copy'Length (2) loop

               --na lewej krawedzi
               if J = 1 then
                  if MAX_SIZE / NUMBER_OF_WORKERS * (worker_number - 1) /=
                     0
                  then
                     alive_tmp :=
                        Get_alive_neighbours_count
                          (whole_board,
                           worker_number,
                           local_board_copy,
                           I,
                           J,
                           True,
                           False);
                  end if;

               --na prawej krawedzi
               elsif J = local_board_copy'Length (2) then
                  if MAX_SIZE / NUMBER_OF_WORKERS * worker_number + 1 <
                     MAX_SIZE
                  then
                     alive_tmp :=
                        Get_alive_neighbours_count
                          (whole_board,
                           worker_number,
                           local_board_copy,
                           I,
                           J,
                           False,
                           True);
                  end if;
               else
                  alive_tmp :=
                     Get_alive_neighbours_count
                       (whole_board,
                        worker_number,
                        local_board_copy,
                        I,
                        J);
               end if;

               cell_state_tmp              := local_board_copy (I, J);
               next_iteration_board (I, J) :=
                  Get_updated_cell_state (cell_state_tmp, alive_tmp);
            end loop;
         end loop;

	 Ada.Text_IO.Put_Line("]]] Worker numer " & Integer'Image(worker_number) & " odsyla do Supervisora przetworzony fragment tablicy..");

         Supervisor.on_data_returned
           (next_iteration_board,
            column_start_range,
            column_end_range,
            worker_number);
      end loop;
   end Worker;

   -- NADZORCA
   --------------------------------------------------------------------
   task body Supervisor is
      -- tablica podleglych mu workerow
      workers                 : array (1 .. NUMBER_OF_WORKERS) of Worker;
      -- cala plansza w obecnej iteracji
      current_iteration_board : Array2D (1 .. MAX_SIZE, 1 .. MAX_SIZE);
      -- zmienna do przechoywwania kolumny
      column                  : Array2D (1 .. MAX_SIZE, 1 .. 1);
   begin
      Ada.Text_IO.Put_Line(">>> Worker rozpoczyna prace. Bok planszy to " & Integer'Image(MAX_SIZE) & ",");
      Ada.Text_IO.Put_Line(">>> mamy " & Integer'Image(NUMBER_OF_WORKERS) & " Workerow i " & Integer'Image(ITERATIONS) & " iteracji");

      Ada.Text_IO.Put_Line(">>> Worker wczytuje tablice z pliku " & IN_FILENAME);
      current_iteration_board :=
         Get_array_from_file (IN_FILENAME, MAX_SIZE, MAX_SIZE);

      for I in 1 .. ITERATIONS loop
	 Ada.Text_IO.Put_Line(">>> tablica w obecnej iteracji (" & Integer'Image(I) & "): ");
         Arrays2D.Print_array
           (current_iteration_board,
            current_iteration_board'Length (1),
            current_iteration_board'Length (2));

         for I in 1 .. NUMBER_OF_WORKERS loop
            workers (I).fill_board_part
              (current_iteration_board,
               MAX_SIZE / NUMBER_OF_WORKERS * (I - 1) + 1,
               MAX_SIZE / NUMBER_OF_WORKERS * I,
               I);
            workers (I).process_data;
         end loop;

         for I in 1 .. NUMBER_OF_WORKERS loop

            -- entry sluzy do poskladania danych. Wywoluja je workery gdy odsylaja
            -- swoje przetworzone czastki. Wtedy do calej tablicy w supervisorze
            -- wpisywane sa te czastki w odpowiednich miejscach
            -- param data: czesc danych ktora przyszla
            -- start_range: gdzie wpisac w duzej planszy
            -- end_range: -||-
            -- current_worker_number: ktory worker to odsyla
            accept on_data_returned (
              data                   : Array2D;
               start_range           : Integer;
               end_range             : Integer;
               current_worker_number : Integer) do

               for I in 1 .. MAX_SIZE loop
                  for J in start_range .. end_range loop
                     current_iteration_board (I, J) :=
                       data (I, J -
                                (current_worker_number - 1) * MAX_SIZE /
                                NUMBER_OF_WORKERS);
                  end loop;
               end loop;

            end on_data_returned;
         end loop;

         Put_Line (">>> Supervisor otrzymal fragmenty i je polaczyl: ");
         Print_array (current_iteration_board, MAX_SIZE, MAX_SIZE);
      end loop;

      Ada.Text_IO.Put_Line(">>> Worker zapisuje koncowa tablice do pliku " & OUT_FILENAME);
      write_array_to_file
           (current_iteration_board,
            OUT_FILENAME,
            MAX_SIZE,
            MAX_SIZE);

   end Supervisor;

end Gol_concurrent;
