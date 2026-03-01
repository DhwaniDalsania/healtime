require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const User = require('./models/User');
const Appointment = require('./models/Appointment');
const Message = require('./models/Message');
const Record = require('./models/Record');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path.join(__dirname, 'uploads');
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir);
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Database Connection
mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('Connected to MongoDB via Mongoose'))
    .catch(err => console.error('MongoDB connection error:', err));

// --- Routes ---

// Auth
app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email, password });
        if (!user) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        if (user.role === 'doctor' && user.status !== 'approved') {
            return res.status(403).json({
                message: `Your account is ${user.status}. Please contact the administrator.`
            });
        }

        res.json({
            id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            status: user.status
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.post('/api/auth/register', async (req, res) => {
    try {
        const { name, email, password, role } = req.body;

        if (role === 'admin') {
            return res.status(403).json({ message: 'Admin registration is not allowed.' });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const status = role === 'doctor' ? 'pending' : 'approved';
        const user = new User({
            name,
            email,
            password,
            role: role || 'patient',
            status: status
        });

        await user.save();
        res.status(201).json({
            id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            status: user.status
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Appointments
app.post('/api/appointments', async (req, res) => {
    try {
        const { patientId, doctorId, date, time, type } = req.body;
        const appointment = new Appointment({
            patientId,
            doctorId,
            date,
            time,
            type,
            status: 'Pending'
        });
        await appointment.save();
        res.status(201).json(appointment);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.get('/api/appointments', async (req, res) => {
    try {
        const { userId, role } = req.query;
        let query = {};
        if (role === 'doctor') {
            query = { doctorId: userId };
        } else {
            query = { patientId: userId };
        }
        const appointments = await Appointment.find(query)
            .populate('patientId', 'name email')
            .populate('doctorId', 'name specialty')
            .sort({ date: 1, time: 1 });
        res.json(appointments);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.patch('/api/appointments/:id', async (req, res) => {
    try {
        const { status } = req.body;
        const appointment = await Appointment.findByIdAndUpdate(
            req.params.id,
            { status },
            { new: true }
        );
        res.json(appointment);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Records
app.post('/api/records', upload.single('file'), async (req, res) => {
    try {
        const { patientId, doctorId, doctorName, date, diagnosis, prescription } = req.body;

        const attachments = [];
        if (req.file) {
            attachments.push(`/uploads/${req.file.filename}`);
        }

        const record = new Record({
            patientId,
            doctorId,
            doctorName,
            date,
            diagnosis,
            prescription,
            attachments
        });
        await record.save();
        res.status(201).json(record);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.get('/api/records', async (req, res) => {
    try {
        const { userId } = req.query;
        let query = {};
        if (userId) {
            query = { patientId: userId };
        }
        const records = await Record.find(query).sort({ date: -1 });
        res.json(records);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Admin
app.get('/api/admin/dashboard', async (req, res) => {
    try {
        const doctors = await User.find({ role: 'doctor' });
        const patients = await User.find({ role: 'patient' });
        res.json({
            doctors,
            patients,
            stats: {
                totalDoctors: doctors.length,
                pendingDoctors: doctors.filter(d => d.status === 'pending').length,
                totalPatients: patients.length
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.get('/api/admin/doctors', async (req, res) => {
    try {
        const doctors = await User.find({ role: 'doctor' });
        res.json(doctors);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.post('/api/admin/approve-doctor', async (req, res) => {
    try {
        const { userId, status } = req.body;
        if (!['approved', 'rejected'].includes(status)) {
            return res.status(400).json({ message: 'Invalid status' });
        }
        const user = await User.findByIdAndUpdate(userId, { status }, { new: true });
        res.json(user);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.delete('/api/admin/users/:id', async (req, res) => {
    try {
        await User.findByIdAndDelete(req.params.id);
        // Also cleanup related appointments and messages
        await Appointment.deleteMany({ $or: [{ patientId: req.params.id }, { doctorId: req.params.id }] });
        await Message.deleteMany({ $or: [{ senderId: req.params.id }, { receiverId: req.params.id }] });

        res.json({ message: 'User deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Stats
app.get('/api/stats', async (req, res) => {
    try {
        const { userId, role } = req.query;
        if (role === 'doctor') {
            const today = new Date().toISOString().split('T')[0];
            const todayApps = await Appointment.countDocuments({
                doctorId: userId,
                date: { $regex: today }
            });
            const pendingApps = await Appointment.countDocuments({
                doctorId: userId,
                status: 'Pending'
            });
            const totalPatients = await Appointment.distinct('patientId', { doctorId: userId });
            res.json({
                activeAppointments: todayApps,
                pendingRequests: pendingApps,
                totalPatients: totalPatients.length
            });
        } else {
            const count = await Appointment.countDocuments({ patientId: userId });
            res.json({ totalAppointments: count });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Users & Doctors
app.get('/api/doctors', async (req, res) => {
    try {
        const doctors = await User.find({ role: 'doctor', status: 'approved' });
        res.json(doctors);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.put('/api/users/:id', async (req, res) => {
    try {
        const userId = req.params.id;
        const updates = req.body;

        // Prevent role manipulation
        delete updates.role;
        delete updates.status;

        const user = await User.findByIdAndUpdate(userId, updates, { new: true });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json(user);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Messages (Chat)
app.post('/api/messages', async (req, res) => {
    try {
        const { senderId, receiverId, content } = req.body;
        const message = new Message({ senderId, receiverId, content });
        await message.save();
        res.status(201).json(message);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get unique chat contacts for a user
app.get('/api/messages/contacts/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;

        // Find all messages where the user is either sender or receiver
        const messages = await Message.find({
            $or: [{ senderId: userId }, { receiverId: userId }]
        }).sort({ createdAt: -1 });

        // Extract unique contact IDs and the latest message
        const contactsMap = new Map();

        for (const msg of messages) {
            const contactId = msg.senderId.toString() === userId ? msg.receiverId.toString() : msg.senderId.toString();

            if (!contactsMap.has(contactId)) {
                contactsMap.set(contactId, {
                    contactId: contactId,
                    lastMessage: msg.content,
                    timestamp: msg.createdAt
                });
            }
        }

        const contactIds = Array.from(contactsMap.keys());

        // Fetch user details for those contacts
        const users = await User.find({ _id: { $in: contactIds } }, 'name role imageUrl specialty');

        const result = users.map(user => {
            const contactInfo = contactsMap.get(user._id.toString());
            return {
                id: user._id,
                name: user.name,
                role: user.role,
                imageUrl: user.imageUrl,
                specialty: user.specialty,
                lastMessage: contactInfo.lastMessage,
                timestamp: contactInfo.timestamp
            };
        });

        // Sort by most recent message
        result.sort((a, b) => b.timestamp - a.timestamp);

        res.json(result);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.get('/api/messages/:userId1/:userId2', async (req, res) => {
    try {
        const { userId1, userId2 } = req.params;
        const messages = await Message.find({
            $or: [
                { senderId: userId1, receiverId: userId2 },
                { senderId: userId2, receiverId: userId1 }
            ]
        }).sort({ createdAt: 1 });
        res.json(messages);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Seed Data
app.get('/api/seed', async (req, res) => {
    try {
        await User.deleteMany({});
        await Appointment.deleteMany({});
        await Message.deleteMany({});

        // Add a default patient and doctor for testing
        const users = [
            { name: 'John Doe', email: 'john@example.com', password: 'password123', role: 'patient' },
            { name: 'Dr. Sarah Smith', email: 'smith@example.com', password: 'password123', role: 'doctor', status: 'approved', specialty: 'Cardiologist', rating: 4.8, reviews: 124, availability: 'Mon-Fri, 9AM-5PM', clinic: 'Heart Care Center', price: '$150' },
            { name: 'Admin User', email: 'admin@healtime.com', password: 'adminpassword', role: 'admin', status: 'approved' },
            { name: 'Dr. Pending', email: 'pending@example.com', password: 'password123', role: 'doctor', status: 'pending' },
            { name: "Dr. Michael Ross", email: "ross@example.com", password: 'password123', role: 'doctor', status: 'approved', specialty: "Neurologist", rating: 4.9, reviews: 89, availability: "Mon-Thu, 10AM-4PM", clinic: 'Neuro Institute', price: '$200' },
            { name: "Dr. Emma Watson", email: "watson@example.com", password: 'password123', role: 'doctor', status: 'approved', specialty: "Pediatrician", rating: 4.7, reviews: 156, availability: "Tue-Sat, 8AM-2PM", clinic: 'Kids Clinic', price: '$100' }
        ];
        await User.insertMany(users);

        res.json({ message: 'Data seeded successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
