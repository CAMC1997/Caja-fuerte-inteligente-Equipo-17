
#include <SoftwareSerial.h>
#include <Servo.h> // servo library 
#include <Wire.h> 
#include <LiquidCrystal_I2C.h> // LCsD I2C library
#include <Keypad.h>

Servo myservo; 
SoftwareSerial BTSerial(2, 3);
LiquidCrystal_I2C lcd(0x27, 16, 2); // Dirección I2C ajustada a 0x27
char btChar;
bool isDoorOpen = false;

const byte ROWS = 4;
const byte COLS = 4;

char keys[ROWS][COLS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};

byte rowPins[ROWS] = {12,11,10,8};
byte colPins[COLS] = {7,6,5,4};

Keypad keypad = Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS);

char showCode[7] = ""; // Clave ingresada
char enteredCode[7] = "______"; // Clave ingresada oculta
char pass[7] = "123456"; // Clave ingresada
int codeIndex = 0; // Índice de la clave
bool changingPass = false; 

char btBuffer[7]; // Buffer para almacenar la cadena recibida
int btIndex = 0; // Índice del buffer


void setup() {
  
  Serial.begin(9600);
  BTSerial.begin(9600);
  myservo.attach(9);
  myservo.write(0);
  Wire.begin();
  lcd.init(); // Inicializar el LCD
  lcd.backlight(); // Encender la luz de fondo del LCD
  displayStartupAnimation();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("INGRESE LA CLAVE");
  lcd.setCursor(5, 1);
  lcd.print(enteredCode);
  if (myservo.read() == 90) {
    isDoorOpen = true; // Si la posición es 90, la puerta está abierta
  } else {
    isDoorOpen = false; // Cualquier otra posición, la puerta está cerrada
  }
}

void loop() {
  // INGRESO DE TEXTO POR BLUETOOH
  if (BTSerial.available() > 0) {
    btChar = BTSerial.read();
    Serial.print("ENTRADA BLUETOOH: ");
    Serial.println(btChar);
    // TECLAS ESPECIALES
    if (btChar >= '0' && btChar <= '9'){
      if (btIndex < 6) {
        btBuffer[btIndex] = btChar;
        btIndex++;
        if (btIndex == 6) {
          verifyAccess(btBuffer, 'b');
        }
      }
    } else {
      closeDoor(btChar);
    }
  }


  // INGRESO DE TEXTO POR KEYBOARD
  char key = keypad.getKey();
  if (key) {
    // TECLAS ESPECIALES
    if (key == 'A' || key == 'B' || key == 'C' || key == 'D' || key == '*' || key == '#') {
      closeDoor(key);
      changuePass(key);
      esc(key);
    } else {
      if (codeIndex < 6) {
        enteredCode[codeIndex] = '*';
        showCode[codeIndex] = key;
        lcd.setCursor(5, 1);
        lcd.print(enteredCode);
        codeIndex++;
        if(codeIndex == 6) {
          if (changingPass) { 
            for (int i = 0; i < 8; i++) {
              pass[i] = showCode[i];
            }
            Serial.print("Contraseña original cambiada: ");
            Serial.println(pass);
            lcd.clear();
            lcd.setCursor(6, 0);
            lcd.print("CLAVE");
            lcd.setCursor(4, 1);
            lcd.print("CAMBIADA");
            delay(1500);
            resetDisplay();
            changingPass = false;
          } else {
            verifyAccess(showCode, 'k');
          }
        }
      }
    }
  }
}

void access(const char* mode){
  lcd.clear();
  lcd.setCursor(5, 0);
  lcd.print("ACCESO");
  lcd.setCursor(4, 1);
  lcd.print("APROBADO");
  isDoorOpen = true;
  resetAuth();
  if(mode == 'k') {
    BTSerial.println("s");
  } else if (mode == 'b') {
    BTSerial.println("a");
  }
    
}

void denied(const char* mode){
  lcd.clear();
  lcd.setCursor(5, 0);
  lcd.print("ACCESO");
  lcd.setCursor(4, 1);
  lcd.print("DENEGADO");
  isDoorOpen = false;
  delay(2000);
  resetDisplay();
  if(mode == 'k') {
    BTSerial.println("w");
    Serial.println("ENVIANDO ALERTA");
  } else if (mode == 'b') {
    BTSerial.println("d");
  }
  
}

void resetAuth(){
  strcpy(enteredCode, "______");
  strcpy(showCode, "");
  codeIndex = 0;
  btIndex = 0;
}

void verifyAccess(const char* passEnter, const char* mode){
  Serial.println("VERIFICANDO ACCESO");
  if (isDoorOpen == false && strcmp(passEnter, pass) == 0) {
    myservo.write(90); // Abrir la cerradura
    isDoorOpen = true; // Actualizar el estado de la puerta
    access(mode);
    
  } else if (isDoorOpen == false && strcmp(passEnter, pass) != 0) {
    denied(mode);
    
  }
}

void closeDoor(const char* passKey){
  if (isDoorOpen == true && passKey == 'C') {
    Serial.println("CERRANDO PUERTA");
    myservo.write(0); // Abrir la cerradura
    //BTSerial.println("Cerradura cerrada");
    lcd.clear();
    lcd.setCursor(4, 0);
    lcd.print("CERRANDO");
    lcd.setCursor(5, 1);
    lcd.print("PUERTA");
    delay(1500);
    resetDisplay();
    isDoorOpen = false; // Actualizar el estado de la puerta
  }
}

void changuePass(const char* passKey){
  if (passKey == 'D') {
    changingPass = true;
    resetAuth();
    lcd.clear();
    lcd.setCursor(3, 0);
    lcd.print("NUEVA CLAVE");
    lcd.setCursor(5, 1);
    lcd.print(enteredCode);
  }
}

void esc(const char* passKey){
  if (isDoorOpen == false && passKey == 'A' ) {
    resetDisplay();
  }
}

void resetDisplay(){
  resetAuth();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("INGRESE LA CLAVE");
  lcd.setCursor(5, 1);
  lcd.print(enteredCode);
}


void displayStartupAnimation() {
  // Muestra un mensaje de bienvenida
  lcd.clear();

  // Barra de progreso de izquierda a derecha
  for (int i = 0; i < 16; i++) {
    lcd.setCursor(i, 1); // Mueve el cursor a la posición (i, 1)
    lcd.print("#");      // Muestra el carácter "#"
    delay(100);          // Pausa de 100 milisegundos entre cada incremento de la barra
  }

  // Pausa breve antes de revertir la animación
  delay(500);

  // Barra de progreso de derecha a izquierda
  for (int i = 15; i >= 0; i--) {
    lcd.setCursor(i, 1); // Mueve el cursor a la posición (i, 1)
    lcd.print(" ");      // Borra el carácter "#"
    delay(100);          // Pausa de 100 milisegundos entre cada decremento de la barra
  }
}

