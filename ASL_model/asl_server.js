
// // this code is take image from uploads file until 30 then it send it to the model 

// 🚀 Node.js + Express Server to Receive and Save Uploaded Images for ASL Prediction

// 📦 Required dependencies
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 🛠️ Create the app
const app = express();
const port = 3001; // The port your server runs on

// 📁 Define the folder to save uploaded images (as frames)
const framesPath = path.join(__dirname, 'frames');

// 🧱 Make sure the "frames" folder exists, if not, create it
if (!fs.existsSync(framesPath)) {
    fs.mkdirSync(framesPath, { recursive: true });
}

// 💾 Multer storage engine: how to save each uploaded image
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, framesPath); // Save to the 'frames' folder
    },
    filename: (req, file, cb) => {
        // 🔢 Find the next number for the image name (0.jpg, 1.jpg, ...)
        const existingFiles = fs
            .readdirSync(framesPath)
            .filter(f => f.endsWith('.jpg'))
            .map(f => parseInt(f.split('.')[0]))
            .filter(Number.isInteger);
        
        const nextIndex = existingFiles.length > 0 ? Math.max(...existingFiles) + 1 : 0;
        cb(null, `${nextIndex}.jpg`);
    }
});

// 🎒 Set up multer with the custom storage engine
const upload = multer({ storage });

// 🌍 Serve the "frames" folder so files can be accessed via URL
app.use('/frames', express.static(framesPath));

// 📤 POST /upload – This endpoint receives an image and saves it
app.post('/frames', upload.single('file'), (req, res) => {
    if (req.file) {
        res.json({
            success: true,
            message: 'Image uploaded successfully!',
            filePath: `/frames/${req.file.filename}`
        });
    } else {
        res.status(400).json({
            success: false,
            message: '❌ No file uploaded'
        });
    }
});

// 🚀 Start the server
app.listen(port, () => {
    console.log(`🟢 ASL image upload server running at: http://192.168.8.136:${port}`);
});


