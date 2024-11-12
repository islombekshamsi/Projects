# include <iostream>

using namespace std;

void drawBoard(char *spaces);
void playerMove(char *spaces, char player);
void computerMove(char *spaces, char computer, char player);
bool checkWinner(char *spaces, char player, char computer);
bool checkTie(char *spaces);

int main(){
  char spaces[9] = {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '};
  char player = 'X';
  char computer = 'O';
  bool running = true;

  drawBoard(spaces);
  while (running){
    playerMove(spaces, player);
    drawBoard(spaces); 
    if (checkWinner(spaces, player, computer)){
      running = false;
      break;
    } else if(checkTie(spaces)){
      running = false;
      break;
    }
    computerMove(spaces, computer, player);
    drawBoard(spaces);
    if (checkWinner(spaces, player, computer)){
      running = false;
      break;
    }else if(checkTie(spaces)){
      running = false;
      break;
    }
  }
  
  return 0;
}

void drawBoard(char *spaces){
  cout << endl;
  cout << "     |     |     " << endl;
  cout << "  " << spaces[0] << "  |  " << spaces[1] << "  |  " << spaces[2] << endl;
  cout << "_____|_____|_____" << endl;
  cout << "     |     |     " << endl;
  cout << "  " << spaces[3] << "  |  " << spaces[4] << "  |  " << spaces[5] << endl;
  cout << "_____|_____|_____" << endl;
  cout << "     |     |     " << endl;
  cout << "  " << spaces[6] << "  |  " << spaces[7] << "  |  " << spaces[8] << endl;
  cout << "     |     |     " << endl << endl;

}
void playerMove(char *spaces, char player){
  int number;
  do {
    cout << "Enter a spot to place a marker (1-9): "; 
    cin >> number;
    number--; // Convert to zero-based index
    if (number >= 0 && number < 9 && spaces[number] == ' ') {
      spaces[number] = player;
      break;
    } else {
      cout << "Invalid move. Try again.\n";
    }
  } while (true); 
}

void computerMove(char *spaces, char computer, char player) {
    // Check if the computer can win in the next move
    for (int i = 0; i < 9; i++) {
        if (spaces[i] == ' ') {
            spaces[i] = computer; // Temporarily make the move
            if (checkWinner(spaces, computer, player)) {
                cout << "Computer chose spot " << i + 1 << endl;
                return; // Win move found
            }
            spaces[i] = ' '; // Undo the move
        }
    }

    // Check if the player can win in the next move and block them
    for (int i = 0; i < 9; i++) {
        if (spaces[i] == ' ') {
            spaces[i] = player; // Temporarily make the player's move
            if (checkWinner(spaces, player, computer)) {
                spaces[i] = computer; // Block the player's winning move
                cout << "Computer chose spot " << i + 1 << endl;
                return; // Block move found
            }
            spaces[i] = ' '; // Undo the move
        }
    }

    // If no winning or blocking move, choose a random available spot
    int number;
    while (true) {
        number = rand() % 9;
        if (spaces[number] == ' ') {
            cout << "Computer chose spot " << number + 1 << endl;
            spaces[number] = computer;
            break;
        }
    }
}
bool checkWinner(char *spaces, char player, char computer) {
    // Define winning combinations
    int winningCombinations[8][3] = {
        {0, 1, 2}, {3, 4, 5}, {6, 7, 8}, // Rows
        {0, 3, 6}, {1, 4, 7}, {2, 5, 8}, // Columns
        {0, 4, 8}, {2, 4, 6}             // Diagonals
    };

    // Check each winning combination
    for (int i = 0; i < 8; i++) {
        int a = winningCombinations[i][0];
        int b = winningCombinations[i][1];
        int c = winningCombinations[i][2];

        if (spaces[a] == spaces[b] && spaces[b] == spaces[c] && spaces[a] != ' ') {
            spaces[a] == player ? cout << "YOU WIN!\n" : cout << "YOU LOSE!\n";
            return true;
        }
    }
    return false; // No winner
}
bool checkTie(char *spaces){
  for (int i = 0; i < 9; i++){
    if (spaces[i] == ' '){ // checks for empty spaces, if empty spaces game continues
      return false;
    }
  }
  cout << "TIE!\n";
  return true;
}
