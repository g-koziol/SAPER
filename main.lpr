program main;

uses
    CRT, procedury, graph;
begin
  textcolor(15);
  window(1,1,100,80);
  clrscr;
  x:=1;
  randomize;
  writeln ('Witaj w Saperze! (by Grzegorz Koziol)');
  writeln('Zalecana wielkosc okna wynosi 100x30!');
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
  cursorbig;
  while (x=1) do
    begin
      clrscr;
      rysuj(k,w, liczba);
      ruch;
    end;
  readln;
end.
