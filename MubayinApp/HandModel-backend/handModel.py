from flask import Flask, request, jsonify
import mediapipe as mp
import cv2
import numpy as np
import os
import requests
import pandas as pd

app = Flask(__name__)

# Folder to save images
UPLOAD_FOLDER = './upload'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Load the CSV data for sign mappings
try:
    signs_df = pd.read_csv('./processed_features_ver2.csv')
    print("Dataset loaded successfully.")
except Exception as e:
    print("Error loading dataset:", e)


# Initialize MediaPipe Holistic
mp_holistic = mp.solutions.holistic
mp_drawing = mp.solutions.drawing_utils

# Heroku model endpoint
#MODEL_URL = "https://arsl-model-889dcbb4a8c2.herokuapp.com/predict"
MODEL_URL = "https://arsl-model-ver2-b7937d81e3ab.herokuapp.com/predict"

# Function to process images using Holistic
def mediapipe_detection(image, model):
    try:
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image = cv2.resize(image, (256, 256))  # Resize image
        image.flags.writeable = False
        results = model.process(image)
        image.flags.writeable = True
        return results
    except Exception as e:
        print("Error processing image:", e)
        return None

# Function to extract hand keypoints
def extract_keypoints(results):
    lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(21 * 3)
    rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(21 * 3)
    return np.concatenate([lh, rh])

# Function to send features to the Heroku model
def send_to_model(features):
    try:
        payload = {"features": features.tolist()}  # Prepare the feature list for sending
        headers = {"Content-Type": "application/json"}  # Set the request headers
        response = requests.post(MODEL_URL, json=payload, headers=headers)  # Send the request

        if response.status_code == 200:
            return response.json().get("predicted_sign", "Unknown")  # Return the predicted sign from the model
        else:
            print("Model prediction failed:", response.text)
            return "Error"
    except Exception as e:
        print("Error sending features to model:", e)
        return "Error"

# Function to get Sign-Arabic from predicted sign ID
def get_sign_arabic(predicted_sign):
    try:
        # Convert predicted_sign to integer if it's a string
        predicted_sign_int = int(predicted_sign)
    except ValueError:
        print(f"Error converting predicted_sign to integer: {predicted_sign}")
        return "Unknown"

    # Search for the corresponding Arabic sign in the dataset
    sign_row = signs_df[signs_df['SignID'] == predicted_sign_int]
    if not sign_row.empty:
        return sign_row['Sign-Arabic'].values[0]
    return "Unknown"


@app.route('/upload', methods=['POST'])
def process_image():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    # Read the image
    image = cv2.imread(file_path)
    if image is None:
        return jsonify({'error': 'Failed to read image'}), 400

    # Process the image with Holistic
    with mp_holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5) as holistic:
        results = mediapipe_detection(image, holistic)

        # Extract hand keypoints
        keypoints = extract_keypoints(results)

        # Draw landmarks if hands are detected
        if results.left_hand_landmarks:
            mp_drawing.draw_landmarks(image, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
        if results.right_hand_landmarks:
            mp_drawing.draw_landmarks(image, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS)

        # Save the processed image
        processed_path = os.path.join(UPLOAD_FOLDER, f"processed_{file.filename}")
        cv2.imwrite(processed_path, image)

        if np.all(keypoints == 0):
            return jsonify({'message': 'No hands detected!'}), 200

        # Send keypoints to the model for prediction
        predicted_sign = send_to_model(keypoints)

        # Convert predicted sign ID to Sign-Arabic
        sign_arabic = get_sign_arabic(predicted_sign)

        return jsonify({
            'message': 'Image processed successfully',
            'predicted_sign': predicted_sign,
            'sign_arabic': sign_arabic,
            'keypoints': keypoints.tolist()
        }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3002, debug=True)