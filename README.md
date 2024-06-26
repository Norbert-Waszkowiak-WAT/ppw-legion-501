[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/t_QPUBo-)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=11989278&assignment_repo_type=AssignmentRepo)


## Opis projektu

Galactic Vendetta jest grą wideo na PC. To platformówka 2D w motywie kosmicznym z elementami RPG.

## Cele projketu

	1. Postać gracza z możliwością poruszania się
	2. Oprawa graficzna w stylu Pixel Art
	3. Działający poziom
	4. Działający system walki
	5. Wrogowie
	6. Rozwój postaci
	7. Więcej zawartości (różne rodzaje broni, wrogów, więcej poziomów)

## Progress update
### 01/03/2024

- Drzewko rozwoju postaci jest w pełni funkcjonalne, lecz nie w pełni wypełnione umiejętnościami. Punkty umięjętności są przyznawane za każdy kolejny
poziom doświadczenia. Każdy można wydać na jedną umiejętność. Posiadane umiejętności są przechowywane w globalnej tabeli słownikowej.
- Broń dystansowa działa zgodnie z zamiarem, w przyszłości zamierzamy ograniczyć dostępną amunicję.
- Zapis gry także działa - są dostępne 3 sloty na zapis. Dane każdego z nich są przechowywane w osobnym pliku w formacie binarnym. Przy wyborze
opcji "nowa gra" jest możliwość wybrania jednego z nich. Po przejściu każdego poziomu stan gry zapisuje się automatycznie. Po wybraniu opcji
"kontynuuj" można wybrać jeden ze slotów (o ile istnieje w nim zapis).
- Tekstury i animacje gracza przyjęły już prawie finalną formę, zostały nam tylko ostatnie szlify.
- Oprócz tego eksperymentalnie dodaliśmy pierwszy efekt dźwiękowy - wystrzał z broni dystansowej.

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/288a6232-3c6f-42d7-9580-f6623d7817a5)

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/5e16c276-1e58-48bc-b8e2-e0e16b8263b4)

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/dc22d669-d986-4249-96b0-4d6bb5521023)

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/d8db5b24-216c-43bd-922d-ad9c46a2cf20)

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/6e383a3e-e90f-439a-ad4f-a433605e9288)

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/155ae2f6-c0fc-40ce-bce7-025956291677)

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/2494fa14-2b17-489c-b4f0-dc2a3181d23a)

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/02a60ebf-1180-489c-aae6-73078dbba10a)

![image](https://github.com/Norbert-Waszkowiak-WAT/ppw-legion-501/assets/59392489/b19c68e4-8c8e-492c-a275-fceeb206aee2)


## Dziennik

### 16/12/2023
Zaimplementowana funkcjonalność:
- Warunek wygranej poziomu
- Pierwszy grywalny poziom
- Usprawnienia menu
- Poprawki, naprawa i refaktoryzacja całego kodu

Gracz wygrywa poziom po wejściu w wyznaczoną strefę. Dodano nowy
poziom demonstracyjny, który jest już w pełni grywalny. Nowy ekran wygranej
po przejściu poziomu. Poprawki m.in. w zachowaniu wroga i różnych innych
interakcjach między elementami gry.

Planowana funkcjonalność na następne tygodnie:
- Dodatkowe warunki ukończenia poziomu
- Więcej tekstur różnych elementów gry
- Pierwsza broń dystansowa
- Usprawnienia w kodzie
- Prototyp rozwoju postaci

### 30/11/2023
Zaimplementowana funkcjonalność:
- TileSet do tworzenia poziomów
- Animowane menu główne 
- Klasy ogólne dla wroga oraz broni
- Poziom doświadczenia gracza
- Dalszy rozwój zachowania wrogów
- Warunek przegranej (śmierć gracza)

Dzięki TileSetowi tworzenie nowych poziomów z gotową kolizją i teksturami jest bardzo proste i przyjemne.
Dodano menu główne gry z animacją podczas włączania gry, a także przy zaczęciu nowej gry.
Klasy ogólne pozwolą na szybsze dodawanie różnych rodzajów wrogów i broni.
Poziom doświadczenia gracza: będzie używany do odblokowywania umiejętności. Doświadczenie zdobywa się przez
zabijanie wrogów.
Wrogowie są teraz w stanie przeskakiwać nad przeszkodami i przepaściami podczas gonienia gracza. Ucieczka
przed nimi stanowi teraz większe wyzwanie niż wcześniej.
Gracz może już umrzeć co kończy grę.

Planowana funkcjonalność na następne tygodnie:
- Więcej tekstur różnych elementów gry
- Usprawnienia menu
- Pierwsza broń dystansowa
- Warunek wygranej poziomu
- Pierwszy w pełni grywalny poziom

### 08/11/2023
Zaimplementowana funkcjonalność:
- Rework systemu poruszania się gracza na tzw. state machine
- Wzór zachowania się wroga na podstawie state machine

Zmiany w systemie poruszania się gracza pozwolą na łatwą implementację animacji różnych czynności gracza,
a także na szybkie dodawanie nowych zdolności dla gracza (np. double jump).
Prototyp wroga otrzymał mocno uproszczoną wersję tego systemu, a jego zachowanie zostało poprawione.
Teraz po wejściu gracza w jego zasięg zaczyna go gonić, a następnie atakować. Kiedy nie ma gracza w swoim zasięgu,
zachowuje się tak jak wcześniej (stoi w miejscu, czasem porusza się na boki).

Planowana funkcjonalność na następne tygodnie:
- Finalne wersje niektórych tekstur
- TileSet do tworzenia poziomów
- Poprawki w implementacji wrogów (klasa ogólna dla wrogów, przygotowania
 pod różne rodzaje wrogów)
- Poprawki w implementacji broni
- Poprawki i refaktoryzacja kodu

### 20/10/2023
Zaimplementowana funkcjonalność:
- System poruszania się gracza
- System zadawania i otrzymywania obrażeń
- Prototyp systemu broni
- Prototyp wroga
- Ruchome tło
- Testowy poziom 

Gracz może poruszać się i skakać. Wiąże się to z odpowiednimi animacjami.
Wróg ma zaimplementowaną wczesną wersję poruszania się poza walką.
Zarówno gracz, jak i wróg, mogą otrzymywać obrażenia. Efektem jest utrata punktów życia oraz odepchnięcie do tyłu z ustaloną siłą.
Dla testów została zaimplementowana pierwsza broń do walki wręcz. Może ją dzierżyć gracz lub też wróg, i atakować nią wybrane cele.
Tło poziomu testowego porusza się razem z kamerą, lecz wolniej od niej, co daje wrażenie 3-wymiarowości (tło wydaje się odległe).
Oprócz tego częścią tła są poruszające się chmury.
Wszystkie tekstury obecne w grze to nadal placeholdery. Pracujemy nad finalnymi teksturami do gry, i będziemy je implementować jak tylko będą 
gotowe do użycia.

Planowana funkcjonalność na następne tygodnie:
- Rework systemu poruszania się gracza na tzw. state machine
- Wzór zachowania się wroga na podstawie state machine
- Finalne wersje niektórych tekstur
- TileSet do tworzenia poziomów
- Poprawki i refaktoryzacja kodu
