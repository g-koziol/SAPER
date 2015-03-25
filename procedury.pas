unit procedury;

interface
uses
    crt, graph;

type
pole = record
  zakryte : integer ; //100 zakryte, 10 odkryte
  ile_bomb : longint ;//ilosc bomb
  bomba : boolean ;   //true - bomba, false - puste
  obramowka : char; //wysietlany znak na ekranie
end;

var
  i,j,k,w,l,licznik,liczba : integer; // i,j do tablicy; k,w kolumny i wiersze; liczba - ilosc liczb; licznik do roxnych petli
  x : integer = 0;//zmienna wykorzystana do nieskonczonej petli while w procedurze "odkryj"
  klawisz : char; //klawisz zczytywany (tak lub nie)
  a : array [1..255,1..255] of pole; //abstrakcyjne pole gry
  dane, ko, wi, li : string; //zmienne do wbudowanej procedury val()
  wartosc,Kod : integer; //zmienne do wbudowanej procedury val()

function rysuj(var k,w, liczba :integer): integer; //rysuje pole na ekranie
procedure ruch; //ruch kursora po planszy
procedure przegrana;
procedure wygrana;
procedure menu;//menu po przedluzeniu gry przez uzytkownika

implementation
    procedure menu;//zczytuje k - kolumny, w-wiersze
    var
      l : integer;//maksymalna ilosc bomb
    begin
      clrscr;
      textcolor(15);
      write('Podaj ilosc kolumn (9-30):  ');
      repeat
        readln(ko);
        val(ko,wartosc,Kod);
        if (Kod<>0) then write('Zly wybor! Jeszcze raz: ')
        else
          begin
            k:=wartosc;
            if ((k<9) or (k>30))  then write('Zly wybor! Jeszcze raz: ');
          end;
      until((k>=9) and (k<=30)) ;
      write('Podaj ilosc wierszy (9-24): ');
      repeat
        readln(wi);
        val(wi,wartosc,Kod);
        if (Kod<>0) then write('Zly wybor! Jeszcze raz: ')
        else
          begin
            w:=wartosc;
            if ((w<9) or (w>24))  then write('Zly wybor! Jeszcze raz: ');
          end;
      until((w>=9) and (w<=24));
      l:=Round((k*w)*0.6);//ustawienie warunku ilosci bomb zależnie od wielkosci planszy
      write('Ile chcesz bomb? (10-', l, '): ');
      repeat
        readln(li);
        val(li,wartosc,Kod);
        if (Kod<>0) then write('Zly wybor! Jeszcze raz: ')
        else
          begin
            liczba:=wartosc;
            if ((liczba<10) or (liczba>l)) then write('Zly wybor! Jeszcze raz: ');
          end;
      until((liczba>=10) and (liczba<=l));
      write('Generuje plansze');
      delay(500);
      write('.');
      delay(500);
      write('.');
      delay(500);
      write('.');
      delay(500);
      write('.');
      rysuj(k,w, liczba); //kolejne rysownie planszy
      ruch;
    end;

