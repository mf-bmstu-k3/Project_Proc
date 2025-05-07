-- этот файл содержит описание операционного устройства для выполнения умножения и сложения
-- он представляет собой vhdl описание схемного проекта contr_unit_BO, представленного на верхнем уровне как МУУ(файл control unit) + БО (файл BO)
-- В описании представлено entity и архитектурное тело операционного устройства
-- Операнды n разрядные

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ctrl_un_BO is
generic (n:integer);     -- n параметр, задает разрядность операндов
	port
	(
		a : in  STD_LOGIC_VECTOR (n-1 downto 0);-- первый операнд		
		b : in  STD_LOGIC_VECTOR (n-1 downto 0);-- второй операнд
		clk		 : in	std_logic; -- тактовый сигнал
		set 		 : in	std_logic; --  сигнал начальной установки
		cop		 : in	std_logic; --  код операции 1-умножение,0 - сложение

		sno		 : in	std_logic; -- сигнал начала операции
		rr 		 : buffer  STD_LOGIC_VECTOR (2*n-1 downto 0);-- результат
      priznak 	 : out  STD_LOGIC_VECTOR (1 downto 0); -- признак результата
		sko	 	 : out	std_logic -- сигнал конца операции

	);

end entity;

architecture arch of ctrl_un_BO is

	type state_type is (s0, s1, s2, s3, s4); -- определяем состояния МУУ

	signal next_state, state : state_type; -- следующее состояние, текущее состояние
	signal i : integer range 1 to n-1 ;    -- счетчик анализируемых разрядов множителя
	signal incr_i	 :std_logic;            -- разрешение инкремента i
	signal RA,RB  	:STD_LOGIC_VECTOR (n-1 downto 0);-- для запоминания а и в

signal d  		:STD_LOGIC_VECTOR (2*n-1 downto 0);-- выход КС1
signal q  		:STD_LOGIC_VECTOR (2*n-1 downto 0);-- выход КС2
signal s  		:STD_LOGIC_VECTOR (2*n-1 downto 0);-- выход сумматора
signal pr  		:STD_LOGIC_VECTOR (1 downto 0);-- выход КС3
signal x			:std_logic_vector (2 downto 0);-- логические условия
signal y	 		:std_logic_vector(10 downto 1); -- управляющие сигналы для блока операций

begin

TS: process (clk,set) -- этот процесс определяет текущее состояние МУУ
	 begin
		if set = '1' then
			state <= s0;
		elsif (rising_edge(clk)) then -- по положительному фронту переключаются состояния
			state <= next_state;			
		end if;
	 end process;
	 
NS: process (state,cop,sno,x,i) -- этот процесс определяет следующее состояние МУУ, управляющие сигналы для БО
	 begin

			case state is
				when s0=> -- переходы из s0
				 
					if (sno = '1') then
						next_state <= s1; y<="0011000111"; -- если есть сигнал начала операции
					else
						next_state <= s0; y<="0000000000"; -- иначе состояние не меняется
					end if;
				when s1=>
				   
					next_state <= s2; -- из s1 всегда переходим в s2
					if  cop='0' then	-- если сложение
						y<="0001101000"; --rr=RA+RB
					elsif x(1 downto 0) = "10"  then
						y<="0101101000"; -- rr=rr +RA  													
					elsif x(1 downto 0)="01" then
						y<="0101110000"; -- rr=rr -RA
					else 
						y<="0101100000"; -- rr=rr+0 
					end if;
				when s2=>
					if i = n-1 then
						next_state <= s0; y<="0000000000"; -- формируем сигнал конца операции
					elsif cop='1' then 							-- если умножение
						next_state <= s1; y<="0001000100";  -- иначе сдвиг rr, сдвиг RB
					elsif cop='0' and x(2)='0' then			-- если сложение и нет отрицательного нуля
					   next_state <= s4; y<="1000000000";  -- иначе запись признака в RPR
					else
						next_state <= s3; y<="0011000000";  -- иначе если сложение и есть отрицательный ноль, то обнуляем rr
					end if;
				when s3 =>
						next_state <= s4; y<="1000000000";  -- иначе запись признака в RPR
				when s4 =>
						next_state <= s0; y<="0000000000";  -- формируем сигнал конца операции
				
			end case;			
	end process;

	sko<='1' when (state=s2 and (i=n-1))  or state =s4 else -- формирование sko	
			'0';
	incr_i<='1' when state=s2 and cop='1' and i/=n-1 else --инкремент i
			'0';
