// class Reciever{
// 	import processing.serial.*;
// 	import hypermedia.net.*;

// 	boolean connected = false;
// 	byte[] ip;
// 	byte[] port;
// 	string serialPort;
// 	UDP udp;
// 	Serial mySerial;
// 	Reciever(){
// 		inBuffer = new byte[3]
// 		udp = new UDP(this, 6000);
// 		udp.listen(true);

// 	}

// 	void scan(){
// 		String ack = "ACK"
// 		String in;
// 		for(int i = 0; i < Serial.list().length; i++){
// 			try {
				
// 				mySerial = new Serial(this, Serial.list()[i], 115200);
// 				mySerial.write("FFT PING");
// 				delay(500);
// 				in = mySerial.readString(i);

// 				if(in.equals(ack)){
// 					serialPort = Serial.list()[i];
// 					connected = true;
// 				}




// 			}
// 			catch (Exception e) {
// 			}
// 		}
// 		if(connected == true){
// 			return
// 		}

// 	}