function rysuj(var k,w, liczba :integer): integer;// rysowanie planszy
  var n,m, s, l : integer; //zmienne pomocnicze
  {-----------------------------------------------------------------------------}
    function losuj_bomby(k,w,liczba : integer): integer; // losowanie liczb w polu gry
      begin
        licznik:=0;
        i:=0;
        j:=0;
        repeat //umieszczanie bomb na planszy
          repeat
            i:=random(k);
            j:=random(w);
          until ((a[i][j].bomba=false) and (i>=2) and (i<=(k-1)) and (j>=2) and (j<=(w-1)));
          a[i][j].bomba:=true;
          licznik:=licznik+1;
        until (licznik=liczba) ;  //sprawdzenie czy wylosowano zadana liczbe bomb
        losuj_bomby:=licznik;
      end;
  {-----------------------------------------------------------------------------}

  begin
     clrscr;
     k:=k+2; //k i w powiekszone o 2 ze wzgledu na obramowanie pola gry
     w:=w+2;
     begin //resetowanie tablicy
       for i:=1 to k do
         begin
          for j:=1 to w do
            begin
              a[i][j].zakryte:=100 ;
              a[i][j].bomba:=false;
            end;
         end;
     end;
     licznik:=losuj_bomby(k,w, liczba); //losowanie polozenia bomb
     for j:=1 to (w-1) do //sprawdzenie bomb dookola
        for i:=1 to (k-1) do
          begin
            if a[i][j].bomba=false then
              begin
              n:=j+1;
              m:=i+1;
              a[i][j].ile_bomb:=0;
              for l:=(j-1) to n do
                for s:=(i-1) to m do
                  begin
                    if (a[s][l].bomba=true) then
                    inc(a[i][j].ile_bomb);
                  end;
          end;
        end;
     textcolor(15);
     for i:=1 to k do //'malowanie' pola gry
      begin
        for j:=1 to w do
          begin
            if ((j=1) or (j=w)) then
              begin
                a[i][j].obramowka:='-';
                a[i][j].zakryte:=10;
              end
              else
                if((i=1) or (i=(k))) then
                  begin
                    a[i][j].obramowka:='|';
                    a[i][j].zakryte:=10;
                  end
                else
                  begin
                  a[i][j].obramowka:='O';
                  a[i][j].zakryte:=100;
                  end;
        end;
      end;
    for j:=1 to w do
      begin
        for i:=1 to k do
          begin
            {if (a[i][j].bomba=true) then //sprawdzenie poprawnosci losowania polozenia bomb (w miejscu bomby wyswietla 'b')
            begin
            a[i][j].obramowka:='b';
            write(a[i][j].obramowka);
            end
            else}
            write(a[i][j].obramowka);
          end;
        writeln;
      end;
    gotoxy((k+3),(w div 2)); //polozenie napisu z intrukcja sterowania
    textbackground(0);
    textcolor(15);
    writeln('Sterowanie strzalkami');
    gotoxy((k+3),((w div 2)+1));
    writeln('b - flaga, spacja - odkrycie pola, n - niepewne');
    rysuj:=licznik;//zwracanie liczby bomb przez funkcje
    gotoxy(2,2);
  end;


    procedure ruch; //korzysta z procedury odkryj
{-----------------------------------------------------------------------------}
  procedure odkryj (kolumna, wiersz : integer);//argumenty to wspolrzedne kolumny i wiersza do odkrycia
    begin
      kolumna:=wherex;
      wiersz:=wherey;
      //n:=wherex;//zapsianie polozenia kursora przed rekurencja
      //m:=wherey;}
      if (a[kolumna][wiersz].bomba=true) then //jesli bomba to przegrana
        begin
        przegrana;
        end
      else
        begin
          if (a[kolumna][wiersz].ile_bomb<>0) then //wyswietlanie liczby bomb dla 1 pola
            begin
            if(a[kolumna][wiersz].ile_bomb=1) then
              begin
                textcolor(9);
                write(a[kolumna][wiersz].ile_bomb);
                textcolor(7);
              end;
            if(a[kolumna][wiersz].ile_bomb=2) then
              begin
                textcolor(10);
                write(a[kolumna][wiersz].ile_bomb);
                textcolor(7);
              end;
            if(a[kolumna][wiersz].ile_bomb=3) then
              begin
                textcolor(12);
                write(a[kolumna][wiersz].ile_bomb);
                textcolor(7);
              end;
            if(a[kolumna][wiersz].ile_bomb=4) then
              begin
                textcolor(11);
                write(a[kolumna][wiersz].ile_bomb);
                textcolor(7);
              end;
            if(a[kolumna][wiersz].ile_bomb=5) then
              begin
                textcolor(13);
                write(a[kolumna][wiersz].ile_bomb);
                textcolor(7);
              end;
            if(a[kolumna][wiersz].ile_bomb=6) then
              begin
                textcolor(1);
                write(a[kolumna][wiersz].ile_bomb);
                textcolor(7);
              end;
            if(a[kolumna][wiersz].ile_bomb=7) then
              begin
                textcolor(2);
                write(a[kolumna][wiersz].ile_bomb);
                textcolor(7);
              end;
            if(a[kolumna][wiersz].ile_bomb=8) then
              begin
                textcolor(6);
                write(a[kolumna][wiersz].ile_bomb);
                textcolor(7);
              end;
            gotoxy(wherex-1,wherey);
            a[kolumna][wiersz].zakryte:=10;
            exit;
            end
          else
            a[kolumna][wiersz].obramowka:=' ';
            write(a[kolumna][wiersz].obramowka);
            a[kolumna][wiersz].zakryte:=10;
            gotoxy(wherex-1,wherey);
            if ((a[kolumna+1][wiersz].bomba=false) and ((kolumna+1)<=(k-1)) and (a[kolumna+1][wiersz].zakryte<>10) and (a[kolumna+1][wiersz].obramowka<>'?')) then
              begin
                gotoxy(kolumna+1,wiersz);
                odkryj(kolumna+1,wiersz);
              end;
            if ((a[kolumna-1][wiersz].bomba=false) and ((kolumna-1)>=2) and (a[kolumna-i][wiersz].zakryte<>10) and (a[kolumna-1][wiersz].obramowka<>'?')) then
              begin
              gotoxy(kolumna-1,wiersz);
              odkryj(kolumna-1,wiersz);
              end;
            if ((a[kolumna][wiersz+1].bomba=false) and ((wiersz+1)<=(w-1)) and (a[kolumna][wiersz+1].zakryte<>10) and (a[kolumna][wiersz+1].obramowka<>'?')) then
              begin
                gotoxy(kolumna,wiersz+1);
                odkryj(kolumna,wiersz+1);
              end;
            if ((a[kolumna][wiersz-1].bomba=false) and ((wiersz-1)>=2) and (a[kolumna][wiersz-1].zakryte<>10) and (a[kolumna][wiersz-1].obramowka<>'?'))then
            begin
                  gotoxy(kolumna,wiersz-1);
                  odkryj(kolumna,wiersz-1);
            end;
            if ((a[kolumna-1][wiersz-1].bomba=false) and ((kolumna-1)>=2) and ((wiersz-1)>=2) and (a[kolumna+1][wiersz+1].zakryte<>10) and (a[kolumna-1][wiersz-1].obramowka<>'?')) then
                   begin
                     gotoxy(kolumna-1,wiersz-1);
                     odkryj(kolumna-1,wiersz-1);
                   end;
            if ((a[kolumna-1][wiersz+1].bomba=false) and ((kolumna-1)>=2) and ((wiersz+1)<=(w-1)) and (a[kolumna-1][wiersz+1].zakryte<>10) and (a[kolumna-1][wiersz+1].obramowka<>'?')) then
                   begin
                     gotoxy(kolumna-1,wiersz+1);
                     odkryj(kolumna-1,wiersz+1);
                   end;
            if ((a[kolumna+1][wiersz-1].bomba=false) and ((kolumna+1)<=(k-1)) and ((wiersz-1)>=2) and (a[kolumna+1][wiersz-1].zakryte<>10) and (a[kolumna+1][wiersz-1].obramowka<>'?')) then
                   begin
                     gotoxy(kolumna+1,wiersz-1);
                     odkryj(kolumna+1,wiersz-1);
                   end;
            if ((a[kolumna+1][wiersz+1].bomba=false) and ((kolumna+1)<=(k-1)) and ((wiersz+1)<=(w-1)) and (a[kolumna+1][wiersz+1].zakryte<>10) and (a[kolumna+1][wiersz+1].obramowka<>'?')) then
                   begin
                     gotoxy(kolumna+1,wiersz+1);
                     odkryj(kolumna+1,wiersz+1);
                   end;
        end;
    end;
{-----------------------------------------------------------------------------}
    procedure pytajnik; //znak pytajnika
      begin
        i:=wherex;
        j:=wherey;
        if (a[i][j].obramowka='?')  then //jesli jest "?" zamien na zakryte
          begin
            textcolor(15);
            a[i][j].obramowka:='O';
            write(a[i][j].obramowka);
            gotoxy(wherex-1,wherey);
          end
        else
          begin
            if (a[i][j].zakryte=100) then
              begin
                textcolor(yellow);
                a[i][j].obramowka:='?';
                write(a[i][j].obramowka);
                gotoxy(wherex-1,wherey);
                textcolor(15);
              end;
          end;
      end;
{-----------------------------------------------------------------------------}
    procedure bomba(var licznik:integer);
      var
      liczba_bomb : integer;
      begin
        liczba_bomb:=licznik;
        i:=wherex;
        j:=wherey;
        if (a[i][j].obramowka='#') then //odznaczenie przez uzytkwnika bomby
          begin
            textcolor(15);
            a[i][j].zakryte:=100;
            a[i][j].obramowka:='O';
            dec(liczba_bomb);
            write(a[i][j].obramowka);
            gotoxy(wherex-1,wherey);
          end
        else //zaznaczenie przez uzytkownika bomby
          begin
            if (a[i][j].zakryte=100) then
              begin
                textcolor(lightred);
                if a[i][j].bomba=true then inc(liczba_bomb); //jesli rzeczywiscie bomba dodaj do licznika
                a[i][j].obramowka:='#';
                a[i][j].zakryte:=10;
                write(a[i][j].obramowka);
                gotoxy(wherex-1,wherey);
                textcolor(15);
              end;
            licznik:=liczba_bomb;
          end;
      end;
{-----------------------------------------------------------------------------}

