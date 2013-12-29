package body Gol_concurrent is

   --logika gry w zycie
   function Is_Alive (cell : Float) return Boolean is
   begin
      if cell = 0.0 then
         return False;
      else
         return True;
      end if;
   end Is_Alive;

   function Get_alive_neighbours_count
     (board            : Array2D;
      I                : Integer;
      J                : Integer;
      is_by_left_edge  : Boolean := False;
      is_by_right_edge : Boolean := False)
      return             Integer
   is
      alive_count        : Integer := 0;
      start_col, end_col : Integer;
   begin
      --tu na podstawie flag ustale gorny i dolny zakres..
      start_col := J - 1;
      end_col   := J + 1;

      if is_by_left_edge = True then
         start_col   := start_col + 1;
         alive_count := alive_count + --(-10);
                        Gol_concurrent.Get_edge_alive_neighbours_count
                           (J - 1,
                            I);
      end if;

      if is_by_right_edge = True then
         end_col     := end_col - 1;
         alive_count := alive_count + --666;
                        Gol_concurrent.Get_edge_alive_neighbours_count
                           (J + 1,
                            I);
      end if;

      for X in I - 1 .. I + 1 loop
         for Y in start_col .. end_col loop
            if (X /= I or Y /= J) and (X >= 1 and X <= MAX_SIZE) then
               if Is_Alive (board (X, Y)) then
                  alive_count := alive_count + 1;
               end if;
            end if;
         end loop;
      end loop;

      return alive_count;
   end Get_alive_neighbours_count;

   function Get_edge_alive_neighbours_count
     (col_num : Integer;
      row_num : Integer)
      return    Integer
   is
      column      : Array2D (1 .. MAX_SIZE, 1 .. 1);
      alive_count : Integer := 0;
      result : Boolean;
   begin
      --result := Gol_concurrent.shared_gameboard.Get_specific_column (column, col_num);

      for I in row_num - 1 .. row_num + 1 loop
         if I >= 1 and I <= MAX_SIZE then
            if Gol_concurrent.Is_Alive (column (I, 1)) then
               alive_count := alive_count + 1;
            end if;
         end if;

      end loop;

      return alive_count;
   end Get_edge_alive_neighbours_count;

   --regula conwaya
   --martwa ma 3 zywych to sie rodzi
   --zywa z 2 albo 3 zywymi nadal zywa, przeciwnym wypadku martwa
   function Get_updated_cell_state
     (cell_state       : Float;
      alive_neighbours : Integer)
      return             Float
   is
   begin
      if cell_state = 0.0 and alive_neighbours = 3 then
         return 1.0;
      end if;
      if cell_state = 1.0 and
         (alive_neighbours = 3 or alive_neighbours = 2)
      then
         return 1.0;
      end if;

      return 0.0;
   end Get_updated_cell_state;

   -- WORKER
   ----------------------------------------------------------------------
   task body Worker is
      local_board_copy     : Array2D (1 .. MAX_SIZE, 1 .. MAX_SIZE / 2);
      next_iteration_board : Array2D (1 .. MAX_SIZE, 1 .. MAX_SIZE / 2);
      column_start_range   : Integer;
      column_end_range     : Integer;
      worker_number        : Integer;
      alive_tmp            : Integer;
      cell_state_tmp       : Float;
   begin

      loop
         accept fill_board_part (
           board                  : Array2D;
            column_from           : Integer;
            column_to             : Integer;
            current_worker_number : Integer) do
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

         -- processing tablicy
         accept process_data;

         for I in 1 .. local_board_copy'Length (1) loop
            for J in 1 .. local_board_copy'Length (2) loop
               next_iteration_board (I, J) := local_board_copy (I, J) * 3.0;

	       --na lewej krawedzi
               if J = 1 then
                 if MAX_SIZE / NUMBER_OF_WORKERS * (worker_number - 1) /= 0 then
		   alive_tmp := Gol_concurrent.Get_alive_neighbours_count(local_board_copy, I, J, True, False);
                 else
                   alive_tmp := -1;
                 end if;
               end if;

               --na prawej krawedzi
               if J = local_board_copy'Length (2) then
                 if MAX_SIZE / NUMBER_OF_WORKERS * worker_number + 1 < MAX_SIZE then
		   alive_tmp := Gol_concurrent.Get_alive_neighbours_count(local_board_copy, I, J, False, True);
                 else
                   alive_tmp := 666;
                 end if;
               end if;

               Put_Line
                 ("(" &
                  Integer'Image (I) &
                  "," &
                  Integer'Image (J) &
                  " is " &
                  Float'Image (local_board_copy (I, J)) &
                  " and has " &
                  Integer'Image (alive_tmp) &
                  " alive nbs on worker " &
                  Integer'Image (worker_number));

            end loop;
         end loop;

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
      workers                 : array (1 .. NUMBER_OF_WORKERS) of Worker;
      current_iteration_board : Array2D (1 .. MAX_SIZE, 1 .. MAX_SIZE);
      --tmp:
      column : Array2D (1 .. MAX_SIZE, 1 .. 1);
   begin
      current_iteration_board :=
         Get_array_from_file (IN_FILENAME, MAX_SIZE, MAX_SIZE);
      shared_gameboard.Set (current_iteration_board);

      for I in 1 .. 1 loop

         shared_gameboard.Get (current_iteration_board);
         Arrays2D.Print_array
           (current_iteration_board,
            current_iteration_board'Length (1),
            current_iteration_board'Length (2));

         --tmp:
         --shared_gameboard.Get_specific_column(column, 1);
         --Put_Line("Column 1st:");
         --Arrays2D.Print_array(column, MAX_SIZE, 1);

         for I in 1 .. NUMBER_OF_WORKERS loop
            workers (I).fill_board_part
              (current_iteration_board,
               MAX_SIZE / NUMBER_OF_WORKERS * (I - 1) + 1,
               MAX_SIZE / NUMBER_OF_WORKERS * I,
               I);
            workers (I).process_data;
         end loop;

         for I in 1 .. NUMBER_OF_WORKERS loop
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

         Put_Line ("Received all the data");
         Print_array (current_iteration_board, MAX_SIZE, MAX_SIZE);
         shared_gameboard.Set (current_iteration_board);
         --write_array_to_file(current_iteration_board, OUT_FILENAME,
         --MAX_SIZE, MAX_SIZE);
         --append jakis?

      end loop;

   end Supervisor;

   -- OBIEKT WSPOLDZIELONY
   --------------------------------------------------------
   protected body Shared_board is
      procedure Set (a_board : Array2D) is
      begin
         board := a_board;
      end Set;

      procedure Get (a_board : out Array2D) is
      begin
         a_board := board;
      end Get;

      function Get_specific_column
        (column  : out Array2D;
         col_num : Integer)
      return Boolean
      is
         col : Array2D (1 .. MAX_SIZE, 1 .. 1);
      begin
         for I in 1 .. MAX_SIZE loop
            col (I, 1) := board (I, col_num);
         end loop;

         column := col;

         return True;
      end Get_specific_column;
   end Shared_board;

end Gol_concurrent;
