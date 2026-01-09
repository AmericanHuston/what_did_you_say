from flask import Flask, jsonify
import speech_recognition as sr
import threading
import time

app = Flask(__name__)

# Global buffer to store spoken words
word_buffer = ""
# Lock to synchronize access to the buffer
buffer_lock = threading.Lock() #Have to unlock here to use, auto locks when opening with "with"

def recognize_speech():
    r = sr.Recognizer()
    with sr.Microphone() as source:
        print("Say something!")
        audio = r.listen(source, 10, 10) #Adjust this if stuff is being weird with timing. Search audio = r.listen() online.

    try:
        text = r.recognize_google(audio, language='en-us')
        print("Google Speech Recognition thinks you said: " + text)
        return text
    except sr.UnknownValueError:
        print("Could not understand audio")
        return None
    except sr.RequestError as e:
        print("Could not request results from Google Speech Recognition service; {0}".format(e))
        return None

def handle_request():
    global word_buffer #MUST POINT TO GLOBAL TO READ/WRITE
    text = recognize_speech()
    if text:
        with buffer_lock: #Unlocks word_buffer to read/write
            word_buffer += f" {text}"
            print(f"Added word: {text}")

def run_recognition_thread():
    while True: #forever loop
        handle_request()
        time.sleep(0.1) # Adjust as needed (letting go of the thread to avoid CPU hogging)

@app.route('/get-words', methods=['GET'])
def get_history():
    global word_buffer #MUST POINT TO GLOBAL TO READ/WRITE
    with buffer_lock:
        word_batch = word_buffer #Copy before deleting
        word_buffer = "" # Clear the buffer after sending
        return jsonify({"words": word_batch.lower()}) #Locked and loaded, fire away

if __name__ == '__main__':
    recognition_thread = threading.Thread(target=run_recognition_thread) #Starts a new thread to do the while true loop (WHY THIS WORKS AND MULTITHREADING DOESNT DOESNT MAKE SENSE)
    recognition_thread.daemon = True #No clue, but needed
    recognition_thread.start() #Start the thread
    app.run(debug=True, host='0.0.0.0', port=5000) #start the server