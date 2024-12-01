const express = require('express');
const multer = require('multer');
const path = require('path');

const app = express();
const port = 3002; // Change this to any available port (e.g., 3001, 4000)

// Set up storage for uploaded files
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, './uploads');
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}_${file.originalname}`);
    }
});

const upload = multer({ storage });

// Serve the uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Endpoint to handle file uploads
app.post('/upload', upload.single('file'), (req, res) => {
    if (req.file) {
        res.json({
            success: true,
            message: 'File uploaded successfully',
            filePath: `/uploads/${req.file.filename}`
        });
    } else {
        res.status(400).json({ success: false, message: 'No file uploaded' });
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://192.168.0.202:${port}`);
});
