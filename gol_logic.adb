with Arrays2D;       use Arrays2D;
with Gol_concurrent; use Gol_concurrent;

-- pakiet przechowujacy logike gry w zycie
package body Gol_logic is

   -- funkcja sluzy do rozsadzania czy dana komorka zyje
   -- param cell : stan danej komorki
   -- return : czy zyje
   function Is_Alive (cell : Float) return Boolean is
   begin
      if cell = 0.0 then
         return False;
      else
         return True;
      end if;
   end Is_Alive;

   -- funkcja do wydobywania kolumny o danym numerze z tablicy
   -- param board : cala tablica
   -- param column : kolumna - zmienna do zapisywania
   -- param col_num : numer zadanej kolumny
   procedure Get_specific_column
     (board   : Array2D;
      column  : out Array2D;
      col_num : Integer)
   is
      col : Array2D (1 .. MAX_SIZE, 1 .. 1);
   begin
      for I in 1 .. MAX_SIZE loop
         col (I, 1) := board (I, col_num);
      end loop;

      column := col;
   end Get_specific_column;

   -- funkcja zwraca ilosc zywych sasiadow komorki (I,J)
   -- param whole_board : pelna tablica, potrzebna do ekstrahowania kolumn
   -- param worker_number : numer workera ktory wola funkcje
   -- param board : lokalny 'skrawek' tablicy - kazdy worker ma swoj
   -- param I : pionowo
   -- param J : poziomo
   -- param is_by_left_edge : czy po lewej stronie skrawa sa jakies dane, do
   --ktorych trzeba sie dostac
   -- param is_by_right_edge : to samo, tylko po prawej
   -- return : ilosc zywych sasiadow
   function Get_alive_neighbours_count
     (whole_board      : Array2D;
      worker_number    : Integer;
      board            : Array2D;
      I                : Integer;
      J                : Integer;
      is_by_left_edge  : Boolean := False;
      is_by_right_edge : Boolean := False)
      return             Integer
   is
      alive_count        : Integer := 0;
      start_col, end_col : Integer;
   begin
      start_col := J - 1;
      end_col   := J + 1;

      if is_by_left_edge = True then
         start_col   := start_col + 1;
         alive_count := alive_count +
                        Get_edge_alive_neighbours_count
                           (whole_board,
                            MAX_SIZE / NUMBER_OF_WORKERS *
                            (worker_number - 1),
                            I);
      end if;

      if is_by_right_edge = True then
         end_col     := end_col - 1;
         alive_count := alive_count +
                        Get_edge_alive_neighbours_count
                           (whole_board,
                            MAX_SIZE / NUMBER_OF_WORKERS * (worker_number) +
                            1,
                            I);
      end if;

      for X in I - 1 .. I + 1 loop
         for Y in start_col .. end_col loop

            if (X /= I or Y /= J) and
               (X >= 1 and X <= MAX_SIZE) and
               (Y >= 1 and Y <= MAX_SIZE)
            then

               if Is_Alive (board (X, Y)) then
                  alive_count := alive_count + 1;
               end if;

            end if;

         end loop;
      end loop;

      return alive_count;
   end Get_alive_neighbours_count;

   -- funkcja sluzaca do synchronizacji miedzy workerami dla kolumn brzegowych
   -- param whole_board : cala tablica
   -- param col_num : numer zadanej kolumny poza zasiegiem workera - z ktora
   --trzeba sie porozumiec
   -- param row_num : numer aktualnego rzedu
   -- return : ilosc zywych sasiadow w kolumnie, ktora jest poza zasiegem
   --workera dla komorki (row_num, col_num - 1)
   function Get_edge_alive_neighbours_count
     (whole_board : Array2D;
      col_num     : Integer;
      row_num     : Integer)
      return        Integer
   is
      column      : Array2D (1 .. MAX_SIZE, 1 .. 1);
      alive_count : Integer := 0;
      result      : Boolean;
   begin
      Get_specific_column (whole_board, column, col_num);

      for I in row_num - 1 .. row_num + 1 loop

         if I >= 1 and I <= MAX_SIZE then

            if Is_Alive (column (I, 1)) then
               alive_count := alive_count + 1;
            end if;

         end if;

      end loop;

      return alive_count;
   end Get_edge_alive_neighbours_count;

   -- funkcja realizjaca logike gry w zycie 23/3
   -- param cell_state : aktualny stan komorki
   -- param alive_neighbours : zywi sasiedzi komorki
   -- return : uaktualniony stan
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
end Gol_logic;
