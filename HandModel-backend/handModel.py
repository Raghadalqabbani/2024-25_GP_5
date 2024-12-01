from flask import Flask, request, jsonify
import mediapipe as mp
import cv2
import numpy as np
import os

app = Flask(__name__)

# Folder to save images
UPLOAD_FOLDER = './upload'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Initialize Mediapipe Hands
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils

@app.route('/upload', methods=['POST'])
def process_image():
    # Ensure a file is included in the request
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    # Read the image
    image = cv2.imread(file_path)
    if image is None:
        return jsonify({'error': 'Failed to read image'}), 400

    # Convert image to RGB for Mediapipe
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    # Process the image with Mediapipe
    with mp_hands.Hands(
        static_image_mode=True,
        max_num_hands=2,
        min_detection_confidence=0.5
    ) as hands:
        results = hands.process(image_rgb)

        landmarks_list = []  # To store landmarks for all hands
        if results.multi_hand_landmarks:
            for hand_idx, hand_landmarks in enumerate(results.multi_hand_landmarks):
                hand_data = []
                for idx, landmark in enumerate(hand_landmarks.landmark):
                    hand_data.append({
                        'id': idx,
                        'x': landmark.x,
                        'y': landmark.y,
                        'z': landmark.z
                    })
                landmarks_list.append({
                    'hand_index': hand_idx,
                    'landmarks': hand_data
                })

                # Draw landmarks on the image
                mp_drawing.draw_landmarks(
                    image, hand_landmarks, mp_hands.HAND_CONNECTIONS
                )

            # Save the processed image
            processed_path = os.path.join(UPLOAD_FOLDER, f"processed_{file.filename}")
            cv2.imwrite(processed_path, image)

            return jsonify({
                'message': 'Image processed successfully',
                'landmarks': landmarks_list
            }), 200

        else:
            return jsonify({'message': 'No hands detected!'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3002, debug=True)
