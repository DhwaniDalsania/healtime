const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    doctorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    date: { type: String, required: true },
    time: { type: String, required: true },
    type: { type: String, enum: ['Video Consultation', 'In-person Visit', 'Follow-up Call'], default: 'Video Consultation' },
    status: { type: String, enum: ['Pending', 'Confirmed', 'Cancelled', 'In Progress'], default: 'Pending' }
}, { timestamps: true });

module.exports = mongoose.model('Appointment', appointmentSchema);