var
  klawisz : char;
  licznik : longint;
  l : integer;
begin
  x:=1;//do nieskonczonej petli
  i:=2;//poczatkowe ustawienie tablicy
  j:=2;
  licznik:=0;
  gotoxy(2,2);
  while (x=1) do
  begin
  l:=0;
  for i:=2 to (k-1) do
    for j:=2 to (w-1) do
      begin
        if (a[i][j].zakryte=10) then inc(l);
      end;
  if ((licznik=liczba) and (l=(k-2)*(w-2))) then wygrana;
  klawisz:=readkey;
  case klawisz of
  #75: begin //ruch w lewo
          if (wherex<>2) then
            begin
              gotoxy(wherex-1,wherey);
              i:=wherex;
            end
          else
            begin
              gotoxy((k-1),wherey);
              i:=wherex;
            end;
       end;
  #77: begin //ruch w prawo
          if (wherex<>(k-1)) then
            begin
              gotoxy(wherex+1,wherey);
              i:=wherex;
            end
          else
            begin
              gotoxy(2,wherey);
              i:=wherex;
            end;
       end;
  #72: begin //ruch w gore
          if (wherey<>2) then
            begin
              gotoxy(wherex,wherey-1);
              j:=wherey;
            end
          else
            begin
              gotoxy(wherex,(w-1));
              j:=wherey;
            end;
       end;
  #80: begin //ruch w dol
          if (wherey<>(w-1)) then
            begin
              gotoxy(wherex,wherey+1);
              j:=wherey;
            end
          else
            begin
              gotoxy(wherex,2);
              j:=wherey;
            end;
       end;
  #32: begin //wlaczenie procedury odkrycia
          if (wherex=(w-1)) then
            begin
              odkryj(wherex,wherey);
              gotoxy(wherex-1,wherey);
            end
          else odkryj(wherex,wherey);
       end;
  'n': pytajnik; //postawienie pytajnika
  'b': bomba(licznik);//postawienie flagi (wyslanie licznika do ilosci trafnie oznaczonych bomb
  end;
  end;