count_i:   process (sno, clk) -- этот процесс определяет поведение счетчика i
	
	begin
		if (sno='1') then i<=1; --устанавливаем в начальное состояние
		elsif clk'event and clk='1' then 
		  if (incr_i='1') then i<=i+1; -- инкремент счетчика
		  end if;
		 end if;
	end process;
	pr_RA: process (clk) -- этот процесс описывает логику работы регистра RA
	begin
		if clk'event and clk='1' then -- по положительному фронту clk
			if y(1)='1' then -- если есть разрешение
			RA<=a; -- выполняется прием первого операнда
			end if;
		end if;
	end process pr_RA;
	
pr_RB: process (clk)-- этот процесс описывает логику работы регистра RB
	begin
		if clk'event and clk='1' then -- по положительному фронту 
		 if y(3)='1' then -- если есть разрешение тактирования
			if y(2)='1' then RB<=b;-- если разрешена загрузка, то прием второго операнда
			 else RB<=RB(n-1)& RB(n-3 downto 0)&'0'; -- иначе сдвиг влево RB с сохранением знака
			end if;
		 end if;
		end if;
end process pr_RB;

-- ниже приводится описание КС1, d(2*n-1 downto 0) её выход
with y(5 downto 4) select
	d(2*n-1 downto n)<=(others=>RA(n-1)) when "01",-- передаем на суммирование +А если y4=1
		(others=>not RA(n-1)) when "10",--передаем на суммирование -А, если y5=1
		(others=>'0') when others; -- ноль в остальных случаях
with y(5 downto 4) select		
	d(n-1 downto 0)<=RA when "01",-- передаем на суммирование +А если y4=1
		not RA when "10",--передаем на суммирование -А, если y5=1
		(others=>'0') when others; -- ноль в остальных случаях
		
-- ниже приводится описание КС2, q(2*n-1 downto 0)её выход 
q(2*n-1 downto n)<=rr(2*n-1 downto n) when y(9)='1' else -- когда умножение
			(others=>RB(n-1)); -- когда сложение
			
q(n-1 downto 0)<=rr(n-1 downto 0) when y(9)='1' else -- когда умножение 
			RB; -- когда сложение
			
SM: process(d,q) -- этот процесс описывает работу сумматора в обратном коде
-- к его входам подключены выходы КС1 и КС2
variable sym:STD_LOGIC_VECTOR (2*n downto 0); -- для вычисления суммы
begin
 
sym:=('0'&d)+('0'&q);-- сложение
	if (sym(2*n)='1')then sym(2*n) :='0'; sym :=sym+1;
   end if;

s <=sym(2*n-1 downto 0);
end process SM;
			
pr_rr: process (clk) -- этот процесс описывает работу регистра результата
begin
	if clk'event and clk='1' then	-- по положительному фронту синхросигнала
		if y(8)='1' then rr<=(others=>'0');   --очистка rr
		elsif (y(7)='1') then -- если есть разрешение тактирования
			if y(6)='1' then rr<=s;--загрузка rr
				else rr<=rr(2*n-2 downto 0)& rr(2*n-1);-- циклический сдвиг влево rr
			end if;
		end if;
	end if;
end process pr_rr;

-- ниже приводится описание КС3, которая формирует признак результата
	pr<="00" when rr (n downto 0)=0 else -- результат равен нулю
		"10" when rr (n downto 0)< 2**(n-1) else -- результат больше 0
		"11" when rr (n downto 0)< (2**n)+2**(n-1) else -- переполнение
		"01"; -- результат меньше 0

pr_RPR: process(clk) --этот процесс описывает работу регистра признака
begin
	if clk'event and clk='1' then -- по положительному фронту 
		if y(10)='1' then priznak<=pr; -- запоминаем признак результата
		end if;
	end if;
end process pr_RPR;	
-- ниже приводится описание логических условий
x(0)<= RB(n-1);   --знак множителя
x(1)<= RB(n-2);	--	анализируемый разряд множителя
x(2)<= '1' when rr (n downto 0)=(2**(n+1))-1 else -- признак отрицательного нуля
			'0'; -- иначе ноль	


--	s_out<=0 when state=s0 else
--			 1 when state=s1 else					
--			 3;
--	next_state_out<=0 when next_state=s0 else
--			 1 when next_state=s1 else					
--			 2 when next_state=s2 else
--			 3;

end arch;
