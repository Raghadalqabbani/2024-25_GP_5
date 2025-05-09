# import requests

# url = "http://192.168.100.62:5000/predict"

# try:
#     response = requests.post(url)
#     if response.status_code == 200:
#         data = response.json()
#         print(f"✅ Prediction: {data['prediction']} (confidence: {data['confidence']:.2f})")
#     else:
#         print("❌ Failed to get a valid response")
#         print(response.text)
# except Exception as e:
#     print("❌ Error occurred while sending request:", e)
import os
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.callbacks import EarlyStopping
from tensorflow.keras import regularizers

# 📁 Paths
FOLDER_1 = os.path.abspath('ASL_FINAL_MODEL/hands')
FOLDER_2 = os.path.abspath('ASL_FINAL_MODEL/Hands_Only_Data')
MODEL_SAVE_PATH = os.path.join('ASL_FINAL_MODEL', 'saved_model', 'new_trained_hands_lstm_model.h5')

# 🏷️ Class labels
actions = np.array([
    'hello', 'thank_you', 'yes', 'no', 'please',
    'help', 'sorry', 'nice_to_meet_you', 'how_are_you', 'Excuse_Me'
])

#  Load data from folder
def load_data_from_folder(folder_path):
    X, y = [], []
    for idx, action in enumerate(actions):
        action_folder = os.path.join(folder_path, action)
        if not os.path.exists(action_folder):
            continue
        for sequence in os.listdir(action_folder):
            path = os.path.join(action_folder, sequence, 'sequence.npy')
            if os.path.exists(path):
                data = np.load(path)
                if data.shape[1] == 126:  # hands-only check
                    X.append(data)
                    y.append(idx)
    return X, y

#  Load both datasets
X1, y1 = load_data_from_folder(FOLDER_1)
X2, y2 = load_data_from_folder(FOLDER_2)

# Combine both
X = np.array(X1 + X2)
y = to_categorical(np.array(y1 + y2)).astype(int)

#  Split with stratification
X_train, X_val, y_train, y_val = train_test_split(
    X, y, test_size=0.1, random_state=42, stratify=y
)

# ✨ Add Gaussian noise to training data only
X_train = X_train + np.random.normal(0, 0.01, X_train.shape)

#  Define LSTM model with dropout + L2 regularization
model = Sequential([
    LSTM(64, return_sequences=True, activation='relu',
         kernel_regularizer=regularizers.l2(0.001),
         input_shape=(X.shape[1], X.shape[2])),
    Dropout(0.5),
    LSTM(64, activation='relu', kernel_regularizer=regularizers.l2(0.001)),
    Dropout(0.5),
    Dense(actions.shape[0], activation='softmax')
])

#  Compile model
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['categorical_accuracy'])

# ⏹️ Early stopping
early_stop = EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)

# 🚀 Train the model
history = model.fit(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=50,
    batch_size=16,
    callbacks=[early_stop]
)

# 💾 Save the final model
model.save(MODEL_SAVE_PATH)
print(f"\n✅ New model saved at: {MODEL_SAVE_PATH}")
