import os
import cv2
import shutil
import numpy as np
from flask import Flask, jsonify
from tensorflow.keras.models import load_model
import mediapipe as mp

# === Initialize Flask app ===
app = Flask(__name__)

# === Load trained LSTM model ===
model = load_model("model/final_hands_asl_lstm_best_model.h5")
actions = np.array([
    'hello', 'thank_you', 'yes', 'no', 'please',
    'help', 'sorry', 'nice_to_meet_you', 'how_are_you', 'Excuse_Me'
])

# === MediaPipe Holistic setup ===
mp_holistic = mp.solutions.holistic
mp_drawing = mp.solutions.drawing_utils

# === MediaPipe detection function ===
def mediapipe_detection(image, model):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = model.process(image)
    return results

# === Only extract hand keypoints (126 total: 63 for each hand) ===
def extract_keypoints(results):
    lh = np.array([[res.x, res.y, res.z]
                   for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
    rh = np.array([[res.x, res.y, res.z]
                   for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
    return np.concatenate([lh, rh])

# === Prediction route ===
@app.route('/predict', methods=['POST'])
def predict():
    frame_dir = 'frames'
    processed_dir = os.path.join(frame_dir, 'processed_frames')
    os.makedirs(processed_dir, exist_ok=True)

    sequence = []

    try:
        # Step 1: Get sorted image list
        image_files = sorted([
            f for f in os.listdir(frame_dir)
            if f.lower().endswith('.jpg') or f.lower().endswith('.png')
        ], key=lambda x: os.path.getmtime(os.path.join(frame_dir, x)))

        if len(image_files) < 5:
            return jsonify({'error': "Not enough frames (need at least 5)"}), 400

        selected_images = image_files[:5]

        with mp_holistic.Holistic(
            static_image_mode=True,
            model_complexity=1,
            enable_segmentation=False,
            refine_face_landmarks=False
        ) as holistic:

            for img_file in selected_images:
                img_path = os.path.join(frame_dir, img_file)
                image = cv2.imread(img_path)
                if image is None:
                    return jsonify({'error': f"Failed to load image {img_file}"}), 400

                results = mediapipe_detection(image, holistic)
                keypoints = extract_keypoints(results)
                sequence.append(keypoints)

                # === Draw only hands for visualization ===
                if results.left_hand_landmarks:
                    mp_drawing.draw_landmarks(image, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
                if results.right_hand_landmarks:
                    mp_drawing.draw_landmarks(image, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS)

                # === Save image with landmarks ===
                processed_path = os.path.join(processed_dir, f"processed_{img_file}")
                cv2.imwrite(processed_path, image)

                # Optionally delete original
                os.remove(img_path)

        # Step 2: Prepare input for model
        sequence = np.array(sequence)  # shape: (5, 126)
        sequence = np.expand_dims(sequence, axis=0)  # shape: (1, 5, 126)

        # Step 3: Predict
        prediction = model.predict(sequence)[0]
        # predicted_label = actions[np.argmax(prediction)]
        predicted_label = actions[np.argmax(prediction)].replace('-', ' ')
        confidence = float(np.max(prediction))

        return jsonify({
            'prediction': predicted_label,
            'confidence': confidence
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# === Run server ===
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

# import os
# import cv2
# import shutil
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # === Initialize Flask app ===
# app = Flask(__name__)

# # === Load trained LSTM model ===
# model = load_model("model/final_asl_lstm_best_model.h5")
# actions = np.array([
#     'hello', 'thank_you', 'yes', 'no', 'please',
#     'help', 'sorry', 'nice_to_meet_you', 'how_are_you', 'Excuse_Me'
# ])

# # === MediaPipe Holistic setup ===
# mp_holistic = mp.solutions.holistic
# mp_drawing = mp.solutions.drawing_utils

# # === MediaPipe detection function ===
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return results

# # === Keypoint extraction function ===
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility]
#                      for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z]
#                      for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z]
#                    for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z]
#                    for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# # === Prediction route ===
# @app.route('/predict', methods=['POST'])
# def predict():
#     frame_dir = 'frames'
#     processed_dir = os.path.join(frame_dir, 'processed_frames')
#     os.makedirs(processed_dir, exist_ok=True)

#     sequence = []

#     try:
#         # Step 1: Get sorted image list
#         image_files = sorted([
#             f for f in os.listdir(frame_dir)
#             if f.lower().endswith('.jpg') or f.lower().endswith('.png')
#         ], key=lambda x: os.path.getmtime(os.path.join(frame_dir, x)))

#         if len(image_files) < 5:
#             return jsonify({'error': "Not enough frames (need at least 5)"}), 400

#         selected_images = image_files[:5]

#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:

#             for img_file in selected_images:
#                 img_path = os.path.join(frame_dir, img_file)
#                 image = cv2.imread(img_path)
#                 if image is None:
#                     return jsonify({'error': f"Failed to load image {img_file}"}), 400

#                 results = mediapipe_detection(image, holistic)
#                 keypoints = extract_keypoints(results)
#                 sequence.append(keypoints)

#                 # === Draw landmarks ===
#                 if results.pose_landmarks:
#                     mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_holistic.POSE_CONNECTIONS)
#                 if results.face_landmarks:
#                     mp_drawing.draw_landmarks(image, results.face_landmarks, mp_holistic.FACEMESH_TESSELATION)
#                 if results.left_hand_landmarks:
#                     mp_drawing.draw_landmarks(image, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
#                 if results.right_hand_landmarks:
#                     mp_drawing.draw_landmarks(image, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS)

#                 # === Save image with landmarks ===
#                 processed_path = os.path.join(processed_dir, f"processed_{img_file}")
#                 cv2.imwrite(processed_path, image)

#                 # Optionally delete original
#                 os.remove(img_path)

#         # Step 2: Prepare input for model
#         sequence = np.array(sequence)  # (5, 1662)
#         sequence = np.expand_dims(sequence, axis=0)  # (1, 5, 1662)

#         # Step 3: Predict
#         prediction = model.predict(sequence)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# # === Run server ===
# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000, debug=True)


# # use the h5 model 
# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained model
# model = load_model("model/final_asl_lstm_best_model.h5")
# actions = np.array(['hello', 'thank_you', 'yes', 'no', 'please', 'help', 'sorry', 'nice_to_meet_you', 'how_are_you', 'Excuse_Me'])

# # Initialize MediaPipe Holistic
# mp_holistic = mp.solutions.holistic

# # MediaPipe detection function
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return results

# # Extract keypoints
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility]
#                      for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z]
#                      for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z]
#                    for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z]
#                    for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# # Route: Prediction API
# @app.route('/predict', methods=['POST'])
# def predict():
#     frame_dir = 'frames'
#     sequence = []

#     try:
#         # 🧹 Step 1: Get list of all image files (jpg or png)
#         image_files = sorted([
#             f for f in os.listdir(frame_dir)
#             if f.lower().endswith('.jpg') or f.lower().endswith('.png')
#         ], key=lambda x: os.path.getmtime(os.path.join(frame_dir, x)))  # Sort by modification time

#         if len(image_files) < 5:
#             return jsonify({'error': "Not enough frames (need at least 5)"}), 400

#         selected_images = image_files[:5]  # ✅ Take the first 5 uploaded images

#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:

#             for img_file in selected_images:
#                 img_path = os.path.join(frame_dir, img_file)

#                 image = cv2.imread(img_path)
#                 if image is None:
#                     return jsonify({'error': f"Failed to load image {img_file}"}), 400

#                 results = mediapipe_detection(image, holistic)
#                 keypoints = extract_keypoints(results)
#                 sequence.append(keypoints)

#                 # 🧹 Optional: Delete processed image
#                 os.remove(img_path)

#         # Step 2: Prepare sequence for model
#         sequence = np.array(sequence)  # (5, 1662)
#         sequence = np.expand_dims(sequence, axis=0)  # (1, 5, 1662)

#         # Step 3: Predict
#         prediction = model.predict(sequence)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# # Run server
# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000, debug=True)

# single frame????????????????????????????/
# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# app = Flask(__name__)

# # Load trained model
# model = load_model("model/FINAL_ASL_MODEL_single_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # Initialize MediaPipe
# mp_holistic = mp.solutions.holistic

# def mediapipe_detection(image, holistic_model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = holistic_model.process(image)
#     return results

# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility]
#                      for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z]
#                      for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z]
#                    for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z]
#                    for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# @app.route('/predict', methods=['POST'])
# def predict():
#     frame_dir = 'frames'
#     image_files = sorted([
#         f for f in os.listdir(frame_dir)
#         if f.lower().endswith('.jpg') or f.lower().endswith('.png')
#     ])

#     if not image_files:
#         return jsonify({'error': "No image found in frames/"}), 400

#     image_file = image_files[0]
#     image_path = os.path.join(frame_dir, image_file)

#     try:
#         image = cv2.imread(image_path)
#         if image is None:
#             os.remove(image_path)
#             return jsonify({'error': f"Failed to load image: {image_file}"}), 400

#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             results = mediapipe_detection(image, holistic)
#             keypoints = extract_keypoints(results)

#         input_data = np.expand_dims([keypoints], axis=0)
#         prediction = model.predict(input_data)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         # ✅ Delete image after use
#         os.remove(image_path)

#         # 📨 Return result
#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence,
#             'processed_file': image_file
#         })

#     except Exception as e:
#         if os.path.exists(image_path):
#             os.remove(image_path)
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000, debug=True)





# 10 FRAME SINGLE FRAME

# JUST PROCESS THE FIRST FRAME

# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained single-frame model
# model = load_model("model/FINAL_ASL_MODEL_single_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # MediaPipe holistic setup
# mp_holistic = mp.solutions.holistic

# # MediaPipe detection function
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# # Extract keypoints
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# # Prediction route
# @app.route('/predict', methods=['POST'])
# def predict():
#     image_path = os.path.join('frames', '0.jpg')

#     if not os.path.exists(image_path):
#         return jsonify({'error': "Missing frame 0.jpg"}), 400

#     try:
#         image = cv2.imread(image_path)
#         if image is None:
#             return jsonify({'error': "Failed to load image"}), 400

#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             _, results = mediapipe_detection(image, holistic)
#             keypoints = extract_keypoints(results)

#         # Prepare input shape: (1, 1, 1662)
#         input_data = np.expand_dims([keypoints], axis=0)

#         prediction = model.predict(input_data)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=5000, debug=True)

# 10 FRAME 
# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained model
# model = load_model("model/FINAL_ASL_MODEL_few_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # MediaPipe holistic setup
# mp_holistic = mp.solutions.holistic

# # Function to run MediaPipe detection
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# # Extract keypoints from MediaPipe result
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# @app.route('/predict', methods=['POST'])
# def predict():
#     image_folder = 'frames'
#     sequence = []

#     try:
#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             for i in range(10):
#                 img_path = os.path.join(image_folder, f'{i}.jpg')
#                 if not os.path.exists(img_path):
#                     return jsonify({'error': f"Missing frame {i}.jpg in {image_folder}"}), 400

#                 image = cv2.imread(img_path)
#                 if image is None:
#                     return jsonify({'error': f"Failed to load {img_path}"}), 400

#                 _, results = mediapipe_detection(image, holistic)
#                 keypoints = extract_keypoints(results)
#                 sequence.append(keypoints)

#         sequence = np.array(sequence)  # (30, 1662)
#         sequence = np.expand_dims(sequence, axis=0)  # (1, 30, 1662)

#         prediction = model.predict(sequence)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=5000, debug=True)



# 10 FRAME SINGLE FRAME

# JUST PROCESS THE FIRST FRAME

# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained single-frame model
# model = load_model("model/FINAL_ASL_MODEL_single_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # MediaPipe holistic setup
# mp_holistic = mp.solutions.holistic

# # MediaPipe detection function
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# # Extract keypoints
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# # Prediction route
# @app.route('/predict', methods=['POST'])
# def predict():
#     image_path = os.path.join('frames', '0.jpg')

#     if not os.path.exists(image_path):
#         return jsonify({'error': "Missing frame 0.jpg"}), 400

#     try:
#         image = cv2.imread(image_path)
#         if image is None:
#             return jsonify({'error': "Failed to load image"}), 400

#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             _, results = mediapipe_detection(image, holistic)
#             keypoints = extract_keypoints(results)

#         # Prepare input shape: (1, 1, 1662)
#         input_data = np.expand_dims([keypoints], axis=0)

#         prediction = model.predict(input_data)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=5000, debug=True)

# 10 FRAME 
# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained model
# model = load_model("model/FINAL_ASL_MODEL_few_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # MediaPipe holistic setup
# mp_holistic = mp.solutions.holistic

# # Function to run MediaPipe detection
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# # Extract keypoints from MediaPipe result
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# @app.route('/predict', methods=['POST'])
# def predict():
#     image_folder = 'frames'
#     sequence = []

#     try:
#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             for i in range(10):
#                 img_path = os.path.join(image_folder, f'{i}.jpg')
#                 if not os.path.exists(img_path):
#                     return jsonify({'error': f"Missing frame {i}.jpg in {image_folder}"}), 400

#                 image = cv2.imread(img_path)
#                 if image is None:
#                     return jsonify({'error': f"Failed to load {img_path}"}), 400

#                 _, results = mediapipe_detection(image, holistic)
#                 keypoints = extract_keypoints(results)
#                 sequence.append(keypoints)

#         sequence = np.array(sequence)  # (30, 1662)
#         sequence = np.expand_dims(sequence, axis=0)  # (1, 30, 1662)

#         prediction = model.predict(sequence)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=5000, debug=True)



# import os
# import cv2
# import numpy as np
# import time
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Load trained model
# model = load_model("model/FINAL_ASL_MODEL_single_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # Setup MediaPipe
# mp_holistic = mp.solutions.holistic

# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# # 🔁 Continuous prediction loop
# def run_prediction_loop():
#     frame_dir = 'frames'
#     print("📡 Starting auto prediction loop...")
    
#     while True:
#         image_files = sorted([
#             f for f in os.listdir(frame_dir)
#             if f.endswith('.jpg') and f.split('.')[0].isdigit()
#         ], key=lambda x: int(x.split('.')[0]))

#         if not image_files:
#             time.sleep(1)
#             continue

#         image_file = image_files[0]
#         image_path = os.path.join(frame_dir, image_file)

#         try:
#             image = cv2.imread(image_path)
#             if image is None:
#                 print(f"❌ Failed to load {image_file}, skipping...")
#                 os.remove(image_path)
#                 continue

#             with mp_holistic.Holistic(
#                 static_image_mode=True,
#                 model_complexity=1,
#                 enable_segmentation=False,
#                 refine_face_landmarks=False
#             ) as holistic:
#                 _, results = mediapipe_detection(image, holistic)
#                 keypoints = extract_keypoints(results)

#             input_data = np.expand_dims([keypoints], axis=0)  # (1, 1, 1662)
#             prediction = model.predict(input_data)[0]
#             predicted_label = actions[np.argmax(prediction)]
#             confidence = float(np.max(prediction))

#             print(f"✅ {image_file} → Prediction: {predicted_label} ({confidence:.2f})")

#             os.remove(image_path)

#         except Exception as e:
#             print(f"❌ Error processing {image_file}: {e}")
#             time.sleep(1)

# # Start the loop
# if __name__ == '__main__':
#     run_prediction_loop()




# 10 FRAME SINGLE FRAME

# JUST PROCESS THE FIRST FRAME

# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained single-frame model
# model = load_model("model/FINAL_ASL_MODEL_single_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # MediaPipe holistic setup
# mp_holistic = mp.solutions.holistic

# # MediaPipe detection function
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# # Extract keypoints
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# # Prediction route
# @app.route('/predict', methods=['POST'])
# def predict():
#     image_path = os.path.join('frames', '0.jpg')

#     if not os.path.exists(image_path):
#         return jsonify({'error': "Missing frame 0.jpg"}), 400

#     try:
#         image = cv2.imread(image_path)
#         if image is None:
#             return jsonify({'error': "Failed to load image"}), 400

#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             _, results = mediapipe_detection(image, holistic)
#             keypoints = extract_keypoints(results)

#         # Prepare input shape: (1, 1, 1662)
#         input_data = np.expand_dims([keypoints], axis=0)

#         prediction = model.predict(input_data)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=5000, debug=True)

# 10 FRAME 
# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained model
# model = load_model("model/FINAL_ASL_MODEL_few_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # MediaPipe holistic setup
# mp_holistic = mp.solutions.holistic

# # Function to run MediaPipe detection
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# # Extract keypoints from MediaPipe result
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# @app.route('/predict', methods=['POST'])
# def predict():
#     image_folder = 'frames'
#     sequence = []

#     try:
#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             for i in range(10):
#                 img_path = os.path.join(image_folder, f'{i}.jpg')
#                 if not os.path.exists(img_path):
#                     return jsonify({'error': f"Missing frame {i}.jpg in {image_folder}"}), 400

#                 image = cv2.imread(img_path)
#                 if image is None:
#                     return jsonify({'error': f"Failed to load {img_path}"}), 400

#                 _, results = mediapipe_detection(image, holistic)
#                 keypoints = extract_keypoints(results)
#                 sequence.append(keypoints)

#         sequence = np.array(sequence)  # (30, 1662)
#         sequence = np.expand_dims(sequence, axis=0)  # (1, 30, 1662)

#         prediction = model.predict(sequence)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=5000, debug=True)



# 10 FRAME SINGLE FRAME

# JUST PROCESS THE FIRST FRAME

# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained single-frame model
# model = load_model("model/FINAL_ASL_MODEL_single_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # MediaPipe holistic setup
# mp_holistic = mp.solutions.holistic

# # MediaPipe detection function
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# # Extract keypoints
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# # Prediction route
# @app.route('/predict', methods=['POST'])
# def predict():
#     image_path = os.path.join('frames', '0.jpg')

#     if not os.path.exists(image_path):
#         return jsonify({'error': "Missing frame 0.jpg"}), 400

#     try:
#         image = cv2.imread(image_path)
#         if image is None:
#             return jsonify({'error': "Failed to load image"}), 400

#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             _, results = mediapipe_detection(image, holistic)
#             keypoints = extract_keypoints(results)

#         # Prepare input shape: (1, 1, 1662)
#         input_data = np.expand_dims([keypoints], axis=0)

#         prediction = model.predict(input_data)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=5000, debug=True)

# 10 FRAME 
# import os
# import cv2
# import numpy as np
# from flask import Flask, jsonify
# from tensorflow.keras.models import load_model
# import mediapipe as mp

# # Initialize Flask app
# app = Flask(__name__)

# # Load trained model
# model = load_model("model/FINAL_ASL_MODEL_few_frame.h5")
# actions = ['hello', 'thanks', 'iloveyou']

# # MediaPipe holistic setup
# mp_holistic = mp.solutions.holistic

# # Function to run MediaPipe detection
# def mediapipe_detection(image, model):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
#     results = model.process(image)
#     return image, results

# # Extract keypoints from MediaPipe result
# def extract_keypoints(results):
#     pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(132)
#     face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(1404)
#     lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(63)
#     rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(63)
#     return np.concatenate([pose, face, lh, rh])

# @app.route('/predict', methods=['POST'])
# def predict():
#     image_folder = 'frames'
#     sequence = []

#     try:
#         with mp_holistic.Holistic(
#             static_image_mode=True,
#             model_complexity=1,
#             enable_segmentation=False,
#             refine_face_landmarks=False
#         ) as holistic:
#             for i in range(10):
#                 img_path = os.path.join(image_folder, f'{i}.jpg')
#                 if not os.path.exists(img_path):
#                     return jsonify({'error': f"Missing frame {i}.jpg in {image_folder}"}), 400

#                 image = cv2.imread(img_path)
#                 if image is None:
#                     return jsonify({'error': f"Failed to load {img_path}"}), 400

#                 _, results = mediapipe_detection(image, holistic)
#                 keypoints = extract_keypoints(results)
#                 sequence.append(keypoints)

#         sequence = np.array(sequence)  # (30, 1662)
#         sequence = np.expand_dims(sequence, axis=0)  # (1, 30, 1662)

#         prediction = model.predict(sequence)[0]
#         predicted_label = actions[np.argmax(prediction)]
#         confidence = float(np.max(prediction))

#         return jsonify({
#             'prediction': predicted_label,
#             'confidence': confidence
#         })

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=5000, debug=True)