end;//koniec procedury ruch

    procedure przegrana; //jesli przegrana przegrana
var
  y : integer = 0;
begin
  clrscr;
  textcolor(15);
  writeln('SAPER MYLI SIE TYLKO RAZ!');
  writeln('PRZEGRALES!!!!');
  writeln('Jeszcze raz?? [T/N]');
  repeat
    if y<>0 then writeln('Nieprawidlowy wybor!');
    klawisz:=readkey;
    y:=y+1
  until (((klawisz='T') or (klawisz='t') or (klawisz='n') or(klawisz='N'))=true);
  if ((klawisz='T') or (klawisz='t')) then menu //rysuj(k,w,liczba)
  else
    begin
      clrscr;
      writeln('Konczenie pracy z programem');
      delay(200);
      write('5, ');
      delay(200);
      write('4, ');
      delay(200);
      write('3, ');
      delay(200);
      write('2, ');
      delay(200);
      write('1, ');
      delay(200);
      write('PUF! xD');
      delay(1000);
      halt;
    end;//koniec bloku else
end;//koniec procedury przegrana

    procedure wygrana; //kiedy wygrana
var
  klawisz : char;
  y:integer=0;
begin
     clrscr;
     textcolor(15);
     Writeln('Jestes prawdziwym saperem!');
     writeln('Jeszcze raz?[T/N]');
     repeat
       if y<>0 then writeln('Nieprawidlowy wybor!');
       klawisz:=readkey;
       y:=y+1
     until ((klawisz='t') or (klawisz='T') or (klawisz='n') or (klawisz='N'));
     if ((klawisz='t') or (klawisz='T')) then menu
     else
     begin
       clrscr;
       writeln('Konczenie pracy z programem');
       delay(200);
       write('5, ');
       delay(200);
       write('4, ');
       delay(200);
       write('3, ');
       delay(200);
       write('2, ');
       delay(200);
       write('1, ');
       delay(200);
       write('PUF! xD');
       delay(1000);
       halt;
       end;
end; //koniec procedury wygrana

end.

