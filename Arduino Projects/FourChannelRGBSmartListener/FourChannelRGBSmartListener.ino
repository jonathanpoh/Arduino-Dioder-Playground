/*

This simple program listens for incoming data in 4-byte
chunks, then pushes the values of those bytes down the
analog pins.

To keep a bit of sanity, the protocol consists of a one-byte header,
one-byte for the channel number, 3 bytes for R, G and B values, and tailed by
a one-byte XOR checksum of the body.

No assumptions are made about colours or number of channels, starting at
kChannel1FirstPin.

NOTE: This project requires Arduino Mega.
DOUBLE NOTE: This program implements the listening side of the messages
sent by the included ArduinoDioder Processing project.
Don't use the DumbListener, because it's dumb.

*/

const int kChannel1FirstPin = 2;

// Protocol details:
// one header byte, one channel number byte, 3 value bytes, one checksum byte

const int kProtocolHeaderFirstByte = 0xAA;  // 10101010 in binary

// TODO: change this to the end byte
const int kProtocolHeaderSecondByte = 0x55; // 01010101 in binary

const int kProtocolHeaderLength = 1;
const int kProtocolBodyLength = 4;
const int kProtocolChecksumLength = 1;

int numChannels = 4;
// TODO: do we need to check for the channel numbers explicitly?
// const int channelOneByte   = 0x00;
// const int channelTwoByte   = 0x01;
// const int channelThreeByte = 0x02;
// const int channelFourByte  = 0x03;

int currentChannel;

// Buffers and state

bool appearToHaveValidMessage;
byte receivedMessage[12];

void setup() {
  // set pins 2 through 13 as outputs:
  for (int thisPin = kChannel1FirstPin; thisPin < (kChannel1FirstPin + sizeof(receivedMessage)); thisPin++) {
    pinMode(thisPin, OUTPUT);
    analogWrite(thisPin, 255);
  }

  appearToHaveValidMessage = false;

  // initialize the serial communication:
  Serial.begin(115200);
}


void loop () {

  int availableBytes = Serial.available();

  if (!appearToHaveValidMessage) {

    // If we haven't found a header yet, look for one.
    if (availableBytes >= kProtocolHeaderLength) {

      // Read then peek in case we're only one byte away from the header.
      byte firstByte = Serial.read();
      // byte secondByte = Serial.peek();

      if (firstByte == kProtocolHeaderFirstByte) {
      // && secondByte == kProtocolHeaderSecondByte) {

          // We have a valid header. We might have a valid message!
          appearToHaveValidMessage = true;

          // Read the second header byte out of the buffer and refresh the buffer count.
          // Serial.read();
          availableBytes = Serial.available();
      }
    }
  }

  if (availableBytes >= (kProtocolBodyLength + kProtocolChecksumLength) && appearToHaveValidMessage) {

    int calculatedChecksum = 0;

    // Read the channel number
    int currentChannel = Serial.read();

    // Check that the channel number is within the expected range
    if (currentChannel < numChannels) {

      // TODO: Work out which pin that channel needs to go to
      // int channelStartPin = kChannel1FirstPin + (currentChannel * 3) ;

      // Read in the body, calculating the checksum as we go.
      // subtracting 1 from the kProtocolBodyLength for the channel number
      for (int i = 0; i < (kProtocolBodyLength - 1); i++) {
        receivedMessage[i] = Serial.read();
        calculatedChecksum ^= receivedMessage[i];
      }

      byte receivedChecksum = Serial.read();

      if (receivedChecksum == calculatedChecksum) {
        // Hooray! Push the values to the output pins.
        for (int i = 0; i < (kProtocolBodyLength - 1); i++) {
          int mappedColour = map(receivedMessage[i], 0, 255, 32, 255);
          analogWrite(i + kChannel1FirstPin, mappedColour);
        }

        Serial.print("OK");
        Serial.write(byte(10));

      } else {

        Serial.println("FAIL");

        // Serial.print("Checksum should be: ");
        // Serial.println(calculatedChecksum);
        // Serial.print("Checksum received: ");
        // Serial.println(receivedChecksum);

        Serial.write(byte(10));
      }

      appearToHaveValidMessage = false;
    }
  }
}

